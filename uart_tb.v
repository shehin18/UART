`timescale 1ns/10ps


module uart_tb ();

//testbench uses a 10 MHz clock
//want to interface to 19200 baud UART
//10000000 / 19200 = 521 Clocks Per Bit
parameter CLK_PERIOD = 20; //period of transmitter clock
parameter CLKS_PER_BIT = 521;
parameter BIT_PERIOD = 10416; //time in ns that each bit should be present


reg [7:0] tx_in = 8'h0;
reg i_clk = 0;
reg rx_in;
reg rst_n;

wire tx_out;
wire [7:0] rx_out;

task UART_READ_BYTE; //task to serialize input data
    input [7:0] data;
    integer i;
    begin
      rx_in <= 1'b0; //send start bit
      #(BIT_PERIOD);
      #1000;
       
      for (i=0; i<8; i=i+1)
        begin
          rx_in <= data[i];
          #(BIT_PERIOD);
        end
       
      rx_in <= 1'b1; //send stop bit
      #(BIT_PERIOD);
    end
endtask //UART_READ_BYTE


uart_tx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_TX
        (.rst_n(rst_n),
        .tx_clk(i_clk),
        .tx_in(tx_in),
        .tx_out(tx_out));

uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX
        (.rst_n(rst_n),
        .rx_clk(i_clk),
        .rx_in(rx_in),
        .rx_out(rx_out));

always //generating clock with 50% duty cycle
#(CLK_PERIOD/2) i_clk <= ~i_clk;

// Testbench sequence
initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    rst_n = 0;

    #(CLK_PERIOD * 2);
    rst_n = 1;

    // Test: Send and receive a byte
    UART_READ_BYTE(8'hE3); //send byte 0xE3

    // Wait and check if data received matches
    #(BIT_PERIOD * 10);
    if (rx_out == 8'hE3)
    $display ("Correct data received");
    else
    $display ("Incorrect data received");
    $finish;

end

endmodule