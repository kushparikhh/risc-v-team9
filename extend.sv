module extend (
    input  logic [31:0] instr, // 32 bit risc v instruction coming from instruction memory
    input  logic        imm_src, // selects which immediate format to extract - 0 for i-type, 1 for B-type
    output logic [31:0] imm_ext // resulting 32 bit sign extended immediate 
);


always_comb begin
    if(imm_src == 0) begin
        imm_ext = {{20{instr[31]}}, instr[31:20]};
    end

    else begin
        imm_ext = {{20{instr[31]}}, instr[7], instr[30:25], instr[11:8], 1'b0};
    end
end

endmodule
