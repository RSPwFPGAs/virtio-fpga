
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

    repeat(2) @(posedge `CSR_PATH.clk); 
    // get Virtqueue physical address
    data1 = {`CSR_PATH.csr_reg_08B4[`CSR_PATH.csr_reg_10B2][19:0], 12'h000};

    // read 8 descriptors
    for (int i = 0; i < 8* 16/4; i++) begin
        debug_trace_rd(data1+(0)+i*4, data2);
    end 
    
    // read available ring flags+index(tail)
        debug_trace_rd(data1+(0+16*256)+0, data2);
    // read 8 available ring id, from 4(head)
    for (int i = 0; i < 8* 2/4; i++) begin
        debug_trace_rd(data1+(0+16*256)+4+i*4, data2);
    end
    
    // read used ring flags+index(tail)
        debug_trace_rd(data1+(0+16*256+1*4096)+0, data2);
    // read 8 used ring id, from 4(head)
    for (int i = 0; i < 8* 8/4; i++) begin
        debug_trace_rd(data1+(1*16*256+1*4096)+4+i*4, data2);
    end




