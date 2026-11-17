module alu #(
    parameter REG_WIDTH = 32,
                )(
        input logic [REG_WIDTH-1:0] ALUop1,
        input logic [REG_WIDTH-1:0] ALUop2,
        input logic ALUctrl,
        output logic [REG_WIDTH-1:0] ALUout,
        output logic EQ
    );

    always_comb begin

        ALUout = 32'b0;
        EQ = 1'b0;

       case(ALUctrl)
       1'b0: ALUout = ALUop1 + ALUop2;
       1'b1: EQ = (ALUop1 == ALUop2);
       default: begin
            ALUout = 32'b0;
            EQ = 1'b0;
       end
       endcase

    end
        

endmodule
