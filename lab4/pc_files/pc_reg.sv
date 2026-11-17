module pc_reg #(
    parameter WIDTH = 32
)
(
    input logic clk,
    input logic rst,
    input logic [WIDTH-1:0] pc_next,
    output logic [WIDTH-1:0] pc
);

    always_ff @(posedge clk, posedge rst) begin
        if (rst) pc_next <= '0;
        else pc <= pc_next;
    end

endmodule
