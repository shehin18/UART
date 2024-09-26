module uart
(d_in, tx_clk, wr_en, tx_out, rx_in, rx_clk, d_out);

input wire [7:0] d_in; //8-bit data input
input wire wr_en; //enable signal
input wire tx_clk; //clock signal
output reg tx_out; //output data
input wire rx_in; //data input
input wire rx_clk; //clock signal
output reg [7:0] d_out; //8 bit data output

uart_tx TX (.tx_in(d_in),
            .tx_en(wr_en),
            .tx_clk(tx_clk),
            .tx_out(tx_out));

uart_rx RX (.rx_in(rx_in),
            .rx_clk(rx_clk),
            .rx_out(d_out));
    
    
endmodule