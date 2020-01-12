`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2019/01/01 15:26:15
// Design Name: 
// Module Name: CAMERE_TOP
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
//����ͷ����ҵ���������ģ��
module CAMERE_TOP(OV_SIOC, OV_SIOD, OV_VSYNC, OV_HREF, OV_PCLK, OV_XCLK, OV_DATA, OV_RST, OV_PWDN, O_Data, Bit_ctrl, Vsync_s, Hsync_s, R_s, G_s, B_s, ACK_YES, PIX, RST_n, Pause, CLK_100MHz, Read_en, Write_en);//
    //����ͷ�ӿ�
    output OV_SIOC;//SCCBʱ��
    inout OV_SIOD;//SCCB���ݣ�˫��
    input OV_VSYNC;//��ͬ���ź�
    input OV_HREF;//����Ч�ź����
    input OV_PCLK;//����ʱ��
    output OV_XCLK;//������ʱ��
    input [7:0]OV_DATA;//8bit����
    output OV_RST;//��λ
    output OV_PWDN;//ʡ��
    //7������ܽӿ�
    output [6:0]O_Data;//�������ʾ
    output [7:0]Bit_ctrl;//λ��
    //VGA�ӿ�
    output Vsync_s;//��ͬ���ź�
    output Hsync_s;//��ͬ���ź�
    output [3:0]R_s;//����ɫ�ź�
    output [3:0]G_s;//����ɫ�ź�
    output [3:0]B_s;//����ɫ�ź�
    //LED�ƽӿ�
    output ACK_YES;//����ͷӦ�������͵�ƽ��Ч��
    output [7:0]PIX;
    output Write_en;//д������ʹ���ź�
    output Read_en;//���ڷ������̬�����
    //ģ��ȫ�ֽӿ�
    input RST_n;//��λ
    input Pause;//��ͣ��
    input CLK_100MHz;//������ϵͳʱ�ӣ�100MHz
    
    //�ڲ�ģ�����
    //SDRAM�ӿ�
    wire [11 : 0]Frame_data; //output
    wire [18 : 0]Frame_addr; //output
    
    //�ڲ�����
    wire [18:0]w_read_addr;//VGA��ȡ��ַ
    wire [7:0]w_Read_ID;//��ȡ����ͷ��ID���������ͷ�Ĺ��������д���������
    wire [11:0]w_out_pix_data;//�������������
    wire w_clk_10MHz, w_clk_24MHz, w_clk_25MHz;//��Ƶ���ʱ����
    
    assign PIX = OV_DATA;//w_out_pix_data[15:8]
    //ʱ�ӷ�Ƶ��
    CLK_DIV div_inst(.CLK_100MHz(CLK_100MHz), .CLK_10MHz(w_clk_10MHz), .CLK_24MHz(w_clk_24MHz), .CLK_25MHz(w_clk_25MHz), .RST_n(RST_n));
    
    //ʵ����OV2640����ģ��
    OV2640_Driver ov2640_inst(
        .OV_SIOC(OV_SIOC), 
        .OV_SIOD(OV_SIOD), 
        .OV_VSYNC(OV_VSYNC), 
        .OV_HREF(OV_HREF),
        .OV_PCLK(OV_PCLK), 
        .OV_XCLK(OV_XCLK), 
        .OV_DATA(OV_DATA), 
        .OV_RST(OV_RST), 
        .OV_PWDN(OV_PWDN), 
        .Frame_data(Frame_data), 
        .Frame_addr(Frame_addr),
        .Output_en(Write_en),//���Կ�ʼд������
        .RST_n(RST_n), 
        .CLK_sioc_10MHz(w_clk_10MHz), 
        .CLK_xclk_24MHz(w_clk_24MHz),
        .ACK_YES(ACK_YES),
        .Read_en(Read_en), 
        .Read_ID(w_Read_ID)
    );
    
    //ʵ������˫��RAM
    SDRAM sdram_inst(
        .W_en(Write_en & ~Pause), //������ͣ����ֹͣ����
        .CLK_w(OV_PCLK), //Frame_clken  CLK_100MHz
        .CLK_r(w_clk_25MHz), 
        .ADDR_in(Frame_addr), 
        .ADDR_out(w_read_addr), 
        .DAT_in(Frame_data), 
        .DAT_out(w_out_pix_data)
    );
    
    //ʵ�����������ʾģ��
    DISPLAY_DATA dis_inst(.CLK_100MHz(CLK_100MHz), .I_Data(w_Read_ID), .O_Data(O_Data), .Bit_ctrl(Bit_ctrl));
    
    //ʵ����VGA��ʾģ��
    VGA vga_inst(
        .CLK_25MH(w_clk_25MHz), 
        .RST_n(RST_n), 
        .Pix_Addr(w_read_addr),
        .Pix_Data(w_out_pix_data),// Frame_data w_out_pix_data
        .Vsync_s(Vsync_s), 
        .Hsync_s(Hsync_s), 
        .R_s(R_s), 
        .G_s(G_s), 
        .B_s(B_s)
    );
endmodule