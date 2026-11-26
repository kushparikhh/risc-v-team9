module reg_file #(
    parameter ADDRESS_WIDTH = 5,
              DATA_WIDTH    = 32
)(
    input  logic                     clk,   
    input  logic [ADDRESS_WIDTH-1:0] A1,   
    input  logic [ADDRESS_WIDTH-1:0] A2,    
    input  logic [ADDRESS_WIDTH-1:0] A3,   
    input  logic [DATA_WIDTH-1:0]    WD3,   
    input  logic                     WE3,   
    output logic [DATA_WIDTH-1:0]    RD1,   
    output logic [DATA_WIDTH-1:0]    RD2,   
    output logic [DATA_WIDTH-1:0]    a0     
);

    //creating 32 registers with a 32 bit address
    logic [DATA_WIDTH-1:0] reg_array [2**ADDRESS_WIDTH-1:0];

    always_ff @(posedge clk) begin
        if (WE3 == 1'b1)
            reg_array[A3] <= WD3;
    end

    assign RD1 = (A1 == 5'd0) ? 32'b0 : reg_array[A1];
    assign RD2 = (A2 == 5'd0) ? 32'b0 : reg_array[A2];

    //This is always sent to the top module
    assign a0  = reg_array[5'd10];

endmodule