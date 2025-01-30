module fetch_module #(
    parameter DATA_WIDTH = 8,         // Data width for the memory and FIFO
    parameter ADDR_WIDTH = 32         // Address width for memory
)(
    input clk,                        // Clock signal
    input rst_n,                      // Active low reset
    input read_mem,                   // Trigger to start reading from memory
    input [ADDR_WIDTH-1:0] address,   // Address for the memory read
    output reg [63:0] fifo_data, // Data to output for FIFO
    output fetch_done,                // Indicates fetch operation completion
    output waiting
);

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
