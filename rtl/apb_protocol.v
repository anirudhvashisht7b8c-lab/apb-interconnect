module apb_protocol #(
    parameter addr_width = 32,
    parameter data_width = 32,
    parameter slave_addr_width = 8,
    parameter num_regs = 16
)(
    input wire pclk,
    input wire presetn,

    // Core interface (master-facing)
    input wire valid_core,
    input wire [addr_width-1:0] addr_core,
    input wire write_core,
    input wire [data_width-1:0] wdata_core,
    output wire ready_core,
    output wire [data_width-1:0] rdata_core,

    output wire pslverr
);

    //signals (from master to slave)
    wire [addr_width-1:0] paddr_w;
    wire psel_w;
    wire penable_w;
    wire pwrite_w;
    wire [data_width-1:0] pwdata_w;
    wire [data_width-1:0] prdata_w;
    wire pready_w;

    // Instantiate APB master (core interface -> APB signals)
    apb_master_rw #(
        .addr_width(addr_width),
        .data_width(data_width)
    ) master_inst (
        .pclk(pclk),
        .presetn(presetn),
        .valid_core(valid_core),
        .addr_core(addr_core),
        .write_core(write_core),
        .wdata_core(wdata_core),
        .ready_core(ready_core),
        .rdata_core(rdata_core),
        .paddr(paddr_w),
        .psel(psel_w),
        .penable(penable_w),
        .pwrite(pwrite_w),
        .pwdata(pwdata_w),
        .prdata(prdata_w),
        .pready(pready_w)
    );

    apb_slave #(
        .addr_width(slave_addr_width),
        .data_width(data_width),
        .num_regs(num_regs)
    ) slave_inst (
        .pclk(pclk),
        .presetn(presetn),
        .psel(psel_w),
        .penable(penable_w),
        .pwrite(pwrite_w),
        .paddr(paddr_w[slave_addr_width-1:0]),
        .pwdata(pwdata_w),
        .prdata(prdata_w),
        .pready(pready_w),
        .pslverr(pslverr)
    );

endmodule
