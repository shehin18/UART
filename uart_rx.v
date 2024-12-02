//CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
//10 MHz Clock, 19200 baud UART
//(10000000)/(19200) = 521

module uart_rx
#(parameter CLKS_PER_BIT = 521)
  (rx_in, rst_n, rx_clk, rx_out);

input rx_in; //data input
input rst_n; //reset
input rx_clk; //clock signal
output [7:0] rx_out; //8 bit data output

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA_BURST = 2'b10;
parameter STOP = 2'b11;

reg [7:0] data = 8'h0; //to store the incoming data
reg [7:0] rx_count = 8'h0;
reg [3:0] bitpos = 4'h0;
reg [1:0] rx_state = IDLE;

reg R1, R2; //two stage synchronizer

always @(posedge rx_clk or negedge rst_n) begin
    if(!rst_n) begin
    rx_count = 8'h0;
    bitpos = 4'h0;
    rx_state = IDLE;
    data = 8'h0;
    end
    else begin  
    R1 <= rx_in;
    R2 <= R1;

    case (rx_state)
    
    IDLE : begin
        R2 = 1'b1;
        bitpos = 4'h0;
        rx_count = 8'h0;

        if(R2 == 1'b0) //start bit received
            rx_state = START;
        else
            rx_state = IDLE;
    end //IDLE

    START : begin
        if (rx_count == (CLKS_PER_BIT - 1)/2) begin
            if (R2 == 1'b0) begin //making sure that start bit 0 is received
                rx_count = 8'h0;
                rx_state = DATA_BURST;
            end
            else
            rx_state = IDLE;
        end
        else begin
            rx_count = rx_count + 1; //increment till mid-point of data bit reached ((CLKS_PER_BIT-1)/2)
            rx_state = START;
        end
    end //START

    DATA_BURST : begin
        if(rx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles to sample serial data
            rx_count = rx_count + 1;
            rx_state = DATA_BURST;
        end
        else begin
            rx_count = 8'h0;
            data[bitpos] = R2;
            if (bitpos < 3'h7) begin //check if all bits are received
                bitpos = bitpos + 1;
                rx_state = DATA_BURST;
            end
            else begin
                bitpos = 4'h0;
                rx_state = STOP;
            end
        end
    end //DATA_BURST

    STOP : begin
        if(rx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles for stop bit to finish
            rx_count = rx_count + 1;
            rx_state = STOP;
        end
        else begin
            rx_count = 8'h0;
            rx_state = IDLE;
        end
    end //STOP
    endcase
    end
end

assign rx_out = data;

endmodule
