`timescale 1ns / 1ps

module tb_apb_protocol;

    localparam addr_width = 32;
    localparam data_width = 32;
    localparam slave_addr_width = 8;
    localparam num_regs = 16;
    localparam clk_period = 10;

    reg pclk = 1'b0;
    reg presetn = 1'b0;

    // Core side signals to drive the master inside the top
    reg valid_core = 1'b0;
    reg [addr_width-1:0] addr_core = {addr_width{1'b0}};
    reg write_core = 1'b0;
    reg [data_width-1:0] wdata_core = {data_width{1'b0}};
    wire ready_core;
    wire [data_width-1:0]   rdata_core;

    wire pslverr;

    // Instantiate top-level APB protocol (master + slave interconnected)
    apb_protocol #(
        .addr_width(addr_width),
        .data_width(data_width),
        .slave_addr_width(slave_addr_width),
        .num_regs(num_regs)
    ) dut (
        .pclk(pclk),
        .presetn(presetn),
        .valid_core(valid_core),
        .addr_core(addr_core),
        .write_core(write_core),
        .wdata_core(wdata_core),
        .ready_core(ready_core),
        .rdata_core(rdata_core),
        .pslverr(pslverr)
    );

    always #(clk_period/2) pclk = ~pclk;

    task apply_reset;
        begin
            presetn = 1'b0;
            repeat (2) @(posedge pclk);
            presetn = 1'b1;
            repeat (2) @(posedge pclk);
        end
    endtask

    task single_write;
        input [addr_width-1:0] addr;
        input [data_width-1:0] data;
        begin
            valid_core = 1'b1;
            addr_core  = addr;
            write_core = 1'b1;
            wdata_core = data;
            @(posedge pclk);
            valid_core = 1'b0;
            while (!ready_core) @(posedge pclk);
            $display("[TB WRITE] Addr: 0x%08h, Data: 0x%08h", addr, data);
        end
    endtask

    task single_read;
        input [addr_width-1:0] addr;
        begin
            valid_core = 1'b1;
            addr_core  = addr;
            write_core = 1'b0;
            @(posedge pclk);
            valid_core = 1'b0;
            while (!ready_core) @(posedge pclk);
            $display("[TB READ]  Addr: 0x%08h, Data: 0x%08h", addr, rdata_core);
        end
    endtask

    initial begin
        $dumpfile("build/apb_protocol_wave.vcd");
        $dumpvars(0, tb_apb_protocol);

        apply_reset();

        // simple sequence
        single_write(32'h0000_0004, 32'hDEAD_BEEF);
        single_read (32'h0000_0004);

        single_write(32'h0000_0008, 32'hCAFEBABE);
        single_read (32'h0000_0008);

        // back-to-back
        valid_core = 1'b1; addr_core = 32'h0000_0010; write_core = 1'b1; wdata_core = 32'h1111_1111; @(posedge pclk);
        valid_core = 1'b1; addr_core = 32'h0000_0014; write_core = 1'b1; wdata_core = 32'h2222_2222; @(posedge pclk);
        valid_core = 1'b1; addr_core = 32'h0000_0010; write_core = 1'b0; @(posedge pclk);
        valid_core = 1'b1; addr_core = 32'h0000_0014; write_core = 1'b0; @(posedge pclk);
        valid_core = 1'b0;
        repeat (8) @(posedge pclk);

        $display("[TB] all transactions done, pslverr = %b", pslverr);

        #20 $finish;
    end

endmodule
