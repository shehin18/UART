//CLKS_PER_BIT = (Frequency of i_Clock)/(Frequency of UART)
//10 MHz Clock, 19200 baud UART
//(10000000)/(19200) = 521

module uart_rx
#(parameter CLKS_PER_BIT = 521)
  (rx_in, rst_n, rx_clk, rx_out);

input wire rx_in, rst_n; //data input
input wire rx_clk; //clock signal
output reg [7:0] rx_out; //8 bit data output

parameter IDLE = 2'b00;
parameter START = 2'b01;
parameter DATA_BURST = 2'b10;
parameter STOP = 2'b11;

reg data = 1'b0; //to store the incoming data
reg [7:0] rx_count = 0;
reg [3:0] bitpos = 4'h0;
reg [1:0] rx_state = IDLE;

//double register approach to avoid metastability
reg R1;
  always @(posedge rx_clk or negedge rst_n) begin
    if(!rst_n)
    rx_count <= 0;
    bitpos <= 0;
    rx_state <= IDLE;
    rx_out <= 0;
    data <= 1;
    end
    else begin  
    R1 <= rx_in;
    data <= R1;
    end    
    
    case (rx_state)
    
    IDLE : begin
        data <= 1;
        bitpos <= 0;
        rx_count <= 0;

        if(data == 1'b0) //start bit received
            rx_state <= START;
        else
            rx_state <= IDLE;
    end //IDLE

    START : begin
        if (rx_count == (CLKS_PER_BIT - 1)/2) begin
            if (data == 1'b0) begin //making sure that start bit 0 is received
                rx_count <= 0;
                rx_state <= DATA_BURST;
            end
            else
            rx_state <= IDLE;
        end
        else begin
            rx_count <= rx_count + 1; //increment till mid-point of data bit reached ((CLKS_PER_BIT-1)/2)
            rx_state <= START;
        end
    end //START

    DATA_BURST : begin
        if(rx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles to sample serial data
            rx_count <= rx_count + 1;
            rx_state <= DATA_BURST;
        end
        else begin
            rx_count <= 0;
            rx_out[bitpos] <= data;
            if (bitpos < 3'h7) begin //check if all bits are received
                bitpos <= bitpos + 1'b1;
                rx_state <= DATA_BURST;
            end
            else begin
                bitpos <= 0;
                rx_state <= STOP;
            end
        end
    end //DATA_BURST

    STOP : begin
        if(rx_count < CLKS_PER_BIT - 1) begin //wait CLKS_PER_BIT-1 clock cycles for stop bit to finish
            rx_count <= rx_count + 1;
            rx_state <= STOP;
        end
        else begin
            rx_count <= 0;
            rx_state <= IDLE;
        end
    end //STOP
    endcase
end

endmodule
