
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

  reg [63      :0] data1;
  reg [8*4096-1:0] data2;

  `define CSR_PATH test_top.DUT.shell_region_i.FIM.FIU.feature_ram.virtio_csr_0.inst
  reg [63:0] virt_queue_phy = 0;
  reg [15:0] curr_avail_idx = 0;
  reg [15:0] next_avail_idx = 0;
  reg [15:0] num_avail_entry = 0;
  reg [15:0] descr_idx = 0;

  always begin
    @(posedge `CSR_PATH.csr_access_10B2);
    if (`CSR_PATH.csr_drv_ok) begin


      repeat(2) @(posedge `CSR_PATH.clk); 
      // get Virtqueue physical address
      virt_queue_phy = {20'h00000, `CSR_PATH.csr_reg_08B4[`CSR_PATH.csr_reg_10B2][31:0], 12'h000};
  
      // read available ring flags+index(tail)
          debug_trace_rd(virt_queue_phy+(0+16*256)+0, data2);                  $display("1");
        next_avail_idx  = data2[31:16]; 
        num_avail_entry = next_avail_idx - curr_avail_idx;
      // read available ring entry
          debug_trace_rd(virt_queue_phy+(0+16*256)+4+curr_avail_idx*2, data2); $display("2"); // TODO: len?
        descr_idx = data2[15:0];
      
      // read descriptor num*16B
          debug_trace_rd(virt_queue_phy+(0)+descr_idx*16, data2);              $display("3");
      //accl:  dma_rd: @0x00000001384bc000(32) =0x00020002000005ee00000000bb421040,000100030000000a00000000bb18bb28  //2.4.5 The Virtqueue Descriptor Table


      // update current available index
        curr_avail_idx  = next_avail_idx;
     
      //// read descriptor num*16B
      //for (int i = 0; i < (num_avail_entry+0)* 16/32; i++) begin
      //    debug_trace_rd(virt_queue_phy+(0)+descr_idx*16+i*32, data2);         $display("3, %d", i);
      //end

      //// read used ring flags+index(tail)
      //    debug_trace_rd(virt_queue_phy+(0+16*256+1*4096)+0, data2);
      //// read 8 used ring id, from 4(head)
      //for (int i = 0; i < 8* 8/4; i++) begin
      //    debug_trace_rd(virt_queue_phy+(1*16*256+1*4096)+4+i*4, data2);
      //end


    end
  end


