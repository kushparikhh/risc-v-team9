/*
 *  Verifies the results of the ALU, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class AluTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->ALUop1 = 0;
        top->ALUop2 = 0;
        top->ALUctrl = 0;
        // output: ALUout, EQ
    }
};

TEST_F(AluTestbench, AddWorksTest)
{
    top->ALUop1 = 5;
    top->ALUop2 = 3;
    top->ALUctrl = 0b0000;   // add
    top->eval();
    EXPECT_EQ(top->ALUout, 8);
}

TEST_F(AluTestbench, SubWorksTest)
{
    top->ALUop1 = 10;
    top->ALUop2 = 4;
    top->ALUctrl = 0b0001;   // sub
    top->eval();
    EXPECT_EQ(top->ALUout, 6);
}

TEST_F(AluTestbench, AndWorksTest)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 0b0010;   // and
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1000);
}

TEST_F(AluTestbench, OrWorksTest)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 0b0011;   // or
    top->eval();
    EXPECT_EQ(top->ALUout, 0b1110);
}

TEST_F(AluTestbench, XorWorksTest)
{
    top->ALUop1 = 0b1100;
    top->ALUop2 = 0b1010;
    top->ALUctrl = 0b0100;   // xor
    top->eval();
    EXPECT_EQ(top->ALUout, 0b0110);
}

TEST_F(AluTestbench, SllWorksTest)
{
    top->ALUop1 = 5;
    top->ALUop2 = 3;
    top->ALUctrl = 0b0101;   // lsl
    top->eval();
    EXPECT_EQ(top->ALUout, 40);
}

TEST_F(AluTestbench, SrlWorksTest)
{
    top->ALUop1 = 40;
    top->ALUop2 = 3;
    top->ALUctrl = 0b0110;   // srl
    top->eval();
    EXPECT_EQ(top->ALUout, 5);
}

TEST_F(AluTestbench, SraWorksTest)
{
    top->ALUop1 = 0xFFFFFFF0;   // -16
    top->ALUop2 = 2;
    top->ALUctrl = 0b0111;      // sra
    top->eval();
    EXPECT_EQ(top->ALUout, 0xFFFFFFFC);   // -4
}

TEST_F(AluTestbench, SltWorksTest)
{
    top->ALUop1 = 3;
    top->ALUop2 = 8;
    top->ALUctrl = 0b1000;   // slt
    top->eval();
    EXPECT_EQ(top->ALUout, 1);
}

TEST_F(AluTestbench, SltuWorksTest)
{
    top->ALUop1 = 3;
    top->ALUop2 = 8;
    top->ALUctrl = 0b1001;   // sltu
    top->eval();
    EXPECT_EQ(top->ALUout, 1);
}

TEST_F(AluTestbench, EqWhenEqualTest)
{
    top->ALUop1 = 7;
    top->ALUop2 = 7;
    top->eval();
    EXPECT_EQ(top->EQ, 1);
}

TEST_F(AluTestbench, EqWhenNotEqualTest)
{
    top->ALUop1 = 7;
    top->ALUop2 = 8;
    top->eval();
    EXPECT_EQ(top->EQ, 0);
}

TEST_F(AluTestbench, SltVsSltuNegativeTest)
{
    top->ALUop1 = 0xFFFFFFFF;   // -1 signed, huge unsigned
    top->ALUop2 = 1;

    top->ALUctrl = 0b1000;      // slt: -1 < 1
    top->eval();
    EXPECT_EQ(top->ALUout, 1);

    top->ALUctrl = 0b1001;      // sltu: huge < 1
    top->eval();
    EXPECT_EQ(top->ALUout, 0);
}

TEST_F(AluTestbench, LsrVsAsrNegativeTest)
{
    top->ALUop1 = 0xFFFFFFF0;   // -16
    top->ALUop2 = 2;

    top->ALUctrl = 0b0110;      // lsr fills with 0s
    top->eval();
    EXPECT_EQ(top->ALUout, 0x3FFFFFFC);

    top->ALUctrl = 0b0111;      // asr keeps the sign
    top->eval();
    EXPECT_EQ(top->ALUout, 0xFFFFFFFC);
}

TEST_F(AluTestbench, AddOverflowWrapsTest)
{
    top->ALUop1 = 0xFFFFFFFF;
    top->ALUop2 = 1;
    top->ALUctrl = 0b0000;      // add
    top->eval();
    EXPECT_EQ(top->ALUout, 0);
}

TEST_F(AluTestbench, ShiftUsesLow5BitsTest)
{
    top->ALUop1 = 1;
    top->ALUop2 = 33;           // only the bottom 5 bits (1) count
    top->ALUctrl = 0b0101;      // lsl
    top->eval();
    EXPECT_EQ(top->ALUout, 2);
}

int main(int argc, char **argv)
{
    top = new Vdut;
    tfp = new VerilatedVcdC;

    Verilated::traceEverOn(true);
    top->trace(tfp, 99);
    tfp->open("waveform.vcd");

    testing::InitGoogleTest(&argc, argv);
    auto res = RUN_ALL_TESTS();

    top->final();
    tfp->close();

    delete top;
    delete tfp;

    return res;
}
