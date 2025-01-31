`default_nettype none 
`timescale 1 ns / 1 ns
module minilab_tb();

  ////////////////////////////////////////////////
  // Declare any registers needed for stimulus //
  //////////////////////////////////////////////
  reg clk, rst_n;
  reg [7:0] my_stim;
  
  ///////////////////////////
  // internal connections //
  /////////////////////////
  //logic ;
  
  /////////////////////////////////////////
  // declare wires to hook output up to //
  ///////////////////////////////////////
  //wire [7:0] _out;
  //wire _out;
  
  
  
  //////////////////////
  // Instantiate DUT //
  ////////////////////
  matrixmult iDUT(.rst_n(rst_n), .clk(clk), .Clr(1'b0), .Cout());
  
  
  
  // Error check wire
  logic error;
    
  initial begin
	error = 0;
    clk = 0;
	rst_n = 0;
	
	@(posedge clk);
	@(negedge clk);
	rst_n = 1;			// deassert reset at negedge of clock
	
	// if(init-condition) begin
	// 	$display("ERROR: ");
	// 	error = 1;
	// end
	
	
	// //////////////////////////////////////////////////////
	// // #1 Test Desc
	// ////////////////////////////////////////////////////
	// change_stim = yadayada; 
	
	
	// @(posedge fjakhdkjha); repeat(2) @(negedge clk);
	// if(condition) begin
	// 	$display("ERROR: ");
	// 	error = 1;
	// end
	
	
	
	// ///////////////////////////////////////////////////////////
	// // End
	// /////////////////////////////////////////////////////////
	// repeat(30) @(negedge clk);
	// if(error) begin
	// 	$display("ONE OR MORE ERRORS DETECTED\n");
	// end
	// if(!error) begin
	// 	$display("YAHOO! All tests passed!\n");
	// end
	
	// $stop();
	
  end
  
  always
    #10 clk = ~clk;
	
endmodule

`default_nettype wire