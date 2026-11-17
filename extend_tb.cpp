#include "Vextend.h"
#include <iostream>
#include <iomanip>
#include <cstdint>

int main() {
    Vextend top;
    int passed = 0;
    int failed = 0;

    // Tests the output against the expected value
    auto run_test = [&](const char* name,
                        uint32_t instr,
                        int imm_src,
                        uint32_t expected) {

        top.instr = instr;
        top.imm_src = imm_src;
        top.eval();

        uint32_t actual = top.imm_ext;

        std::cout << name << std::endl;
        std::cout << std::hex << std::setfill('0');
        std::cout << "Expected: 0x"
                  << std::setw(8) << expected << std::endl;
        std::cout << "Actual:   0x"
                  << std::setw(8) << actual << std::endl;

        if (actual == expected) {
            std::cout << "PASS\n\n";
            passed++;
        } else {
            std::cout << "FAIL\n\n";
            failed++;
        }
    };

    // Test 1: I-type positive immediate (+5)
    run_test("Test 1: I-type positive",
             0x00500000, 0, 0x00000005);

    // Test 2: I-type negative immediate (-4)
    run_test("Test 2: I-type negative",
             0xFFC00000, 0, 0xFFFFFFFC);

    // Test 3: B-type positive immediate (+8)
    run_test("Test 3: B-type positive",
             0x00000400, 1, 0x00000008);

    // Test 4: B-type negative immediate (-4)
    run_test("Test 4: B-type negative",
             0xFE000E80, 1, 0xFFFFFFFC);

    std::cout << std::dec;
    std::cout << "Tests passed: " << passed << "/4\n";
    std::cout << "Tests failed: " << failed << "/4\n";

    top.final();

    return failed == 0 ? 0 : 1;
}

