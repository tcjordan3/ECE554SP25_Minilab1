`timescale 1ps/1ps

// vsim work.minilab_tb -L C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_mf -voptargs="+acc"

module minilab_tb();

    // Clock generation
    logic clk;
    initial begin
        clk = 0;
        forever #5 clk = ~clk;
    end

    // Test signals
    logic rst_n;
    logic Clr;
    wire [23:0] Cout0;
    wire [23:0] Cout1;
    wire [23:0] Cout2;
    wire [23:0] Cout3;
    wire [23:0] Cout4;
    wire [23:0] Cout5;
    wire [23:0] Cout6;
    wire [23:0] Cout7;
    wire [23:0] Cout [7:0];

    // Instantiate DUT
    matrixmult DUT(
        .clk(clk),
        .rst_n(rst_n),
        .Clr(1'b0),
        .Cout0(Cout[0]),
	.Cout1(Cout[1]),
	.Cout2(Cout[2]),
	.Cout3(Cout[3]),
	.Cout4(Cout[4]),
	.Cout5(Cout[5]),
	.Cout6(Cout[6]),
	.Cout7(Cout[7]),
	.curr_state()
    );

    // Monitor internal signals
    string state_string;
    always_comb begin
        case(DUT.state)
            2'b00: state_string = "IDLE";
            2'b01: state_string = "GET";
            2'b10: state_string = "FILL";
            2'b11: state_string = "DONE";
            default: state_string = "UNKNOWN";
        endcase
    end

    // Test stimulus
    initial begin
        // Set up waveform dumping
        // $dumpfile("minilab_tb.vcd");
        // $dumpvars(0, minilab_tb);

        // Initialize signals
        rst_n = 0;
        Clr = 0;
        
        // Wait a few clock cycles and release reset
        repeat(3) @(posedge clk);
        rst_n = 1;
        
        // Monitor key signals
        $display("Time\tState\t\tCount\tStatecount");
        $monitor("%0t\t%s\t%0d\t%0d", 
                 $time, 
                 state_string,
                 DUT.count,
                 DUT.statecount);

        // Wait for filling of FIFOs
        wait(DUT.state == DUT.FILL);
        $display("\nFIFO filling started at time %0t", $time);

        // Wait for computation to complete
        wait(DUT.state == DUT.DONE);
        $display("\nComputation completed at time %0t", $time);

        // Add additional checks for FIFO states
        $display("\nFinal FIFO States:");
        for(int i = 0; i < 9; i++) begin
            $display("FIFO[%0d]: full=%b, empty=%b", 
                    i, 
                    DUT.full[i],
                    DUT.empty[i]);
        end

	/**

        // Test reset during operation
        repeat(50) @(posedge clk);
        rst_n = 0;
        $display("\nAsserting reset at time %0t", $time);
        repeat(3) @(posedge clk);
        rst_n = 1;
        $display("Releasing reset at time %0t", $time);

        // Wait for second computation
        wait(DUT.state == DUT.DONE);
        $display("\nSecond computation completed at time %0t", $time);

        // Run for a while longer to ensure stability
        repeat(100) @(posedge clk);
        
        $display("\nSimulation completed at time %0t", $time);
        $finish;
    end

    **/
	#1000;

	// Display final results
        $display("\nFinal Results:");
        for(int i = 0; i < 8; i++) begin
            $display("Cout[%0d] = %h", i, DUT.Cout[i]);
        end

	$stop;
    end

    // Timeout watchdog
    initial begin
        #100000 // Adjust timeout value as needed
        $display("Simulation timeout at time %0t", $time);
        $finish;
    end

    /**

    // Additional monitoring and checks
    property reset_clears_signals;
        @(posedge clk) 
        !rst_n |-> ##1 (DUT.count == 0 && DUT.state == DUT.IDLE);
    endproperty
    assert property(reset_clears_signals) 
    else $error("Reset did not clear signals properly");

    // Monitor Enable signals progression
    always @(posedge clk) begin
        if (DUT.En[0] && !$isunknown(DUT.En)) begin
            $display("Time %0t: Enable signals: %b", 
                    $time, 
                    DUT.En);
        end
    end

    // Check for proper FIFO operation
    always @(posedge clk) begin
        if (DUT.state == DUT.FILL) begin
            for(int i = 0; i < 9; i++) begin
                if (DUT.full[i] && DUT.empty[i]) begin
                    $error("FIFO %0d is both full and empty!", i);
                end
            end
        end
    end

    **/

endmodule