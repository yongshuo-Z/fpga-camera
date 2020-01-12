`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 22:01:24
// Design Name: 
// Module Name: CONTROL
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
//VGA����ģ��
module CONTROL(CLK, RST_n, Ready_s, Col_s, Row_s, Rom_addr, Rom_data, R_s, G_s, B_s);//Rom_addr, 
    input CLK;//ʱ���źţ���������Ч
    input RST_n;//��λ�źţ��͵�ƽ��Ч
    input Ready_s;//��Ч�����ź�
    input [10:0]Col_s;//�������ź�
    input [10:0]Row_s;//�������ź�    
    output [18:0]Rom_addr;//��Ӧͼ��ĵ�ַ��19λ
    input [11:0]Rom_data;//һ��ͼ�����ء�12λ
    output [3:0]R_s;//����ɫ�ź�
    output [3:0]G_s;//����ɫ�ź�
    output [3:0]B_s;//����ɫ�ź�
    
    //�궨�����
    parameter p_rowmin = 11'd0;//��������С�߽�
    parameter p_rowmax = 11'd480 ;//���������߽� 480 
    parameter p_colmin = 11'd0;//��������С�߽�
    parameter p_colmax = 11'd640;//���������߽�640  
    
    reg r_pic_ready;//ͼƬ��ʾ��Χ
    
    /*����Ч�����źŽ��и�ֵ*/
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)
            r_pic_ready <= 1'b0;//��λ
        else if ((Col_s >= p_colmin && Col_s < p_colmax) && (Row_s >= p_rowmin && Row_s < p_rowmax))
            //���о���ʵ����ʾ�ķ�Χ��
            r_pic_ready <= 1'b1;//������ʾ
        else //��������ʾ����
            r_pic_ready <= 1'b0;//���ֲ���ʾ
    end
    
    /*������źŽ��п���*/
    assign Rom_addr = Row_s*p_colmax + Col_s;//�����ַ
    assign R_s[0] = (Ready_s && r_pic_ready) ? Rom_data[11] : 1'b0;//��
    assign R_s[1] = (Ready_s && r_pic_ready) ? Rom_data[10] : 1'b0;//��
    assign R_s[2] = (Ready_s && r_pic_ready) ? Rom_data[9] : 1'b0;//��
    assign R_s[3] = (Ready_s && r_pic_ready) ? Rom_data[8] : 1'b0;//��
    assign G_s[0] = (Ready_s && r_pic_ready) ? Rom_data[7] : 1'b0;//��
    assign G_s[1] = (Ready_s && r_pic_ready) ? Rom_data[6] : 1'b0;//��
    assign G_s[2] = (Ready_s && r_pic_ready) ? Rom_data[5] : 1'b0;//��
    assign G_s[3] = (Ready_s && r_pic_ready) ? Rom_data[4] : 1'b0;//��
    assign B_s[0] = (Ready_s && r_pic_ready) ? Rom_data[3] : 1'b0;//��
    assign B_s[1] = (Ready_s && r_pic_ready) ? Rom_data[2] : 1'b0;//��
    assign B_s[2] = (Ready_s && r_pic_ready) ? Rom_data[1] : 1'b0;//��
    assign B_s[3] = (Ready_s && r_pic_ready) ? Rom_data[0] : 1'b0;//��

endmodule