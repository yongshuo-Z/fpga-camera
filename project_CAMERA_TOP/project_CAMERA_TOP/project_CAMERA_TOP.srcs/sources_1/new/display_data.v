`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/24 22:26:03
// Design Name: 
// Module Name: display_data
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////
module DISPLAY_DATA(CLK_100MHz, I_Data, O_Data, Bit_ctrl);
    input CLK_100MHz;//ʱ�ӣ���������Ч
    input [7:0]I_Data;//��Ҫ��ʾ������//Ĭ�ϰ�λ
    output [6:0]O_Data;
    output reg[7:0]Bit_ctrl;//λ��
    
    wire w_clk;//��Ƶ���ʱ��
    reg [3:0]temp_disp;//��ʱ��ʾ
    reg flag_set = 0;
    
    //λ��
    always @ (posedge w_clk)
    begin
        if (flag_set)
            begin
            flag_set <= 0;
            Bit_ctrl = 8'b1111_1101;//��ʾ[1]λ
            temp_disp <= {I_Data[7:4]};
            end
        else
            begin
            flag_set <= 1;
            Bit_ctrl = 8'b1111_1110;//��ʾ[0]λ
            temp_disp <= {I_Data[3:0]};
            end
    end
    
    //��ʾ
    display7 DIS_inst(.iData(temp_disp), .oData(O_Data));
    //��Ƶʱ��  
    divider DIV_inst(.I_CLK(CLK_100MHz), .rst(0), .O_CLK(w_clk));
endmodule
