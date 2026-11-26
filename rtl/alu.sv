module alu #(
    parameter REG_WIDTH = 32
                )(
        input logic [REG_WIDTH-1:0] ALUop1,
        input logic [REG_WIDTH-1:0] ALUop2,
        input logic [3:0]           ALUctrl,
        output logic[REG_WIDTH-1:0] ALUout,
        output logic EQ
    );

    always_comb begin

        ALUout = 32'b0;
        EQ = (ALUop1 == ALUop2);

       case(ALUctrl)
       4'b0000: ALUout = ALUop1 + ALUop2; //add
       4'b0001: ALUout = ALUop1 - ALUop2; //sub
       4'b0010: ALUout = ALUop1 & ALUop2; //and
       4'b0011: ALUout = ALUop1 | ALUop2; //or
       4'b0100: ALUout = ALUop1 ^ ALUop2; //xor
       4'b0101: ALUout = ALUop1 << ALUop2[4:0]; //lsl
       4'b0110: ALUout = ALUop1 >> ALUop2[4:0]; //lsr
       4'b0111: ALUout = $signed(ALUop1) >>> ALUop2[4:0]; //asr
       4'b1000: ALUout = {31'b0, $signed(ALUop1) < $signed(ALUop2)}; //slt
       4'b1001: ALUout = {31'b0, ALUop1 < ALUop2}; //sltu

       default: begin
            ALUout = 32'b0;
       end
       endcase

    end
        

endmodule
