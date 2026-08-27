module apb_master_rw #(
    parameter addr_width = 32,
    parameter data_width = 32
)(
    input wire pclk,
    input wire presetn,

    input wire valid_core,
    input wire [addr_width-1:0] addr_core,
    input wire write_core,
    input wire [data_width-1:0] wdata_core,
    output reg ready_core,
    output reg [data_width-1:0] rdata_core,

    output reg [addr_width-1:0] paddr,
    output reg psel,
    output reg penable,
    output reg pwrite,
    output reg [data_width-1:0] pwdata,
    input wire [data_width-1:0] prdata,
    input wire pready
);

    localparam idle   = 2'b00;
    localparam setup  = 2'b01;
    localparam access = 2'b10;

    reg [1:0] state;

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state      <= idle;
            paddr      <= {addr_width{1'b0}};
            psel       <= 1'b0;
            penable    <= 1'b0;
            pwrite     <= 1'b0;
            pwdata     <= {data_width{1'b0}};
            ready_core <= 1'b0;
            rdata_core <= {data_width{1'b0}};
        end else begin
            case (state)
                idle: begin
                    psel       <= 1'b0;
                    penable    <= 1'b0;
                    ready_core <= 1'b0;

                    if (valid_core) begin
                        paddr      <= addr_core;
                        pwrite     <= write_core;
                        pwdata     <= write_core ? wdata_core : {data_width{1'b0}};
                        psel       <= 1'b1;
                        penable    <= 1'b0;
                        state      <= setup;
                    end else begin
                        state      <= idle;
                    end
                end

                setup: begin
                    psel       <= 1'b1;
                    penable    <= 1'b0;
                    ready_core <= 1'b0;
                    state      <= access;
                end

                access: begin
                    psel       <= 1'b1;
                    penable    <= 1'b1;
                    ready_core <= 1'b0;

                    if (pready) begin
                        if (!pwrite) begin
                            rdata_core <= prdata;
                        end
                        ready_core <= 1'b1;

                        if (valid_core) begin
                            paddr      <= addr_core;
                            pwrite     <= write_core;
                            pwdata     <= write_core ? wdata_core : {data_width{1'b0}};
                            psel       <= 1'b1;
                            penable    <= 1'b0;
                            state      <= setup;
                        end else begin
                            psel       <= 1'b0;
                            penable    <= 1'b0;
                            state      <= idle;
                        end
                    end else begin
                        state      <= access;
                    end
                end

                default: begin
                    state      <= idle;
                    psel       <= 1'b0;
                    penable    <= 1'b0;
                    ready_core <= 1'b0;
                end
            endcase
        end
    end
endmodule
