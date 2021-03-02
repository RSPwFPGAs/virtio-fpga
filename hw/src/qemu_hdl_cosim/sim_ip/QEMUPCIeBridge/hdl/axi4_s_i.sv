
`timescale 1ns/100ps
module axi4_s_i
#(
    parameter   TAGW            = 3
,               ADRW            = 32
,               DATW            = 256
,               SIZE            = 3'b010        // always refer to DATW
,               STBW            = (DATW/8)
,               DTMP            = 4096
)
(
    input                       i_clk
,   input                       i_rst_n

//INTERRUPT
,   input                       intx_msi_request
,   output                      interrupt_out
,   output                      intx_msi_grant
);

    import "DPI-C" function void     C_req_interrupt(input int vector);

    // virtual msix request
    reg       intx_msi_request_virtual = 0;
    reg [1:0] intx_msi_request_number  = 2'b00;

    always@(posedge intx_msi_request_virtual or posedge intx_msi_request)
    begin: INTR
        C_req_interrupt(intx_msi_request_number);
    end

    assign interrupt_out = 0;
    assign intx_msi_grant = 0;

endmodule
