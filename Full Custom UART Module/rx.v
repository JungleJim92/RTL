
module rx(rst,
    sys_clk, // Assumed to be faster than rx_clk
    rx_clk,
    rx_data_in,
    rx_data_out,
    rx_en,
    rx_empty,
    rx_req
    );

input           rst;
input           sys_clk;        
input           rx_clk;
input           rx_data_in;
input           rx_en;
input           rx_req;
output reg  [7:0]   rx_data_out;
output          rx_empty;

reg     [3:0]   rx_cnt;
reg             rx_action;
reg     [7:0]   data_r;
reg     [31:0]  fifo;
reg     [3:0]   valid;
reg     [3:0]   sample_cnt;
reg     [3:0]   sample;
reg             new_data;
reg     [7:0]   fifo_in;
reg             data_read;

wire            voted_bit;

assign rx_empty = ~(valid[0]);
assign voted_bit = (sample > 4'b0011) ? 1'b1 : 1'b0;

always @(posedge rx_clk, negedge rst)
begin
    if(rst == 1'b0)
    begin
        rx_cnt <= 4'b0000;
        rx_action <= 1'b0;
        data_r <= 8'h00;
        sample_cnt <= 4'b0000;
        sample <= 4'b0000;
        new_data <= 1'b0;
        fifo_in <= 8'h00;
    end
    else 
    begin
        if(rx_action == 1'b0)
        begin
            new_data <= 1'b0;
        end
    
        if(rx_action == 1'b0 && rx_data_in == 1'b0 && rst == 1'b1) // START bit
        begin
            rx_action <= 1'b1;
            rx_cnt <= 4'b0000;
            sample_cnt <= 4'b0001;
            sample <= 4'b0000;
        end
        else if(rx_action == 1'b1 && rst == 1'b1)
        begin
            if(sample_cnt != 4'b1000)
            begin
                sample_cnt <= sample_cnt + 1;
                sample <= sample + rx_data_in; // Running sum of samples
            end
            else
            begin
                sample_cnt <= 4'b0001;
                sample <= {3'b000, rx_data_in};
                if(rx_cnt == 4'b1000)
                begin
                    rx_action <= 1'b0;
                    rx_cnt <= 4'b1111;
                    new_data <= 1'b1;
                    fifo_in <= {voted_bit, data_r[7:1]};
                    data_r <= {voted_bit, data_r[7:1]};
                end
                else
                begin
                    rx_cnt <= rx_cnt + 1;
                    data_r <= {voted_bit, data_r[7:1]};
                end
            end
        end
    end
end

always @(posedge sys_clk, negedge rst)
begin
    
    if(rst == 1'b0)
    begin
        fifo <= 32'h0000_0000;
        rx_data_out <= 8'b0000_0000;
        valid <= 4'b0000;
        data_read <= 1'b0;
    end
    else
    begin

        if(new_data == 1'b0 && rst == 1'b1)
        begin
            data_read <= 1'b0;
        end
        
        if(new_data == 1'b1 && data_read == 1'b0 && rst == 1'b1)
        begin
            data_read <= 1'b1;
            if(rx_en == 1'b1 && rx_req == 1'b1)
            begin
                if(valid[0] == 1'b0)
                begin
                    rx_data_out <= fifo_in;
                end
                else if(valid[1] == 1'b0)
                begin
                    fifo[7:0] <= fifo_in;
                    rx_data_out <= fifo[7:0];
                end
                else if(valid[2] == 1'b0)
                begin
                    fifo[15:0] <= {fifo_in, fifo[15:8]};
                    rx_data_out <= fifo[7:0];
                end
                else if(valid[3] == 1'b0)
                begin
                    fifo[23:0] <= {fifo_in, fifo[23:8]};
                    rx_data_out <= fifo[7:0];
                end
                else
                begin
                    fifo[31:0] <= {fifo_in, fifo[31:8]};
                    rx_data_out <= fifo[7:0];
                end
            end
            else 
            begin
                if(valid[0] == 1'b0)
                begin
                    fifo[7:0] <= fifo_in;
                    valid[0] <= 1'b1;
                end
                else if(valid[1] == 1'b0)
                begin
                    fifo[15:8] <= fifo_in;
                    valid[1] <= 1'b1;
                end
                else if(valid[2] == 1'b0)
                begin
                    fifo[23:16] <= fifo_in;
                    valid[2] <= 1'b1;
                end
                else if(valid[3] == 1'b0)
                begin
                    fifo[31:24] <= fifo_in;
                    valid[3] <= 1'b1;
                end
            end
        end
        else if(rst == 1'b1)
        begin
            if(rx_en == 1'b1 && rx_req == 1'b1)
            begin
                rx_data_out <= fifo[7:0];
                fifo <= {8'b0000_0000, fifo[31:8]};
                valid <= {1'b0, valid[3:1]};
            end
        end 
    end
end

endmodule
