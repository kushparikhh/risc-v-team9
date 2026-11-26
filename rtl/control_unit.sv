
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

    logic [1:0] ALUOp;   // decoder to ALU decoder
    logic       Branch;  // beq, bne
    logic       Jump;    // jal, jalr

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
        //loading instruction (lw and lbu)
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


// ALU decoder
// ALUOp come from main decoder and tell what type instruction it is
// if Register or int typee then funct3 decide the actual operation
always_comb
    case (ALUOp)
        2'b00:   ALUControl = 4'b0000;          // add, load and store need it for address, jalr for jump target
        2'b01:   ALUControl = 4'b0001;          // sub, for beq and bne we subtract rs1 and rs2 so Zero is 1 when they same

        2'b10:                                  // R-type and I-type, need check funct3 for operation
            case (funct3)
                3'b000:  if (op[5] == 1'b1 && funct7b5 == 1'b1)
                             ALUControl = 4'b0001;      // sub, op[5] only 1 for R-type so addi with negative imm dont become sub
                         else
                             ALUControl = 4'b0000;    // add or addi
                3'b001:  ALUControl = 4'b0101;        // shift left logical, sll or slli
                3'b010:  ALUControl = 4'b1000;        // set less than (signed), slt or slti
                3'b011:  ALUControl = 4'b1001;        // set less than unsigned, sltu or sltiu
                3'b100:  ALUControl = 4'b0100;        // xor or xori
                3'b101:  if (funct7b5 == 1'b1)
                             ALUControl = 4'b0111;    // shift right arithmetic, keep sign bit, sra or srai
                         else
                             ALUControl = 4'b0110;    // shift right logical, fill zero, srl or srli
                3'b110:  ALUControl = 4'b0011;        // or or ori
                3'b111:  ALUControl = 4'b0010;        // and or andi
                default: ALUControl = 4'b0000;        // funct3 not used so just add
            endcase
        default: ALUControl = 4'b0000;       
                 // ALUOp not used so just add
    endcase
    


// PC source logic which decides where next instruction is from
// jalr check first because it set Jump too but need use ALU result
always_comb
    if (op == 7'b1100111)
        PCSrc = 2'b10;        // jalr, go to rs1 + imm which ALU already calculate
    else if (Jump == 1'b1)
        PCSrc = 2'b01;       // jal, go to PC + imm from the target adder
    else if (Branch == 1'b1 && funct3 == 3'b000 && Zero == 1'b1)
        PCSrc = 2'b01;       // beq taken when rs1 equal rs2 so ALU give zero
    else if (Branch == 1'b1 && funct3 == 3'b001 && Zero == 1'b0)
        PCSrc = 2'b01;       // bne taken when rs1 not equal rs2 so ALU not zero
    else
        PCSrc = 2'b00;        // normal case, go to PC + 4
 

endmodule