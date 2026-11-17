//Kept general so it can be reused throughout project
module mux #(
    parameter WIDTH = 32
) (
    input logic sel,
    input logic [WIDTH-1:0] in0, //Selected when sel = 0
    input logic [WIDTH-1:0] in1, //Selected when sel = 1 
    output logic [WIDTH-1:0] out
);
    
    assign out = sel ? in1:in0; 
    
endmodule