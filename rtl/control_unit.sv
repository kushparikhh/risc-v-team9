
module control_unit (
    input  logic [6:0] op,          // opcode [6:0]
    input  logic [2:0] funct3,      //[14:12]
    input  logic       funct7b5,    // Although funct7 is 7 bits only bit 5 is needed to identify instruction
    input  logic       Zero,        // Signal from ALU for 
    output logic [1:0] PCSrc,       // Address of next instruction
    output logic [1:0] ResultSrc,   // Which value is written into register (ALU/Upper Immediate?)
    output logic       MemWrite,    // data memory write enable
    output logic [3:0] ALUControl,  // ALU operations
    output logic       ALUSrc,      // Alu read operand (Reg/Imm)
    output logic [2:0] ImmSrc,      // sign extend type
    output logic       RegWrite     // register write enable
);

    logic [1:0] ALUOp;   // main decoder to ALU decoder
    

always_comb begin
    // default values 
    RegWrite  = 1'b0;
    ImmSrc    = 3'b000;
    ALUSrc    = 1'b0;
    MemWrite  = 1'b0;
    ResultSrc = 2'b00;
    Branch    = 1'b0;
    Jump      = 1'b0;
    ALUOp     = 2'b00;

    case (op)
        //loading instructions (lw and lbu)
        7'b0000011: begin           
            RegWrite  = 1'b1;
            ALUSrc    = 1'b1;
            ResultSrc = 2'b01;
        end
        //storing instruction (sw, sb)
        7'b0100011: begin          
            ImmSrc    = 3'b001;
            ALUSrc    = 1'b1;
            MemWrite  = 1'b1;
        end
        //Register ALU instructions
        7'b0110011: begin          
            RegWrite  = 1'b1;
            ALUOp     = 2'b10;
        end
        //Immediate ALU Instructions
        7'b0010011: begin          
            RegWrite  = 1'b1;
            ALUSrc    = 1'b1;
            ALUOp     = 2'b10;
        end
        //Branch Instruction (beq, bne)
        7'b1100011: begin           
            ImmSrc    = 3'b010;
            Branch    = 1'b1;
            ALUOp     = 2'b01;
        end
        //Jump and link instruction (jal)
        7'b1101111: begin           
            RegWrite  = 1'b1;
            ImmSrc    = 3'b011;
            ResultSrc = 2'b10;
            Jump      = 1'b1;
        end
        //Jump and link register instruction (jalr)
        7'b1100111: begin           
            RegWrite  = 1'b1;
            ALUSrc    = 1'b1;
            ResultSrc = 2'b10;
            Jump      = 1'b1;
        end
        //loading upper immediate instruction (lui)
        7'b0110111: begin           
            RegWrite  = 1'b1;
            ImmSrc    = 3'b100;
            ResultSrc = 2'b11;
        end
        //default case for unknown OP
        default:    RegWrite = 1'b0;    
    endcase
end


endmodule