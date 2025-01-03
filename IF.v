`include "lib/defines.vh"
module IF(
    input wire clk, //时钟信号
    input wire rst,  //复位信号             
    input wire [`StallBus-1:0] stall, //一个控制信号，表示流水线是否停顿。

    // input wire flush,
    // input wire [31:0] new_pc,

    input wire [`BR_WD-1:0] br_bus,  //分支相关信号，包含分支是否发生 (br_e) 和分支目标地址 (br_addr)。

    output wire [`IF_TO_ID_WD-1:0] if_to_id_bus,

    output wire inst_sram_en,
    output wire [3:0] inst_sram_wen,
    output wire [31:0] inst_sram_addr,
    output wire [31:0] inst_sram_wdata
);
    reg [31:0] pc_reg;
    reg ce_reg;   //ce_reg 是一个控制信号，表示 IF 阶段是否有效
    wire [31:0] next_pc;
    wire br_e;
    wire [31:0] br_addr;

    assign {
        br_e,
        br_addr
    } = br_bus;


    always @ (posedge clk) begin
        if (rst) begin
            pc_reg <= 32'hbfbf_fffc;
        end
        else if (stall[0]==`NoStop) begin
            pc_reg <= next_pc;
        end
    end

    always @ (posedge clk) begin
        if (rst) begin
            ce_reg <= 1'b0;
        end
        else if (stall[0]==`NoStop) begin
            ce_reg <= 1'b1;
        end
    end


    assign next_pc = br_e ? br_addr : pc_reg + 32'h4;
    //如果 br_e 为高（分支发生），则将 next_pc 设置为 br_addr，即跳转到分支目标地址。
    //否则，next_pc 就是当前 PC 加 4，即顺序执行下一条指令。

    
    assign inst_sram_en = ce_reg;
    assign inst_sram_wen = 4'b0;
    assign inst_sram_addr = pc_reg;
    assign inst_sram_wdata = 32'b0;
    assign if_to_id_bus = {
        ce_reg,
        pc_reg
    };

endmodule