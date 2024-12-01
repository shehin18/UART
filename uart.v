module uart
(rst_n, d_in, tx_clk, rx_clk, rx_in, tx_out, d_out);

input rst_n; //reset
input [7:0] d_in; //8-bit data input
input tx_clk; //clock signal
input rx_clk; //clock signal
input rx_in; //serial-in

output reg tx_out; //serial-out
output reg [7:0] d_out; //8 bit data output

uart_tx TX (.rst_n(rst_n),
            .tx_in(d_in),
            .tx_clk(tx_clk),
            .tx_out(tx_out));

uart_rx RX (.rst_n(rst_n),
            .rx_in(rx_in),
            .rx_clk(rx_clk),
            .rx_out(d_out));
    
    
endmodule