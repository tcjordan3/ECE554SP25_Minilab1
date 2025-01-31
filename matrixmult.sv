`default_nettype none 
`timescale 1 ns / 1 ns

module matrixmult(
    input wire clk,
    input wire rst_n,
    input wire Clr,
	output logic [23:0] Cout [7:0]
);
	///////////////////////////////////////////////
	//
	//USE vsim work.minilab_tb -L C:/intelFPGA_lite/23.1std/questa_fse/intel/verilog/altera_mf -voptargs="+acc" !!!!!!!
	//
	///////////////////////////////////////////
	
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
    generate
        for (i = 0; i < 8; ++i) begin
            MAC imac(.clk(clk), .rst_n(rst_n), .En(En[i]), .Clr(Clr), .Ain(Ain[i]), .Bin(Bin[i]), .Cout(Cout[i]));
        end
    endgenerate

    // fifos for A
    genvar k;
    generate
        for (k = 1; k < 9; ++k) begin
            FIFO ififo(.clk(clk), .rst_n(rst_n), .rden(En[k - 1]), .wren(wren[k]), .i_data(Afill[k]), .o_data(Ain[k - 1]), .full(full[k]), .empty(empty[k]));
        end
    endgenerate

    fetch_module iFETCH(.clk(clk), .rst_n(rst_n), .read_mem(read_mem), .address(address), .fifo_data(fetchout), .fetch_done(fetch_done), .waiting(waiting));

    // fifo for B
    FIFO fifob(.clk(clk), .rst_n(rst_n), .rden(En[0]), .wren(wren[0]), .i_data(Afill[0]), .o_data(Bin[0]), .full(full[0]), .empty(empty[0]));

    // always_ff @(posedge clk, negedge rst_n) begin
    //     if(~rst_n) begin
    //         En[0] <= 1'b0;
    //         Bin[0] <= 8'h00;
    //         Ain[0] <= 8'h00;
    //         En[1] <= 1'b0;
    //         Bin[1] <= 8'h00;
    //         Ain[1] <= 8'h00;
    //         En[2] <= 1'b0;
    //         Bin[2] <= 8'h00;
    //         Ain[2] <= 8'h00;
    //         En[3] <= 1'b0;
    //         Bin[3] <= 8'h00;
    //         Ain[3] <= 8'h00;
    //         En[4] <= 1'b0;
    //         Bin[4] <= 8'h00;
    //         Ain[4] <= 8'h00;
    //         En[5] <= 1'b0;
    //         Bin[5] <= 8'h00;
    //         Ain[5] <= 8'h00;
    //         En[6] <= 1'b0;
    //         Bin[6] <= 8'h00;
    //         Ain[6] <= 8'h00;
    //         En[7] <= 1'b0;
    //         Bin[7] <= 8'h00;
    //         Ain[7] <= 8'h00;
    //         count = 4'h0;
    //     end
    //     else if(Enable) begin
    //         if(count < 8)
    //             En[0] <= Enable;
    //         else
    //             En[0] <= 1'b0;
    //         Ain[0] <= Amatrix[0][count];
    //         Bin[0] <= Bvector[count];
    //         En[1] <= En[0];
    //         Bin[1] <= Bin[0];
    //         Ain[1] <= Amatrix[1][count - 1];
    //         En[2] <= En[1];
    //         Bin[2] <= Bin[1];
    //         Ain[2] <= Amatrix[2][count - 2];
    //         En[3] <= En[2];
    //         Bin[3] <= Bin[2];
    //         Ain[3] <= Amatrix[3][count - j];
    //         En[4] <= En[3];
    //         Bin[4] <= Bin[3];
    //         Ain[4] <= Amatrix[4][count - j];
    //         En[5] <= En[4];
    //         Bin[5] <= Bin[4];
    //         Ain[5] <= Amatrix[5][count - j];
    //         En[6] <= En[5];
    //         Bin[6] <= Bin[5];
    //         Ain[6] <= Amatrix[6][count - j];
    //         En[7] <= En[6];
    //         Bin[7] <= Bin[6];
    //         Ain[7] <= Amatrix[7][count - j];
    //         count <= count + 1;
    //     end
    // end

    always_ff @(posedge clk, negedge rst_n) begin
        if(~rst_n) begin
            En[0] <= 1'b0;
	    count <= 4'h0;
            // Bin[0] <= 8'h00;
            // Ain[0] <= 8'h00;
        end
        else begin
            if (full[7])
                En[0] <= 1'b1;
            else if (count > 7)
                En[0] <= 1'b0;
            // Ain[0] <= Amatrix[0][count];
            // Bin[0] <= Bvector[count];
            count <= count + 1;
        end
    end

    genvar j;
    generate
        for (j = 1; j < 8; ++j) begin
            always_ff @(posedge clk, negedge rst_n) begin
                if(~rst_n) begin
                    En[j] <= 1'b0;
                    Bin[j] <= 8'h00;
                    // Ain[j] <= 8'h00;
                end
                else begin
                    En[j] <= En[j-1];
                    Bin[j] <= Bin[j-1];
                    // Ain[j] <= Amatrix[j][count - j];
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
            end
            else begin
                state <= nxt_state;
            end
        end
    
    
        // State transitions (input/outputs)
        always_comb begin
    
            // default nxt_state and outputs
            nxt_state = state;
            read_mem = 0;
        
            case(state)
                IDLE: begin
                    nxt_state = GET;
                    read_mem = 1'b1;
                    statecount = '0;
                    address = '0;
                end
                GET: begin
                    read_mem = 1'b0;
                    if (fetch_done)
                        nxt_state = FILL;
                end
                FILL: begin
                    if(full[8])
                        nxt_state = DONE;
                    else if(full[statecount]) begin
                        nxt_state = GET;
                        read_mem = 1'b1;
                        statecount = statecount + 1;
                        address = statecount;
                        wren[statecount] = 1'b0;
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

endmodule

`default_nettype wire
