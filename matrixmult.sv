`default_nettype none 
`timescale 1 ns / 1 ns

module matrixmult(
    input wire clk,
    input wire rst_n,
    input wire Clr,
    output logic [23:0] Cout0,
    output logic [23:0] Cout1,
    output logic [23:0] Cout2,
    output logic [23:0] Cout3,
    output logic [23:0] Cout4,
    output logic [23:0] Cout5,
    output logic [23:0] Cout6,
    output logic [23:0] Cout7,
    output logic [1:0] curr_state
);
	///////////////////////////////////////////////
	//
	//USE vsim work.minilab_tb -L C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_mf -voptargs="+acc" !!!!!!!
	//
	///////////////////////////////////////////

    logic [23:0] Cout [7:0];
    reg [7:0] Ain [7:0];
    reg [7:0] Bin [7:0];
    reg En[7:0];
    reg full[8:0];
    reg empty[8:0];
    reg [3:0] count;
    reg [3:0] statecount;
    reg read_mem;
    reg [7:0] Afill [8:0];
    reg wren[8:0];
    reg [7:0] fetchout;
    reg fetch_done;
    reg waiting;
    genvar i;
    reg [3:0] address;
    reg [7:0] Bin_flopped [7:0];
    reg [3:0] statecount_tmp;
    reg [3:0] address_tmp;

    generate
        for (i = 0; i < 8; ++i) begin : MAC_gen
            MAC imac(.clk(clk), .rst_n(rst_n), .En(En[i]), .Clr(Clr), .Ain(Ain[i]), .Bin(Bin[i]), .Cout(Cout[i]));
        end
    endgenerate

    /**
    always_ff @(posedge clk, negedge rst_n) begin
	if(!rst_n) begin
	    for(int j = 0; j < 8; j++) begin
		Bin_flopped[j] <= '0;
	    end
	end else begin
	    Bin_flopped[0] <= Bin[0];
	    for (int j = 1; j < 8; j++) begin
		Bin_flopped[j] <= Bin_flopped[j-1];
	    end
	end
    end
    **/

    // fifos for A
    genvar k;
    generate
        for (k = 0; k < 8; ++k) begin : FIFO_gen
            FIFO ififo(.clk(clk), .rst_n(rst_n), .rden(En[k]), .wren(wren[k + 1]), .i_data(Afill[k + 1]), .o_data(Ain[k]), .full(full[k + 1]), .empty(empty[k + 1]));
        end
    endgenerate

    fetch_module iFETCH(.clk(clk), .rst_n(rst_n), .read_mem(read_mem), .address(address), .fifo_data(fetchout), .fetch_done(fetch_done), .waiting(waiting));

    // fifo for B
    FIFO fifob(.clk(clk), .rst_n(rst_n), .rden(En[0]), .wren(wren[0]), .i_data(Afill[0]), .o_data(Bin[0]), .full(full[0]), .empty(empty[0]));

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            En[0] <= 1'b0;
	    count <= 4'h0;
        end
        else begin
            if (full[8] & (~empty[1])) begin
                En[0] <= 1'b1;
	        count <= count + 1;
	    end
            else if (count > 7) begin
                En[0] <= 1'b0;
		count <= '0;
	    end
        end
    end

    genvar j;
    generate
        for (j = 1; j < 8; ++j) begin : EN_gen
            always_ff @(posedge clk, negedge rst_n) begin
                if(~rst_n) begin
                    En[j] <= 1'b0;
                    Bin[j] <= 8'h00;
                end
                else begin
                    En[j] <= En[j-1];
                    Bin[j] <= Bin[j-1];
                end
            end
        end
    endgenerate
	
    typedef enum reg [1:0] {IDLE, GET, FILL, DONE} state_t;
    
        state_t state, nxt_state;

    
        // Next state and reset logic
        always_ff @(posedge clk, negedge rst_n) begin
            if(!rst_n) begin
                state <= IDLE;
		statecount <= '0;
		address <= '0;
            end
            else begin
                state <= nxt_state;
		statecount <= statecount_tmp;
		address <= address_tmp;
            end
        end
    
    
        // State transitions (input/outputs)
        always_comb begin
    
            // default nxt_state and outputs
            nxt_state = state;
            read_mem = 0;
				statecount_tmp = statecount;
				address_tmp = address;
        
            case(state)
                IDLE: begin
                    nxt_state = GET;
                    read_mem = 1'b1;
                    statecount_tmp = '0;
                    address_tmp = 1;
                end
                GET: begin
                    read_mem = 1'b0;
                    if (fetch_done)
                        nxt_state = FILL;
                end
                FILL: begin
                    if(full[8]) begin
                        nxt_state = DONE;
			wren[statecount] = 1'b0;
		    end
                    else if(full[statecount]) begin
                        nxt_state = GET;
                        read_mem = 1'b1;
			wren[statecount] = 1'b0;
                        statecount_tmp = statecount + 1;
                        address_tmp = statecount_tmp + 1;
                    end
                    else
                        wren[statecount] = 1'b1;
                        Afill[statecount] = fetchout;
                end
                DONE: begin
                    nxt_state = DONE;
					end
                
            endcase
        end


    assign Cout0 = Cout[0];
    assign Cout1 = Cout[1];
    assign Cout2 = Cout[2];
    assign Cout3 = Cout[3];
    assign Cout4 = Cout[4];
    assign Cout5 = Cout[5];
    assign Cout6 = Cout[6];
    assign Cout7 = Cout[7];
    assign curr_state = state;
endmodule

`default_nettype wire
