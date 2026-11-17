module control (
    input  logic [6:0] opcode,
    input  logic [2:0] funct3,
    input  logic       equal, // when registers are equal, this is 1

    output logic       reg_write,
    output logic       alu_src,
    output logic       imm_src,
    output logic       branch,
    output logic       alu_ctrl,
    output logic       pc_src
);

always_comb begin 

    reg_write = 0;
    alu_src   = 0;
    imm_src   = 0;
    branch    = 0;
    alu_ctrl  = 0;

    if (opcode == 7'b0010011 && funct3 == 3'b000) begin
        reg_write = 1;
        alu_src = 1;
    end

    else if (opcode == 7'b1100011 && funct3 == 3'b001) begin 
        imm_src = 1;
        alu_ctrl = 1;
        branch = 1;

    end
end

assign pc_src = branch && !equal;

endmodule
// ALUctrl outputs 0 for add instruction and 1 for compare instruction