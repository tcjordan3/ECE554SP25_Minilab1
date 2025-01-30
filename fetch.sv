module fetch_module #(
    parameter DATA_WIDTH = 8,         // Data width for the memory and FIFO
    parameter ADDR_WIDTH = 32         // Address width for memory
)(
    input clk,                        // Clock signal
    input rst_n,                      // Active low reset
    input read_mem,                   // Trigger to start reading from memory
    input [ADDR_WIDTH-1:0] address,   // Address for the memory read
    output reg [7:0] fifo_data,       // Data to output for FIFO
    output fetch_done,                // Indicates fetch operation completion
    output waiting
);

  reg [2:0] cnt;
  reg [63:0] fifo_row;

  always_ff @(posedge clk, negedge rst_n) begin
    if(!rst_n) begin
      cnt <= 3'b000;
    end else begin
      cnt <= cnt + 1;
    end
  end

  assign fifo_data = (cnt == 3'b000)? fifo_row[7:0] : (cnt == 3'b001)? fifo_row[15:8] : (cnt == 3'b010)? fifo_row[23:16] :
 		     (cnt == 3'b011)? fifo_row[31:24] : (cnt == 3'b100)? fifo_row[39:32] : (cnt == 3'b101)? fifo_row[47:40] :
		     (cnt == 3'b110)? fifo_row[55:48] : fifo_row[63:56];

  // Memory instantiation (assuming the use of your memory module in memory.v)
  mem_wrapper memory_inst (
        .clk(clk),
        .reset_n(rst_n),
        .address(address),            // Address input for reading from memory
        .read(read_mem),              // Read signal to trigger memory read
        .readdata(fifo_data),         // Output data fetched from memory
        .readdatavalid(fetch_done),   // Signal when data is valid
        .waitrequest(waiting)                // Waitrequest (not used in this example)
    );

endmodule
