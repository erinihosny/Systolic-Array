module SystolicArray #(
    parameter N = 3,   // N x N input
    parameter M = 2,  // K x K filter
    parameter data_width = 1
) (
    input  logic clk,
    input  logic reset,
    input  logic [data_width-1:0] A [0:N-1][0:N-1], // 2D input
    input  logic [data_width-1:0] B [0:M-1][0:M-1],          // 2D filter
    output logic [2*data_width:0] P [0:N-M][0:N-M]
);
    localparam OUTPUT_SIZE = N - M + 1;
    localparam CYCLES = M * M;
	 
    
    logic [$clog2(CYCLES)-1:0] cycle;
    logic [data_width-1:0] b;
    logic [2*data_width:0] partial_sums [0:OUTPUT_SIZE-1][0:OUTPUT_SIZE-1];
    
    // Cycle counter
    always_ff @(posedge clk or posedge reset) begin
        if (reset) cycle <= 0;
        else cycle <= (cycle == CYCLES-1) ? 0 : cycle + 1;
    end

    // Fetch weight based on cycle
    always_comb begin
        automatic logic [$clog2(M)-1:0] m = cycle / M;
        automatic logic [$clog2(M)-1:0] n = cycle % M;
        b = B[m][n];
    end

    // Generate PEs and input routing
	 genvar i, j;
    generate
        for (i = 0; i < OUTPUT_SIZE; i++) begin : row
            for (j = 0; j < OUTPUT_SIZE; j++) begin : col
                logic [data_width-1:0] a;
                
                // Calculate input index
                always_comb begin
                    automatic logic [$clog2(M)-1:0] m = cycle / M;
                    automatic logic [$clog2(M)-1:0] n = cycle % M;
                    a = A[i + m][j + n]; // 2D access
                end

                PE #(.data_width(data_width)) pe (
                    .clk(clk),
                    .reset(reset),
                    .a(a),
                    .b(b),   // Use the shared weight
                    .p(partial_sums[i][j])
                );
            end
        end
    // Copy output grid to output feature map at the end of all cycles
    always_ff @(posedge clk or posedge reset) begin
        if (reset) begin
            for (int i = 0; i < OUTPUT_SIZE; i++)
                for (int j = 0; j < OUTPUT_SIZE; j++)
                    P[i][j] <= 0;
        end else if (cycle == 0) begin
            for (int i = 0; i < OUTPUT_SIZE; i++)
                for (int j = 0; j < OUTPUT_SIZE; j++)
                    P[i][j] <= partial_sums[i][j];
        end
    end
    endgenerate
endmodule