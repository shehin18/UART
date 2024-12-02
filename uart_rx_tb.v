`timescale 1ns/10ps

module uart_rx_tb;

// Parameters
parameter CLK_PERIOD = 20;            // 10 MHz clock period (20 ns)
parameter CLKS_PER_BIT = 521;         // 19200 baud (10000000 / 19200)
parameter BIT_PERIOD = 10416;         // Bit period in ns (1 / 19200)

// Signals
reg rx_clk = 0;
reg rx_in = 1;
wire [7:0] rx_out;

// Instantiate the UART receiver
uart_rx #(.CLKS_PER_BIT(CLKS_PER_BIT)) UART_RX (
    .rx_clk(rx_clk),
    .rx_in(rx_in),
    .rx_out(rx_out)
);

// Clock generation
always #(CLK_PERIOD / 2) rx_clk = ~rx_clk;

// Task to send a byte serially
task UART_WRITE_BYTE(input [7:0] data);
    integer i;
    begin
        rx_in <= 1'b0;                 // Start bit
        #(BIT_PERIOD);
        
        for (i = 0; i < 8; i = i + 1) begin
            rx_in <= data[i];          // Data bits
            #(BIT_PERIOD);
        end
        
        rx_in <= 1'b1;                 // Stop bit
        #(BIT_PERIOD);
    end
endtask

// Test sequence
initial begin
    $dumpfile("dump.vcd");
    $dumpvars(0, uart_rx_tb);

    // Wait for a few clock cycles after reset
    #(CLK_PERIOD * 5);

    // Send a byte (0xE3)
    UART_WRITE_BYTE(8'hE3);

    // Wait for the receiver to process the byte (assuming full reception)
    #(BIT_PERIOD * 11);               // 1 start + 8 data + 1 stop + buffer

    // Check received data
    if (rx_out == 8'hE3)
        $display("Correct data received: %h", rx_out);
    else
        $display("Incorrect data received: %h", rx_out);

    $finish;
end

endmodule
