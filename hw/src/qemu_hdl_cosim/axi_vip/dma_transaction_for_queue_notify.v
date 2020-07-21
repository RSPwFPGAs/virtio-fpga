
    file = $fopen("dma_transaction_for_queue_notify.txt","r");
    if (file == 0)
    begin
        $display("Failed to open dma_transaction_for_queue_notify playback file!");
    end
    
    while (!$feof(file))
    begin
        r = $fscanf(file, " %s %h %h\n", command, data1, data2);
        case (command)
        "rd":
        begin
            debug_trace_rd(data1+32'h`PCIE_BAR_MAP, data2);
            $display("dma_rd mem[%8h] = %8h", data1, data2);
        end
        "wr":
        begin
            debug_trace_wr(data1+32'h`PCIE_BAR_MAP,data2);
            $display("dma_wr mem[%8h] = %8h", data1+32'h`PCIE_BAR_MAP, data2);
        end
        default:
            $display("Trace Playback Unknown command '%0s'", command);
        endcase
    end

    $fclose(file);

