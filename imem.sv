module imem (
    input  logic [31:0] pc,
    output logic [31:0] instr
);

logic [7:0] memory [0:1023];
logic [31:0] index;

initial begin
    $readmemh("program.hex", memory);
end

assign index = pc - 32'hBFC00000;
assign instr = {memory[index + 3], memory[index + 2], memory[index + 1], memory[index]};


endmodule