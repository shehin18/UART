//CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
//10 MHz Clock, 19200 baud UART
//(10000000)/(19200) = 521

module uart_tx
#(parameter CLKS_PER_BIT = 521)
(tx_in, rst_n, tx_clk, tx_out);

input [7:0] tx_in; //8-bit data input
input rst_n; //reset
input tx_clk; //clock signal
output reg tx_out; //output data

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA_BURST = 2'b10;
parameter STOP = 2'b11;

reg [7:0] data = 8'h0; //to store the incoming 8-bit data
reg [7:0] tx_count = 8'h0;
reg [3:0] bitpos = 4'h0;
reg [1:0] tx_state = IDLE;


always @(posedge tx_clk or negedge rst_n;) begin
  if(!rst_n) begin
  tx_out <= 1'b1;
  tx_count <= 8'h0;
  bitpos <= 4'h0;
  tx_state <= IDLE;
  end
  else begin
    data <= tx_in;

    case (tx_state)
    
    IDLE : begin
        tx_out <= 1;
        bitpos <= 0;
        tx_count <= 0;

        if(tx_out == 1'b0) //start bit received
            tx_state <= START;
        else
            tx_state <= IDLE;
    end //IDLE

    START : begin
        tx_out <= 1'b0; //send out start bit
        if(tx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles for start bit to finish
            tx_count <= tx_count + 1;
            tx_state <= START;
        end
        else begin
            tx_count <= 0;
            tx_state <= DATA_BURST;
        end
    end //START

    DATA_BURST : begin
        tx_out <= data[bitpos];
        if(tx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles to finish
            tx_count <= tx_count + 1;
            tx_state <= DATA_BURST;
        end
        else begin
            tx_count <= 0;
            if (bitpos < 3'h7) begin //check if all 8 bits are received
                bitpos <= bitpos + 1'b1;
                tx_state <= DATA_BURST;
            end
            else begin //all bits sent
                bitpos <= 0;
                tx_state <= STOP;
            end
        end
    end //DATA_BURST

    STOP : begin
        tx_out <= 1'b1; //stop bit 1
        if(tx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles for stop bit to finish
            tx_count <= tx_count + 1;
            tx_state <= STOP;
        end
        else begin
            tx_count <= 0;
            tx_state <= IDLE;
        end
    end //STOP
    endcase
    end
end

endmodule
