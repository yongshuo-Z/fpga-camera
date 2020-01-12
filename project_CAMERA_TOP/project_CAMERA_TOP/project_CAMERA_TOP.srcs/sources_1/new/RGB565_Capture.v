`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/23 12:26:30
// Design Name: 
// Module Name: RGB565_Capture
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
//����ͷ�źŲɼ�ģ��Out_frame_vsync, Out_frame_href, 
module RGB565_Capture(CLK, RST_n, CFG_done, OV_pclk, OV_xclk, OV_vsync, OV_href, OV_din, Out_frame_data, Out_data_en, Out_data_addr);
    //ģ���ڲ�ȫ�ֽӿ�
    input CLK;//�ⲿ����ʱ�ӣ�24MHz
    input RST_n;//��λ�źţ��͵�ƽ��Ч
    input CFG_done;//��������ź�
    //����ͷ�ӿ�
    input OV_pclk;//����ͷ����ʱ��
    output OV_xclk;//����ͷ����ʱ��
    input OV_vsync;//����ͷ��ͬ���ź����
    input OV_href;//����ͷ����Ч�ź����
    input [7:0]OV_din;//����ͷ8bit���ݽ���
    //��������ź�
    output reg[11:0]Out_frame_data;//����ͷ���������ƴ�ӵ�12bit���ݣ������϶���
    output reg Out_data_en;//�������ʹ���ź�
    output [18:0]Out_data_addr;//д��RAM�ĵ�ַ    
    

    parameter p_max_addr = 19'd307200;//������ʵ�����߽�
    parameter p_real_y = 11'd600;//������ʵ�����߽�
    parameter p_real_x = 11'd800;//������ʵ�����߽�
    parameter p_true_y = 11'd480;//��������Ч���߽�
    parameter p_true_x = 11'd640;//��������Ч���߽�
    //parameter p_true_y = 11'd600;//��������Ч���߽�
    //parameter p_true_x = 11'd800;//��������Ч���߽�

    //��ַ��ʱ�ӵĸ�ֵ
    reg [18:0]r_addr;//��ַ�Ĵ���
    assign Out_data_addr = r_addr;
    assign OV_xclk = CLK;//�ⲿʱ��ֱ����Ϊ������
    //���VSYNC���������½���
    reg [1:0]r_OV_vsync;//���ؼ��Ĵ���
    reg r_vysnc_valid;//֡��Ч�ź�
    wire w_vysnc_negedge;//�½���
    wire w_vysnc_posedge;//������
    always @ (posedge OV_pclk or negedge RST_n)
    begin
        if(!RST_n)
            r_OV_vsync <= 0;
        else if (CFG_done)
            r_OV_vsync <= {r_OV_vsync[0], OV_vsync};
    end
    assign w_vysnc_negedge = r_OV_vsync[1] && !r_OV_vsync[0] ;//�½���
    assign w_vysnc_posedge = !r_OV_vsync[1] && r_OV_vsync[0] ;//������
    

    
    always @(posedge OV_pclk or negedge RST_n)
    begin
        if (!RST_n) 
            begin 
            r_vysnc_valid <= 0;//��λ����Ч
            end
        else if (CFG_done)
            begin
            if(w_vysnc_posedge) //�����أ�����һ֡ͼ��ʼ
                r_vysnc_valid <= 1; 
            else if(w_vysnc_negedge) //�½��أ�����һ֡ͼ�����
                r_vysnc_valid <= 0;
            else 
                r_vysnc_valid <= r_vysnc_valid;
            end//of else if
    end//of always
    
    //ƴ������
    reg [11:0]r_herf_cnt;//���������
    //reg [11:0]camera_data_reg;
    reg [1:0]r_counter;//������ƴ�ӵĸ�λ���λ���п���

    always @ (posedge OV_pclk or negedge RST_n)
    begin
        if (!RST_n) //��λ
            begin 
            r_herf_cnt <= 0;
            r_counter <= 0;
            //camera_data_reg <= 0;
            Out_frame_data  <= 0;
            Out_data_en <= 1'b0;
            r_addr <= 0;
            end
        else if (CFG_done)//�������
            begin
            if (r_vysnc_valid)
                begin
                if ((OV_href == 1'b1) && (OV_vsync == 1'b1) && (r_herf_cnt < p_true_x)) //��һ��֡���д���
                    begin   
                    if (r_counter < 1'b1) 
                        begin                                    
                        r_counter <= r_counter + 1'b1;
                        Out_frame_data[11:5] = {OV_din[7:4], OV_din[2:0]};
                        //camera_data_reg <= {camera_data_reg[5:0], };
                        //camera_data_reg <= {camera_data_reg[7:0], OV_din};
                        Out_data_en <= 1'b0;
                        end
                    else 
                        begin                                                 
                        r_herf_cnt <= r_herf_cnt+ 1'b1;
                        r_counter <= 0;
                        Out_frame_data[4:0] <= {OV_din[7], OV_din[4:1]};
                        //Out_frame_data <={camera_data_reg[5:0], OV_din[7:6], OV_din[4:1]};
                        if (r_addr < p_max_addr) //��ֹд��RAM�����������
                            begin
                            r_addr <= r_addr + 1'b1;
                            Out_data_en <= 1'b1;
                            end    
                        //camera_data_reg <= 0;                  
                        end
                    end
                else if ((OV_href == 1'b0) && (OV_vsync == 1'b1)) //һ�н���
                    begin   
                    r_herf_cnt <= 0;
                    r_counter <= 0;
                    Out_data_en <= 1'b0;
                    r_addr <= r_addr;
                    end
                else 
                    begin
                    r_herf_cnt <= r_herf_cnt;//��ȡһ�к�ȴ�
                    r_counter <= 0;
                    Out_data_en <= 1'b0;
                    r_addr <= r_addr;
                    end
            end
        else 
            begin
            r_herf_cnt <= 0;
            r_counter <= 0;
            Out_data_en <= 1'b0;
            r_addr <= 0;
            end   
        end 
    end    
    
endmodule
