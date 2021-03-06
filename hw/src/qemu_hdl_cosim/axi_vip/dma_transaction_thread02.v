
//  integer file, r;
//  reg [80*8:1] command;
//  reg [31:0] data1;
//  reg [31:0] data2;
//
//    file = $fopen("dma_transaction_for_queue_notify.txt","r");
//    if (file == 0)
//    begin
//        $display("Failed to open dma_transaction_for_queue_notify playback file!");
//    end
//    
//    while (!$feof(file))
//    begin
//        r = $fscanf(file, " %s %h %h\n", command, data1, data2);
//        case (command)
//        "rd":
//        begin
//            debug_trace_rd(data1+32'h`PCIE_BAR_MAP, data2);
//            $display("dma_rd mem[%8h] = %8h", data1, data2);
//        end
//        "wr":
//        begin
//            debug_trace_wr(data1+32'h`PCIE_BAR_MAP,data2);
//            $display("dma_wr mem[%8h] = %8h", data1+32'h`PCIE_BAR_MAP, data2);
//        end
//        default:
//            $display("Trace Playback Unknown command '%0s'", command);
//        endcase
//    end
//
//    $fclose(file);

  reg [63:0] data1;
  reg [31:0] data2;

  `define CSR_PATH test_top.DUT.shell_region_i.FIM.FIU.feature_ram.virtio_csr_0.inst
  `define TOP_PATH test_top 

  //`define PREFETCH_ALL_RX_DESC
  `define PREFETCH_LIMIT 4

  reg [15:0] virt_queue_num = 0;
  reg [15:0] virt_queue_sel = 0;
  reg [63:0] virt_queue_phy = 0;
  reg [15:0] curr_avail_idx[3];
  reg [15:0] next_avail_idx[3];
  reg [15:0] num_avail_idx;
  reg [ 7:0] ith_avail_idx;
  reg [15:0] desc_idx = 0;
  reg [16*8-1:0] desc_entry = 0;
  reg [63:0] desc_entry_phy = 0;
  reg [31:0] desc_entry_len = 0;
  reg [15:0] desc_entry_flg = 0;
  reg desc_entry_flg_next, desc_entry_flg_writ, desc_entry_flg_indi;
  reg [15:0] desc_entry_nxt = 0;
  reg [31:0] desc_chain_len= 0;

  reg [ 7:0] desc_queue_size[3];
  reg [15:0] num_toget_idx;

  //reg queue_notify_set[3];
  //reg queue_notify_clr[3];
  //reg ring_available_set[3];
  reg ring_available_clr[3];
  //reg [2:0] queue_notify_pending;

  // reset
  always begin
    @(posedge `CSR_PATH.csr_rst);
    for (int i = 0; i < 3; i++) begin
      curr_avail_idx[i] = 0;
      next_avail_idx[i] = 0;
      
      //queue_notify_set[i] = 0;
      //queue_notify_clr[i] = 0;
      ring_available_clr[i] = 0;
    end
  end

  //// make a record of pending notification
  //always @(posedge `CSR_PATH.clk) begin
  //  for (int i = 0; i < 3; i++) begin
  //    if (queue_notify_set[i])
  //      queue_notify_pending[i] = 1'b1;
  //    else if (queue_notify_clr[i])
  //      queue_notify_pending[i] = 1'b0;
  //    else if (`CSR_PATH.csr_rst)
  //      queue_notify_pending[i] = 1'b0;
  //  end 
  //end

  //// thread 0: handle notification
  //always begin
  //  @(posedge `CSR_PATH.csr_access_10B2);
  //  if (`CSR_PATH.csr_drv_ok) begin

  //    repeat(2) @(posedge `CSR_PATH.clk);
  //    virt_queue_num = `CSR_PATH.csr_reg_10B2;

  //    queue_notify_set[virt_queue_num] = 1;
  //    @(posedge `CSR_PATH.clk);
  //    queue_notify_set[virt_queue_num] = 0;

  //  end  
  //end

  // { process notified virtqueue
  // Do we need multiple channels to hanlde multiple virtqueue?
  // thread 2: read available ring entry, num*2B
  always begin
    @(posedge `CSR_PATH.clk);
    // sync local next available index with thread1
    for (int i = 0; i < 3; i++) begin
      next_avail_idx[i]  = `TOP_PATH.th01_next_avail_idx[i];
      desc_queue_size[i] = `TOP_PATH.desc_queue[i].size(); 
    end 
`ifdef PREFETCH_ALL_RX_DESC
    // handle newly_added available ring
    if (`TOP_PATH.ring_available_pending != 0) begin
`else
    // handle unfinished/newly_added available ring
    if (1) begin
`endif
`ifdef PREFETCH_ALL_RX_DESC
      // arbiter to choose which pending available ring to process
      virt_queue_sel = `TOP_PATH.ring_available_pending[0]? 0:
                      (`TOP_PATH.ring_available_pending[1]? 1:
                      (`TOP_PATH.ring_available_pending[2]? 2:
                                                            0));
`else
      // arbiter to choose which pending available ring to process
      virt_queue_sel = (desc_queue_size[0] != `PREFETCH_LIMIT && next_avail_idx[0] != curr_avail_idx[0])? 0:
                      ((desc_queue_size[1] != `PREFETCH_LIMIT && next_avail_idx[1] != curr_avail_idx[1])? 1:
                      ((desc_queue_size[2] != `PREFETCH_LIMIT && next_avail_idx[2] != curr_avail_idx[2])? 2:
                                                                                                          0));
`endif
      // get Virtqueue physical address
      virt_queue_phy = {20'h00000, `CSR_PATH.csr_reg_08B4[virt_queue_sel][31:0], 12'h000};
      
`ifdef PREFETCH_ALL_RX_DESC
      // clear pending available ring
      @(posedge `CSR_PATH.clk);
      ring_available_clr[virt_queue_sel] = 1;
      @(posedge `CSR_PATH.clk);
      ring_available_clr[virt_queue_sel] = 0;
`endif

      // calculate number of available index in available ring
      num_avail_idx = (next_avail_idx[virt_queue_sel] >= curr_avail_idx[virt_queue_sel])?
                      (next_avail_idx[virt_queue_sel]  - curr_avail_idx[virt_queue_sel]):
                (256 + next_avail_idx[virt_queue_sel]  - curr_avail_idx[virt_queue_sel]);

`ifdef PREFETCH_ALL_RX_DESC
      // use the available number, regardless of the decriptor queue status
      num_toget_idx = num_avail_idx;
`else
      // use the smaller one
      num_toget_idx = ((`PREFETCH_LIMIT - desc_queue_size[virt_queue_sel]) < num_avail_idx)?
                       (`PREFETCH_LIMIT - desc_queue_size[virt_queue_sel]):
                       num_avail_idx; 
`endif

      // { handle multiple descriptor chains
      for (int i = 0; i < num_toget_idx; i++) begin
        // calculate the ith idx
        ith_avail_idx = curr_avail_idx[virt_queue_sel]+i;// 0~255

        // read available ring entry, num*2B
        data1 = virt_queue_phy+(0+16*256)+4+ith_avail_idx*2;
        debug_trace_rd(data1, data2);                                                 $display("th02: 2.0 dma_rd, %d", i);
        desc_idx = data1[1]? data2[31:16]: data2[15:0];
      
        // read the whole descriptor chain, following the NEXT flag+next
        desc_entry_flg_next = 1'b1; 
        desc_entry_nxt = desc_idx;
        desc_chain_len = 0;
        while (desc_entry_flg_next) begin
          // read descriptor, num*chain_entry*16B
          data1 = virt_queue_phy+(0)+desc_entry_nxt*16+0; 
          debug_trace_rd(data1, data2);                                              $display("th02: 3.0 dma_rd, %d, %d", i, desc_entry_nxt);
          desc_entry[ 31:  0] = data2;
          data1 = virt_queue_phy+(0)+desc_entry_nxt*16+4; 
          debug_trace_rd(data1, data2);                                              $display("th02: 3.4 dma_rd, %d, %d", i, desc_entry_nxt);
          desc_entry[ 63: 32] = data2;
          data1 = virt_queue_phy+(0)+desc_entry_nxt*16+8; 
          debug_trace_rd(data1, data2);                                              $display("th02: 3.8 dma_rd, %d, %d", i, desc_entry_nxt);
          desc_entry[ 95: 64] = data2;
          data1 = virt_queue_phy+(0)+desc_entry_nxt*16+12; 
          debug_trace_rd(data1, data2);                                              $display("th02: 3.c dma_rd, %d, %d", i, desc_entry_nxt);
          desc_entry[127: 96] = data2;
          //2.4.5 The Virtqueue Descriptor Table
          desc_entry_phy = desc_entry[ 63:  0];  // 64b
          desc_entry_len = desc_entry[ 95: 64];  // 32b
          desc_entry_flg = desc_entry[111: 96];  // 16b
          desc_entry_nxt = desc_entry[127:112];  // 16b
          
          desc_entry_flg_next = desc_entry_flg[0];
          desc_entry_flg_writ = desc_entry_flg[1];
          desc_entry_flg_indi = desc_entry_flg[2];

          $display("th02 desc: %d, %d, %d, %d", desc_entry_len, desc_entry_flg_next, desc_entry_flg_writ, desc_entry_flg_indi);

          desc_chain_len = desc_chain_len + desc_entry_len;

	  `TOP_PATH.desc_queue[virt_queue_sel].push_back({desc_idx, desc_entry});
	end
      
        // TODO: thread 3 4 5: handle receiveq, transmitq and controlq
    
        //if (1) begin  // pretending to send/receive packets
        //  // TODO: thread 6: write used ring entry, len+id, num*8B
        //  data1 = virt_queue_phy+(0+16*256+1*4096)+4+ith_avail_idx*8+0;
        //  data2 = {16'd0, desc_idx};
        //  debug_trace_wr(data1, data2);                                                 $display("th02: 5.0, %d", i);
        //  data1 = virt_queue_phy+(0+16*256+1*4096)+4+ith_avail_idx*8+4;
        //  data2 = desc_entry_flg_writ? desc_chain_len: 0;//5.1.6.1
        //  debug_trace_wr(data1, data2);                                                 $display("th02: 5.4, %d", i);
        //end
      end
      // } handle multiple descriptor chains
      
`ifdef PREFETCH_ALL_RX_DESC
      // update current available index to the next available index
      curr_avail_idx[virt_queue_sel]  = next_avail_idx[virt_queue_sel]; 
`else
      // update current available index with the consumed available ring entry
      curr_avail_idx[virt_queue_sel]  = curr_avail_idx[virt_queue_sel] + num_toget_idx; 
`endif

      //// { update used ring header
      //if (1) begin  // pretending to send/receive packets
      //  // TODO: thread 6: write used ring flags+index(), 2B+2B
      //  data1 = virt_queue_phy+(0+16*256+1*4096)+0;
      //  data2 = {next_avail_idx[virt_queue_sel], 16'd0};
      //  debug_trace_wr(data1, data2);                                                   $display("th02: 6");
      //end
      //// } update used ring header

    end

    // TODO: thread 7: MSI-X interrupt
  end
  //// } process notified virtqueue


