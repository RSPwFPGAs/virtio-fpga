
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

  reg [63   :0] data1;
  reg [256-1:0] data2;

  `define CSR_PATH test_top.DUT.shell_region_i.FIM.FIU.feature_ram.virtio_csr_0.inst
  reg [15:0] virt_queue_sel = 0;
  reg [63:0] virt_queue_phy = 0;
  reg [15:0] curr_avail_idx = 0;
  reg [15:0] next_avail_idx = 0;
  reg [15:0] num_avail_entry = 0;
  reg [15:0] desc_idx = 0;
  reg [16*8-1:0] desc_entry = 0;
  reg [63:0] desc_entry_phy = 0;
  reg [31:0] desc_entry_len = 0;
  reg [15:0] desc_entry_flg = 0;
  reg [15:0] desc_entry_nxt = 0;
  reg [31:0] desc_chain_len= 0;

  always begin
    @(posedge `CSR_PATH.csr_drv_ok);
    curr_avail_idx = 0;
    next_avail_idx = 0;
  end

  always begin
    @(posedge `CSR_PATH.csr_access_10B2);
    if (`CSR_PATH.csr_drv_ok) begin

      repeat(2) @(posedge `CSR_PATH.clk);
      virt_queue_sel = `CSR_PATH.csr_reg_10B2;
      // get Virtqueue physical address
      virt_queue_phy = {20'h00000, `CSR_PATH.csr_reg_08B4[virt_queue_sel][31:0], 12'h000};
  

      // read available ring flags+index(tail), 2B+2B
      debug_trace_rd(virt_queue_phy+(0+16*256)+0, data2);                            $display("1");
      next_avail_idx  = data2[31:16]; 
      num_avail_entry = next_avail_idx - curr_avail_idx;
      
      for (int i = 0; i < num_avail_entry; i++) begin
        // read available ring entry, num*2B
        debug_trace_rd(virt_queue_phy+(0+16*256)+4+curr_avail_idx+i*2, data2);       $display("2, %d", i);
        desc_idx = data2[15:0];
      

        desc_entry_flg = 16'h1; 
        desc_entry_nxt = desc_idx;
	desc_chain_len = 0;
        while (desc_entry_flg[0]) begin
          // read descriptor, num*chain_entry*16B
          debug_trace_rd(virt_queue_phy+(0)+desc_entry_nxt*16, data2);              $display("3, %d", desc_entry_nxt);
          //2.4.5 The Virtqueue Descriptor Table
          desc_entry = (desc_entry_nxt[0] == 0)? data2[127:0]: data2[255:128];
	  desc_entry_phy = desc_entry[ 63:  0];
	  desc_entry_len = desc_entry[ 95: 64];
          desc_entry_flg = desc_entry[111: 96];
          desc_entry_nxt = desc_entry[127:112];
	  desc_chain_len = desc_chain_len + desc_entry_len;
	  // TODO: read/write buffer
        end
      

        // write used ring entry, len+id, num*8B
        data2 = {64'd0, 64'd0, 64'd0, {desc_chain_len, {16'd0, desc_idx}}};
        debug_trace_wr(virt_queue_phy+(0+16*256+1*4096)+4+curr_avail_idx+i*8, data2);
      end
      
      // write used ring flags+index(), 2B+2B
      data2 = {64'd0, 64'd0, 64'd0, {32'd0, {next_avail_idx, 16'd0}}};
      debug_trace_wr(virt_queue_phy+(0+16*256+1*4096)+0, data2);


      // update current available index
      curr_avail_idx  = next_avail_idx;
     

      //// read used ring flags+index(tail)
      //    debug_trace_rd(virt_queue_phy+(0+16*256+1*4096)+0, data2);
      //// read 8 used ring id, from 4(head)
      //for (int i = 0; i < 8* 8/4; i++) begin
      //    debug_trace_rd(virt_queue_phy+(1*16*256+1*4096)+4+i*4, data2);
      //end

    end
  end


