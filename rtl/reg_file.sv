module reg_file #(
    parameter  REG_WIDTH = 32,
                REG_ADDR = 5)(
        input logic clk,
        input logic [REG_ADDR-1:0] AD1,
        input logic [REG_ADDR-1:0] AD2,
        input logic [REG_ADDR-1:0] AD3,
        input logic [REG_WIDTH-1:0] WD3,
        input logic WE3,
        output logic [REG_WIDTH-1:0] RD1,
        output logic [REG_WIDTH-1:0] RD2,
        output logic [REG_WIDTH-1:0] a0
    );

    logic [REG_WIDTH-1:0] reg_val [2**REG_ADDR-1:0];

    always_comb begin
        RD1 = reg_val[AD1];
        RD2 = reg_val[AD2];
        a0 = reg_val[5'd10];
    end

    always_ff @(negedge clk)begin
        if(WE3) begin
            reg_val[AD3] <= WD3;
        end
    
    end
         
endmodule

