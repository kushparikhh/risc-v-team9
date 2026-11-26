/*
 *  Verifies the results of the reg file, exits with a 0 on success.
 */

#include "base_testbench.h"

Vdut *top;
VerilatedVcdC *tfp;
unsigned int ticks = 0;

class RegFileTestbench : public BaseTestbench
{
protected:
    void initializeInputs() override
    {
        top->clk = 0;
        top->AD1 = 0; 
        top->AD2 = 0;
        top->AD3 = 0;
        top->WD3 = 0; 
        top->WE3 = 0;
        //output RD1, RD2, a0
    }

    void tick()  
    {
        for(int i = 0; i < 2; i++){
            top->clk = !top->clk;
            top->eval();
        }
    }
};

TEST_F(RegFileTestbench, WriteThenReadTest)
{
    // 1. Write 42 into x5
    top->AD3 = 5;
    top->WD3 = 42;
    top->WE3 = 1;
    tick();

    // 2. Read x5 back
    top->WE3 = 0;
    top->AD1 = 5;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 42);
}

TEST_F(RegFileTestbench, WriteEnableIsZeroTest)
{
    // 1. Write 42 into x5 
    top->AD3 = 5;
    top->WD3 = 42;
    top->WE3 = 1;
    tick();
    // 2. Try write 37 into x5 but WE3 = 0
    top->AD3 = 5;
    top->WD3 = 37;
    top->WE3 = 0;
    tick();

    // 3. Read x5 back
    top->WE3 = 0;
    top->AD1 = 5;
    top->eval();

    // 4. Check
    EXPECT_EQ(top->RD1, 42);
}

TEST_F(RegFileTestbench, TwoSimultaneousReadsTest)
{
    // 1. Write 42 into x5
    top->AD3 = 5;
    top->WD3 = 42;
    top->WE3 = 1;
    tick();

    // 2. Write 43 into x6
    top->AD3 = 6;
    top->WD3 = 43;
    top->WE3 = 1;
    tick();

    // 3. Read x5 and x6 at the same time
    top->WE3 = 0;
    top->AD1 = 5;
    top->AD2 = 6;
    top->eval();

    // 4. Check
    EXPECT_EQ(top->RD1, 42);
    EXPECT_EQ(top->RD2, 43);
}

TEST_F(RegFileTestbench, X0AlwaysZeroTest)
{
    // 1. Write 42 into x0
    top->AD3 = 0;
    top->WD3 = 42;
    top->WE3 = 1;
    tick();

    // 2. Read x0 back
    top->WE3 = 0;
    top->AD1 = 0;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 0);
}

TEST_F(RegFileTestbench, CheckingA0Test)
{
    // 1. Write 77 into x10
    top->AD3 = 10;
    top->WD3 = 77;
    top->WE3 = 1;
    tick();
    // 2. Check
    EXPECT_EQ(top->a0, 77);
}

TEST_F(RegFileTestbench, NoWriteBeforeClockTest)
{
    // 1. Write 55 into x20
    top->AD3 = 20;
    top->WD3 = 55;
    top->WE3 = 1;
    
    //2. Read x20 before any clock edge
    top->AD1 = 20;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 0);
}

TEST_F(RegFileTestbench, HighestRegisterTest)
{
    // 1. Write 42 into x31
    top->AD3 = 31;
    top->WD3 = 42;
    top->WE3 = 1;
    tick();

    //2. Read x31
    top->WE3 = 0;
    top->AD1 = 31;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 42);
}

TEST_F(RegFileTestbench, Full32BitValueTest)
{
    // 1. Write 0xFFFFFFFF into x8
    top->AD3 = 8;
    top->WD3 = 0xFFFFFFFF;
    top->WE3 = 1;
    tick();
    
    //2. Read x8
    top->WE3 = 0;
    top->AD1 = 8;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 0xFFFFFFFF);
}

TEST_F(RegFileTestbench, OverwriteTest)
{
    // 1. Write 10 into x13
    top->AD3 = 13;
    top->WD3 = 10;
    top->WE3 = 1;
    tick();

    // 2. Write 20 into x13
    top->WD3 = 20;
    tick();

    // 3. Read x13 back
    top->WE3 = 0;
    top->AD1 = 13;
    top->eval();

    // 4. Check the new value replaced the old
    EXPECT_EQ(top->RD1, 20);
}

TEST_F(RegFileTestbench, SameRegisterBothPortsTest)
{
    // 1. Write 64 into x14
    top->AD3 = 14;
    top->WD3 = 64;
    top->WE3 = 1;
    tick();

    // 2. Read x14 on both ports
    top->WE3 = 0;
    top->AD1 = 14;
    top->AD2 = 14;
    top->eval();

    // 3. Check
    EXPECT_EQ(top->RD1, 64);
    EXPECT_EQ(top->RD2, 64);
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
