`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/12 19:13:57
// Design Name: 
// Module Name: SYNC
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
/*����ͬ������ģ��*/
module SYNC(CLK, RST_n, Vsync_s, Hsync_s, Ready_s, Col_s, Row_s);
    input CLK;//ʱ���źţ���������Ч
    input RST_n;//��λ�źţ��͵�ƽ��Ч
    output Vsync_s;//��ͬ���ź�
    output Hsync_s;//��ͬ���ź�
    output Ready_s;//��Ч�����ź�
    output [10:0]Col_s;//�������ź�
    output [10:0]Row_s;//�������ź�
    
    /*�ֱ��ʣ�640*480*/
    parameter p_Hmaxsize = 11'd800;//��ʵ���������
    parameter p_Vmaxsize = 11'd525;//��ʵ���������
    parameter p_Hreal_minsize = 11'd144;//ʵ����ʾ��������ʹ�
    parameter p_Hreal_maxsize = 11'd785;//ʵ����ʾ��������ߴ�
    parameter p_Vreal_minsize = 11'd35;//ʵ����ʾ��������ʹ�
    parameter p_Vreal_maxsize = 11'd515;//ʵ����ʾ��������ߴ�
    parameter p_Hsyncsize = 11'd96;//��ͬ������ʱ��Χ
    parameter p_Vsyncsize = 11'd2;//��ͬ������ʱ��Χ
    /*�ֱ��ʣ�800*600*/
    /*parameter p_Hmaxsize = 11'd1040;//��ʵ���������
    parameter p_Vmaxsize = 11'd666;//��ʵ���������
    parameter p_Hreal_minsize = 11'd184;//ʵ����ʾ��������ʹ�
    parameter p_Hreal_maxsize = 11'd985;//ʵ����ʾ��������ߴ�
    parameter p_Vreal_minsize = 11'd29;//ʵ����ʾ��������ʹ�
    parameter p_Vreal_maxsize = 11'd629;//ʵ����ʾ��������ߴ�
    parameter p_Hsyncsize = 11'd120;//��ͬ������ʱ��Χ
    parameter p_Vsyncsize = 11'd6;//��ͬ������ʱ��Χ*/
    
    reg [10:0]r_countH;//��¼ʵʱ����
    reg [10:0]r_countV;//��¼ʵʱ����
    reg r_is_ready;//��ʾ׼��������־λ����ʱΪ������ʾ������
    
    /*���н���ɨ��*/
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)
            r_countH <= 11'b0;//��λ
        else if (r_countH == p_Hmaxsize)//�������ұ�ʱ
            r_countH <= 11'b0;//���������
        else
            r_countH <= r_countH + 1'b1;//ɨ���������һ��
    end
    
    /*���н���ɨ��*/
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)
            r_countV <= 11'b0;//��λ
        else if (r_countV == p_Vmaxsize)//�������±�ʱ
            r_countV <= 11'b0;//�������ϱ�
        else if (r_countH == p_Hmaxsize)//��ÿһ��ɨ����Ϻ�
            r_countV <= r_countV + 1'b1;//ɨ���������һ��
    end
    
    /*����Ч�����źŽ����ж�*/
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)
            r_is_ready <= 1'b0;//��λ
        else if ((r_countH > p_Hreal_minsize && r_countH < p_Hreal_maxsize) && (r_countV > p_Vreal_minsize && r_countV < p_Vreal_maxsize))
            //���о���ʵ����ʾ�ķ�Χ��
            r_is_ready <= 1'b1;//������ʾ
        else //��������ʾ����
            r_is_ready <= 1'b0;//���ֲ���ʾ
    end
    
    /*��������źŽ��и�ֵ*/
    //����ͬ���źţ��Լ��Ƿ���ʾ���ݵ��ź�
    assign Vsync_s = (r_countV <= p_Vsyncsize) ? 1'b0 : 1'b1;//ͬ��ʱΪ�͵�ƽ
    assign Hsync_s = (r_countH <= p_Hsyncsize) ? 1'b0 : 1'b1;//ͬ��ʱΪ�͵�ƽ
    assign Ready_s = r_is_ready;//������ʾ����ʱ��Ӧ��ֵ
    //��������ֵ
    assign Col_s = r_is_ready ? (r_countH - p_Hreal_minsize - 1'b1) : 11'd0;//������
    assign Row_s = r_is_ready ? (r_countV - p_Vreal_minsize - 1'b1) : 11'd0;//������
    
endmodule
