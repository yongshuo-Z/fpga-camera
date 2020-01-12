`timescale 1ps / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 22:41:04
// Design Name: 
// Module Name: OV2640_Driver
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
//OV2640����ͷ����ģ�� 
module OV2640_Driver(OV_SIOC, OV_SIOD, OV_VSYNC, OV_HREF, OV_PCLK, OV_XCLK, OV_DATA, OV_RST, OV_PWDN, Frame_data, Frame_addr, Output_en, RST_n, CLK_sioc_10MHz, CLK_xclk_24MHz, ACK_YES, Read_en, Read_ID);//clk_pll, , Capture_en
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
    //��FIFO�ӿ�
    output [11:0]Frame_data; 
    output [18:0]Frame_addr;
    output Output_en;//��������ź�
    //��ģ���ڲ�ȫ�ֽӿ�
    input RST_n;//��λ
    input CLK_sioc_10MHz;//SCCBЭ��ʹ��ʱ�ӣ�10MHz��
    input CLK_xclk_24MHz;//����ͷXCLKʹ��ʱ�ӣ�24MHz
    output ACK_YES;//����ͷ��Ӧ���źţ��͵�ƽΪ��Ӧ��
    output Read_en;//TBd ��̬�Ŷ�ȡ�źſ���
    output [7:0]Read_ID;//��ȡ�Ĵ���������
    
    //�궨�����
    parameter p_rIDaddr = 8'h60;//д�Ĵ�����ID��ַ
    //ģ���ڲ�����
    wire [7:0]w_cfg_size;
    wire [7:0]w_cfg_index;
    wire [15:0]write_data;//��ȡ����������
    wire w_xclk, w_sioc;//ʱ������
    wire w_cfg_done;//��������ź�
    
    ////�̶���ֵ
    assign OV_RST  = 1;//����ʹ�ã����ߵ�ƽ
    assign OV_PWDN = 0;//����ʹ�ã����͵�ƽ
    
    //SCCBʱ���д����
    SCCB_Timing_Control timing_inst(
        .CLK(CLK_sioc_10MHz), 
        .RST_n(RST_n), 
        .SCCB_CLK(OV_SIOC), 
        .SCCB_DATA(OV_SIOD), 
        .CFG_size(w_cfg_size), //w_cfg_size
        .CFG_index(w_cfg_index), //w_cfg_index
        .CFG_data({p_rIDaddr, write_data[15:0]}), //r_read_ID
        .CFG_done(w_cfg_done), //
        .CFG_rdata(Read_ID),
        .ACK(ACK_YES),
        .Read_en(Read_en)
    );
    
    //������Ϣģ��
    RGB565_Config config_inst(.LUT_INDEX(w_cfg_index), .LUT_DATA(write_data), .LUT_SIZE(w_cfg_size));
    
    //�����������ģ��
    RGB565_Capture capture_inst(
        .CLK(CLK_xclk_24MHz), 
        .RST_n(RST_n), 
        .CFG_done(w_cfg_done),
        .OV_pclk(OV_PCLK), 
        .OV_xclk(OV_XCLK), 
        .OV_vsync(OV_VSYNC), 
        .OV_href(OV_HREF), 
        .OV_din(OV_DATA), 
        .Out_frame_data(Frame_data), 
        .Out_data_en(Output_en), 
        .Out_data_addr(Frame_addr)
    );

endmodule
