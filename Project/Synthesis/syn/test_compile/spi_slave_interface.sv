module spi_slave_interface #(
    parameter integer WIDTH = 16
)(
    input  logic clk,               // System clock
    input  logic rst,               // Reset

    // SPI lines
    input  logic sclk,             // SPI clock
    input  logic cs_n,             // Active-low chip select
    input  logic mosi,             // Master out, slave in
    output logic miso,             // Master in, slave out

    // Register interface
    output logic wr_en,                            // Write enable (1 cycle pulse)
    output logic [15:0] addr,                      // Address
    output logic signed [WIDTH-1:0] wr_data,       // Write data
    input  logic signed [WIDTH-1:0] rd_data        // Read data (from register file)
);

    typedef enum logic [1:0] {
        IDLE,
        SHIFT_IN,
        SHIFT_OUT
    } spi_state_t;

    spi_state_t state, next_state;

    logic [5:0] bit_count;
    logic [31:0] shift_reg;          
    logic [WIDTH-1:0] read_buffer;   

    // SCLK synchronizer and edge detection
    logic [1:0] sclk_sync;
    logic sclk_rising, sclk_falling;

    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            sclk_sync <= 2'b00;
        end else begin
            sclk_sync <= {sclk_sync[0], sclk};
        end
    end

    assign sclk_rising  = (sclk_sync == 2'b01);
    assign sclk_falling = (sclk_sync == 2'b10);

    // FSM: state register
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            state <= IDLE;
        end else begin
            state <= next_state;
        end
    end

    // FSM: next state logic
    always_comb begin
        next_state = state;
        case (state)
            IDLE: begin
                if (!cs_n) begin
                    next_state = SHIFT_IN;
                end
            end
            SHIFT_IN: begin
                if (bit_count == 6'd32) begin
                    next_state = SHIFT_OUT;
                end
            end
            SHIFT_OUT: begin
                if (cs_n) begin
                    next_state = IDLE;
                end
            end
            default: begin
                next_state = IDLE;
            end
        endcase
    end

    // Shift register input logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            shift_reg <= 32'd0;
            bit_count <= 6'd0;
        end else if (cs_n) begin
            shift_reg <= 32'd0;
            bit_count <= 6'd0;
        end else if (state == SHIFT_IN) begin
            if (sclk_rising) begin
                shift_reg <= {shift_reg[30:0], mosi};
                bit_count <= bit_count + 1;
            end
        end else if (state != SHIFT_IN) begin
            bit_count <= 6'd0;
        end
    end

    // Write logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            wr_en   <= 1'b0;
            addr    <= 16'd0;
            wr_data <= '0;
        end else begin
            wr_en <= 1'b0; // default

            if (state == SHIFT_IN && bit_count == 6'd32) begin
                addr    <= shift_reg[30:16];
                wr_data <= shift_reg[15:0];

                if (!shift_reg[31]) begin // Write command
                    wr_en <= 1'b1;
                end
            end
        end
    end

    // Read buffer logic
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            read_buffer <= '0;
        end else begin
            if (state == SHIFT_IN && bit_count == 6'd32 && shift_reg[31]) begin
                read_buffer <= rd_data;
            end else if (state == SHIFT_OUT && sclk_falling) begin
                read_buffer <= {read_buffer[WIDTH-2:0], 1'b0};
            end
        end
    end

    // Output logic for MISO
    always_ff @(posedge clk or posedge rst) begin
        if (rst) begin
            miso <= 1'b0;
        end else begin
            if (state == SHIFT_OUT && shift_reg[31]) begin
                miso <= read_buffer[WIDTH-1];
            end else begin
                miso <= 1'b0;
            end
        end
    end

endmodule

