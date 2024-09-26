`timescale 1ns/10ps

//`include "uart_tx.v"
//`include "uart_tx.v"

module uart_tb ();

//testbench uses a 10 MHz clock
//want to interface to 19200 baud UART
//10000000 / 19200 = 521 Clocks Per Bit
parameter CLK_PERIOD = 20; //period of transmitter clock
parameter CLKS_PER_BIT = 521;
parameter BIT_PERIOD = 10416; //time in ns that each bit should be present


reg [7:0] tx_in = 0;
reg tx_en = 0;
reg i_clk = 0;
wire tx_out;
reg rx_in;
wire [7:0] rx_out;

task UART_WRITE_BYTE; //task to serialize input data
    input [7:0] i_data;
    integer i;
    begin
      tx_in <= 1'b0; //send start bit
      #(BIT_PERIOD);
      #1000;
       
      for (i=0; i<8; i=i+1)
        begin
          tx_in <= i_data[i];
          #(BIT_PERIOD);
        end
       
      tx_in <= 1'b1; //send stop bit
      #(BIT_PERIOD);
    end
endtask //UART_WRITE_BYTE

uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX
        (.tx_clk(i_clk),
        .tx_en(tx_en),
        .tx_in(tx_in),
        .tx_out(tx_out));

uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX
        (.rx_clk(i_clk),
        .rx_in(rx_in),
        .rx_out(rx_out));

always //generating clock with 50% duty cycle
#(CLK_PERIOD/2) i_clk <= ~i_clk;

initial begin
    @(posedge i_clk);
    tx_en <= 1'b1;
    tx_in <= 8'hBD;
    @(posedge i_clk);
    tx_en <= 1'b0;

    @(posedge i_clk);
    UART_WRITE_BYTE(8'hE3);

    @(posedge i_clk);
    if (rx_out == 8'hE3)
    $display ("Correct data received");
    else
    $display ("Incorrect data received");


end


endmodule