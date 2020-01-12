`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 19:13:31
// Design Name: 
// Module Name: VGA
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
//����VGAģ��
module VGA(CLK_25MH, RST_n, Pix_Data, Pix_Addr, Vsync_s, Hsync_s, R_s, G_s, B_s);
    input CLK_25MH;//ʱ���źš�25MHz����������Ч
    input RST_n;//��λ�źţ��͵�ƽ��Ч
    input [11:0]Pix_Data;//ͼƬ���������ݣ�12λ
    output [18:0]Pix_Addr;//���ص�ַ
    output Vsync_s;//��ͬ���ź�
    output Hsync_s;//��ͬ���ź�
    output [3:0]R_s;//����ɫ�ź�
    output [3:0]G_s;//����ɫ�ź�
    output [3:0]B_s;//����ɫ�ź�
    
    //����ģ��֮�������
    wire ready_s;//��Ч������ʾ��
    wire [10:0]row;//������
    wire [10:0]col;//������

    //ʵ����ͬ������ģ��
    SYNC sync_inst(
        .CLK(CLK_25MH), 
        .RST_n(RST_n), 
        .Vsync_s(Vsync_s), 
        .Hsync_s(Hsync_s), 
        .Ready_s(ready_s), 
        .Col_s(col), 
        .Row_s(row)
    );
    //ʵ����VGA����ģ��
    CONTROL control_inst(
        .CLK(CLK_25MH), 
        .RST_n(RST_n), 
        .Ready_s(ready_s), 
        .Col_s(col), 
        .Row_s(row), 
        .Rom_addr(Pix_Addr),
        .Rom_data(Pix_Data), 
        .R_s(R_s), 
        .G_s(G_s), 
        .B_s(B_s)
    );

endmodule
