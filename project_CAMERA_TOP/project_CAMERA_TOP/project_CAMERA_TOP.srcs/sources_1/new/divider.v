`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/24 22:28:52
// Design Name: 
// Module Name: divider
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
module divider(I_CLK, rst, O_CLK);
    input I_CLK;//����ʱ���źţ���������Ч
    input rst;//ͬ����λ�źţ��ߵ�ƽ��Ч
    output O_CLK;//���ʱ��
    //
    parameter multiple = 500000;//�궨���Ƶ����=multiple*2
    reg O_CLK = 0;
    integer i = 0;//������
    
    always @ (posedge I_CLK)
    begin
        if (rst == 1)
            begin
            i <= 0;
            O_CLK <= 0;
            end
        else if (i >= multiple)
            begin
            i <= 1;
            O_CLK <= ~O_CLK;
            end
        else
            begin
            i <= i + 1;
            end
    end
endmodule
