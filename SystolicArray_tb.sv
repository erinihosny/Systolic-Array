module SystolicArray_tb #(
    parameter N = 3,
    parameter M = 2,
    parameter data_width = 1
);
    logic clk, reset;
    logic [data_width-1:0] A [0:N-1][0:N-1];
    logic [data_width-1:0] B [0:M-1][0:M-1];
    logic [2*data_width:0] P [0:N-M][0:N-M];

    SystolicArray #(
        .N(N),
        .M(M),
        .data_width(data_width)
    ) DUT (.*);

    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    initial begin
        // Initialize 3x3 input
        A = '{
            '{1, 1, 1}, 
            '{1, 1, 0}, 
            '{0, 1, 0}
        };
        // Initialize 2x2 filter
        B = '{
            '{1, 1}, 
            '{1, 1}
        };
        
        reset = 1;
        #10 reset = 0;
        #((M*M+1)*10);
        $display("Final Product:");
        for (int i = 0; i < N-M+1; i++) begin
            $write("[");
            for (int j = 0; j < N-M+1; j++) begin
                $write("%4d", P[i][j]);
                if (j != N-M) $write(", ");
            end
            $display("]");
        end
        $finish;
    end
endmodule