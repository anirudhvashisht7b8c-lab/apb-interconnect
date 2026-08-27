module apb_slave #(
    parameter addr_width = 8,
    parameter data_width = 32,
    parameter num_regs = 16
)(
    input wire pclk,
    input wire presetn,

    input wire psel,
    input wire penable,
    input wire pwrite,
    input wire [addr_width-1:0] paddr,
    input wire [data_width-1:0] pwdata,

    output reg [data_width-1:0] prdata,
    output reg pready,
    output reg pslverr
);

    localparam idle   = 1'b0;
    localparam access = 1'b1;

    reg state;
    reg [data_width-1:0] mem [0:num_regs-1];
    integer i;

    always @(posedge pclk or negedge presetn) begin
        if (!presetn) begin
            state    <= idle;
            pready   <= 1'b0;
            pslverr  <= 1'b0;
            prdata   <= {data_width{1'b0}};

            for (i = 0; i < num_regs; i = i + 1) begin
                mem[i] <= {data_width{1'b0}};
            end
        end else begin
            case (state)
                idle: begin
                    pready  <= 1'b0;
                    pslverr <= 1'b0;

                    if (psel && !penable) begin
                        state <= access;
                    end else begin
                        state <= idle;
                    end
                end

                access: begin
                    if (psel && penable) begin
                        if (pwrite) begin
                            if (paddr < num_regs) begin
                                mem[paddr] <= pwdata;
                            end else begin
                                pslverr <= 1'b1;
                            end
                        end else begin
                            if (paddr < num_regs) begin
                                prdata <= mem[paddr];
                            end else begin
                                prdata <= {data_width{1'b0}};
                                pslverr <= 1'b1;
                            end
                        end

                        pready <= 1'b1;
                        state  <= idle;
                    end else begin
                        pready <= 1'b0;
                        state  <= access; // remain in access until penable is asserted
                    end
                end

                default: begin
                    state   <= idle;
                    pready  <= 1'b0;
                    pslverr <= 1'b0;
                end
            endcase
        end
    end
endmodule
