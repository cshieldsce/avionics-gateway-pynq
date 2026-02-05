module can_filter (
    input              clk,           // Added for compatibility
    input              rst_n,         // Added for compatibility (active low)
    
    input      [10:0]  id_in,
    input              id_valid_in,
    
    input      [10:0]  accept_code,
    input      [10:0]  accept_mask,
    
    output reg         id_valid_out,
    output reg [10:0]  id_out
);

    // Synchronous process
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            id_valid_out <= 1'b0;
            id_out       <= 11'b0;
        end else begin
            if (id_valid_in && ((id_in & accept_mask) == (accept_code & accept_mask))) begin
                id_valid_out <= 1'b1;
                id_out       <= id_in;
            end else begin
                id_valid_out <= 1'b0;
                id_out       <= 11'b0;
            end
        end
    end

endmodule