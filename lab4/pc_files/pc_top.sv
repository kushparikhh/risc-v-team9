module pc_top #(
    parameter WIDTH = 32
    )(
    input  logic clk,
    input  logic rst,
    input  logic pc_src, // from Control Unit (teammate 3)
    input  logic [WIDTH-1:0] imm_op, // from Sign-extend (teammate 3)
    output logic [WIDTH-1:0] pc // to Instr Mem (teammate 3)
);

    logic [WIDTH-1:0] branch_pc;
    logic [WIDTH-1:0] incr_pc;
    logic [WIDTH-1:0] pc_next;
    
    assign branch_pc = pc + imm_op;
    assign incr_pc = pc + 4;
    

    mux #(.WIDTH(WIDTH)) pc_mux (
    .sel (pc_src),
    .in0(incr_pc),
    .in1(branch_pc),
    .out (pc_next)
    );

    pc_reg #(.WIDTH(WIDTH)) pc_register(
        .clk(clk),
        .rst(rst),
        .pc_next(pc_next),
        .pc(pc)
    );

endmodule