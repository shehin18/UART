`timescale 1ns/10ps

module uart_rx_tb;

//testbench uses a 10 MHz clock
//want to interface to 19200 baud UART
//10000000 / 19200 = 521 Clocks Per Bit
parameter CLK_PERIOD = 20; //period of transmitter clock
parameter CLKS_PER_BIT = 521;
parameter BIT_PERIOD = 10416; //time in ns that each bit should be present

reg rx_clk = 0;
reg rx_in = 1;
reg rst_n = 1;

wire [7:0] rx_out;

task UART_WRITE_BYTE; //task to serialize input data
input [7:0] data;
    integer i;
    begin
      rx_in = 1'b0; //start bit
      #(BIT_PERIOD);
       
      for (i=0; i<8; i=i+1)
        begin
          rx_in = data[i];
          #(BIT_PERIOD);
        end
       
      rx_in = 1'b1; //stop bit
      #(BIT_PERIOD);
    end
endtask //UART_WRITE_BYTE

uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX
        (.rst_n(rst_n),
        .rx_clk(rx_clk),
        .rx_in(rx_in),
        .rx_out(rx_out));

always #(CLK_PERIOD/2) rx_clk = ~rx_clk; //generating clock with 50% duty cycle

// Testbench sequence
initial begin
    $dumpfile("dump.vcd");
    $dumpvars;

    //reset
    rst_n = 0;
    #(CLK_PERIOD * 2);
    rst_n = 1;

    // Wait for reset release
    @(posedge rx_clk);

    UART_WRITE_BYTE(8'hE3); //send byte 0xE3

    // Wait and check if data received matches
    @(posedge rx_clk);
    if (rx_out == 8'hE3)
    $display ("Correct data received : %h", rx_out);
    else
    $display ("Incorrect data received : %h", rx_out);
    $finish();
    end

endmodule