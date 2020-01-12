`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/21 22:42:42
// Design Name: 
// Module Name: SCCB_Timing_Control
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
//SCCBЭ��ʱ����ƣ�Э����д���ã�
module SCCB_Timing_Control(CLK, RST_n, SCCB_CLK, SCCB_DATA, CFG_size, CFG_index, CFG_data, CFG_done, CFG_rdata, ACK, Read_en);
    input CLK;//ȫ��ʱ�ӣ���������Ч����Ҫ24MHz��ʱ��
    input RST_n;//��λ�źţ��͵�ƽ��Ч
    output SCCB_CLK;//SCCBЭ��ʱ�ӣ�������ͷ��
    inout SCCB_DATA;//SCCB˫�������ݣ�������ͷ��
    input [7:0]CFG_size;//����ģ��Ĵ���������    
    input [23:0]CFG_data;//����SCCB�����ݣ�д��Ĵ���������3phase{ID, ��ַ������}
    output reg[7:0]CFG_index;//��ǰ����ģ���ѯָ���Ĵ���������
    output CFG_done;//����ͷ��������ź�
    output reg[7:0]CFG_rdata;//��ȡ�Ĵ���������
    output reg ACK;//���Ӧ����
    output Read_en;//��дʹ��
    
    //**********************�ӻ���ַ��дʱ��0x60******************
    parameter p_delay_num = 100000;
    parameter p_sccb_clk = 1000;
    parameter p_SCCB_IDLE = 5'd0;//������״̬
    parameter p_SCCB_W_START = 5'd1;//д��ʱ��ʼ
    parameter p_SCCB_W_IDADDR = 5'd2;//д�����ID��ַ
    parameter p_SCCB_W_ACK1 = 5'd3;//д����ȡӦ���ź�1
    parameter p_SCCB_W_REGADDR = 5'd4;//д������Ĵ�����ַ
    parameter p_SCCB_W_ACK2 = 5'd5;//д����ȡӦ���ź�2
    parameter p_SCCB_W_REGDATA = 5'd6;//д������Ĵ�������
    parameter p_SCCB_W_ACK3 = 5'd7;//д����ȡӦ���ź�3
    parameter p_SCCB_W_STOP = 5'd8;//д��ʱ�����
    parameter p_SCCB_R_START1 = 5'd9;//��1��ʱ��ʼ�ź�1
    parameter p_SCCB_R_IDADDR1 = 5'd10;//��1�����ID��ַ
    parameter p_SCCB_R_ACK1 = 5'd11;//��1��д��Ӧ���ź�1
    parameter p_SCCB_R_REGADDR = 5'd12;//��1������Ĵ�����ַ
    parameter p_SCCB_R_ACK2 = 5'd13;//��1��д��Ӧ���ź�2
    parameter p_SCCB_R_STOP1 = 5'd14;//��1��ʱ������ź�
    parameter p_SCCB_R_IDLE = 5'd15;//�м���ת״̬����ת����ȡװ̬2
    parameter p_SCCB_R_START2 = 5'd16;//��2��ʱ��ʼ�ź�
    parameter p_SCCB_R_IDADDR2 = 5'd17;//��2�����ID��ַ
    parameter p_SCCB_R_ACK3 = 5'd18;//��2��д��Ӧ���ź�3
    parameter p_SCCB_R_REGDATA = 5'd19;//��2����ȡ�Ĵ���
    parameter p_SCCB_R_NACK = 5'd20;//��2����ȡӦ���ź�����
    parameter p_SCCB_R_STOP2 = 5'd21;//��2��ʱ������ź�
    
    reg [16:0]r_delay_cnt;//�ӳټ���    
    reg [16:0]r_clk_cnt;//ʱ�Ӽ���
    reg r_sccb_clk;//SCCBЭ��ʱ��
    reg [4:0]r_now_state;//״̬����ǰ״̬
    reg [4:0]r_next_state;//״̬����һ״̬
    reg [3:0]r_bit_cnt;//ÿһphas�Ĵ���λ����������0-7
    reg r_sccb_out;//Ҫ��������ݣ���������̬��    
    wire w_sccb_in = SCCB_DATA;//Ҫ��������ݣ���������̬��
    wire w_delay_done = (r_delay_cnt == p_delay_num) ? 1'b1 : 1'b0;//�ӳ���ɺ��ź�Ϊ1
    wire w_transfer_en = (r_clk_cnt == 17'd0) ? 1'b1 :1'b0;//���ݷ���ʹ���ź�
    wire w_capture_en = (r_clk_cnt == (2*p_sccb_clk/4) - 1'b1) ? 1'b1 :1'b0;//���ݷ���ʹ���ź�
    wire w_write_done;//д���ź�

    //�ϵ�����ӳ�
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)//��λ
            r_delay_cnt <= 0;
        else if (r_delay_cnt < p_delay_num)
            r_delay_cnt <= r_delay_cnt + 1'b1;
        else
            r_delay_cnt <= r_delay_cnt;
    end
    
    //��ʱ��ɺ�ȷ��SCCB��ʱ��
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)//��λ
            begin 
            r_clk_cnt <= 0;
            r_sccb_clk <= 0;
            end
        else if (w_delay_done)
            begin 
            if (r_clk_cnt < (p_sccb_clk - 1'b1))
                r_clk_cnt <= (r_clk_cnt + 1'd1);
            else
                r_clk_cnt <= 0;
            r_sccb_clk <= (r_clk_cnt >= (p_sccb_clk/4 + 1'b1))&&(r_clk_cnt  < (3*p_sccb_clk/4) + 1'b1) ? 1'b1 : 1'b0;
            end
        else
            begin
            r_clk_cnt <= 0;
            r_sccb_clk <= 0;
            end
    end
    
    //��ȡʹ����Ч�ź�
    wire w_read_en = (r_now_state == p_SCCB_W_ACK1 || r_now_state == p_SCCB_W_ACK2
                    || r_now_state == p_SCCB_W_ACK3 || r_now_state == p_SCCB_R_ACK1
                    || r_now_state == p_SCCB_R_ACK2 || r_now_state == p_SCCB_R_ACK3
                    || r_now_state == p_SCCB_R_REGDATA) ? 1'b1 : 1'b0;
    assign Read_en =  w_read_en;
    //SCCBʱ�����
    assign SCCB_CLK = (r_now_state >= p_SCCB_W_IDADDR && r_now_state <= p_SCCB_W_ACK3 
                    || r_now_state >= p_SCCB_R_IDADDR1 && r_now_state <= p_SCCB_R_ACK2
                    || r_now_state >= p_SCCB_R_IDADDR2 && r_now_state <= p_SCCB_R_NACK) ? r_sccb_clk : 1'b1;

    //��̬�Ž�������������ж�
    assign SCCB_DATA = (~w_read_en) ? r_sccb_out : 1'bz;
    
    //��ȡ״̬������ȡ�Ĵ���������4phase{ID1, ��ַ��ID2, ����}
    reg r_sclk_default;
    reg [7:0]r_sccb_wdata;//�ݴ�Ҫд������
    //��1��ͬ��ʱ��飬��ʽ����̬����̬
    always @ (posedge CLK or negedge RST_n)
        if (!RST_n)//����
            r_now_state = p_SCCB_IDLE;//��ʼ��
        else
            r_now_state = r_next_state;
    //��2��ת��������
    always @ (*)
    begin
        r_next_state = p_SCCB_IDLE;
        case (r_now_state)
        p_SCCB_IDLE: 
            if (w_delay_done)
                r_next_state = p_SCCB_W_START;//p_SCCB_R_PRE  p_SCCB_R_START1
            else
                r_next_state = p_SCCB_IDLE;
        p_SCCB_R_START1: //��ʼ1
            if (w_transfer_en)
                r_next_state = p_SCCB_R_IDADDR1;
            else
                r_next_state = p_SCCB_R_START1;
        p_SCCB_R_IDADDR1: //ID1
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_R_ACK1;
            else
                r_next_state = p_SCCB_R_IDADDR1;
        p_SCCB_R_ACK1://Ӧ��1
            if (w_transfer_en)
                r_next_state = p_SCCB_R_REGADDR;
            else
                r_next_state = p_SCCB_R_ACK1;
        p_SCCB_R_REGADDR: //�Ĵ�����ַ
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_R_ACK2;
            else
                r_next_state = p_SCCB_R_REGADDR;
        p_SCCB_R_ACK2: //Ӧ��2
            if (w_transfer_en)
                r_next_state = p_SCCB_R_STOP1;
            else
                r_next_state = p_SCCB_R_ACK2;
        p_SCCB_R_STOP1: //ֹͣ1
            if (w_transfer_en)
                r_next_state = p_SCCB_R_IDLE;
            else
                r_next_state = p_SCCB_R_STOP1;
        p_SCCB_R_IDLE: //�м�ת��״̬
            if (w_transfer_en)
                r_next_state = p_SCCB_R_START2;
            else
                r_next_state = p_SCCB_R_IDLE;
        p_SCCB_R_START2: //��ʼ2
            if (w_transfer_en)
                r_next_state = p_SCCB_R_IDADDR2;
            else
                r_next_state = p_SCCB_R_START2;
        p_SCCB_R_IDADDR2: //ID2
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_R_ACK3;
            else
                r_next_state = p_SCCB_R_IDADDR2;
        p_SCCB_R_ACK3: //Ӧ��3
            if (w_transfer_en)
                r_next_state = p_SCCB_R_REGDATA;
            else 
                r_next_state = p_SCCB_R_ACK3;
        p_SCCB_R_REGDATA: 
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_R_NACK;
            else
                r_next_state = p_SCCB_R_REGDATA;
        p_SCCB_R_NACK: //NAλ
            if (w_transfer_en)
                r_next_state = p_SCCB_R_STOP2;
            else
                r_next_state = p_SCCB_R_NACK;
        p_SCCB_R_STOP2: //ֹͣ2
            r_next_state = p_SCCB_R_STOP2;//����ֹͣ״̬
        /////////////////////////////////////////////////////
        p_SCCB_W_START://д����ʼ
            if (w_transfer_en)
                r_next_state = p_SCCB_W_IDADDR;
            else
                r_next_state = p_SCCB_W_START;
        p_SCCB_W_IDADDR://д��ID��ַ
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_W_ACK1;
            else
                r_next_state = p_SCCB_W_IDADDR;
        p_SCCB_W_ACK1://д��Ӧ��ACK1
            if (w_transfer_en)
                r_next_state = p_SCCB_W_REGADDR;
            else
                r_next_state = p_SCCB_W_ACK1;
        p_SCCB_W_REGADDR://д���Ĵ�����ַ
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_W_ACK2;
            else
                r_next_state = p_SCCB_W_REGADDR;
        p_SCCB_W_ACK2: //д��Ӧ��ACK2
            if (w_transfer_en)
                r_next_state = p_SCCB_W_REGDATA;
            else
                r_next_state = p_SCCB_W_ACK2;
        p_SCCB_W_REGDATA: //д��ID����ַ
            if (w_transfer_en == 1'b1 && r_bit_cnt == 4'd8)
                r_next_state = p_SCCB_W_ACK3;
            else
                r_next_state = p_SCCB_W_REGDATA;
        p_SCCB_W_ACK3: //д��Ӧ��ACK3
            if (w_transfer_en)
                r_next_state = p_SCCB_W_STOP;
            else 
                r_next_state = p_SCCB_W_ACK3;
        p_SCCB_W_STOP: //д��ֹͣ*********************��***********************
            if (w_transfer_en)//���
                if (w_write_done) //CFG_done  
                    r_next_state = p_SCCB_R_START1;//ת����ȡ p_SCCB_W_STOP  
                else
                    r_next_state = p_SCCB_W_START;//���ؼ���д��  p_SCCB_W_START
            else
                r_next_state = p_SCCB_W_STOP;//���ָ�״̬
        endcase
    end 
    //��3����̬�������飨�ӼĴ��������ݣ�
    always @ (negedge CLK or negedge RST_n)
    begin
        if (!RST_n)//����
            begin
            r_sccb_out <= 1'b0;//r_next_state <= p_SCCB_IDLE;
            end
        else if (w_transfer_en)
            case (r_next_state)
            //******��״̬******
            p_SCCB_R_STOP1: //ֹͣ���
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                end
            p_SCCB_R_STOP2:
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                end
            p_SCCB_R_IDLE: //�����м�ת��״̬
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b1;
                end
            p_SCCB_R_START1: //������ʼ1
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                r_sccb_wdata <= CFG_data[23:16];//���λ��ID��ַ
                end
            p_SCCB_R_START2: //������ʼ2
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                r_sccb_wdata <= CFG_data[7:0];//��λ��ID��ַ
                end
            p_SCCB_R_IDADDR1: //����д��Ҳ���Ƕ���ID��ַ
                begin
                r_sclk_default <= 1'b0;
                r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                end
            p_SCCB_R_IDADDR2: //������ID��ַ
                begin
                r_sclk_default <= 1'b0;
                if (r_bit_cnt < 4'd7)
                    r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                else
                    r_sccb_out <= 1'b1;//����λ����
                end
            p_SCCB_R_ACK1: //����Ӧ��1
                begin
                r_sclk_default <= 1'b0;
                r_sccb_wdata <= CFG_data[15:8];//�м�λ�ļĴ�����ַ
                end
            p_SCCB_R_ACK2://����Ӧ��2
                begin
                r_sclk_default <= 1'b0;
                end
            p_SCCB_R_ACK3:
                begin
                r_sclk_default <= 1'b0;
                end
            p_SCCB_R_REGDATA: //�����Ĵ�������
                begin
                r_sclk_default <= 1'b0;
                end
            p_SCCB_R_REGADDR: //�����Ĵ�����ַ
                begin
                r_sclk_default <= 1'b0;
                r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                end
            p_SCCB_R_NACK: //����NA״̬
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b1;
                end
            //******д״̬******
            p_SCCB_W_START: //д����ʼ���
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                r_sccb_wdata <= CFG_data[23:16];//���λ��ID��ַ
                end
            p_SCCB_W_IDADDR: //д��дID��ַ
                begin
                r_sclk_default <= 1'b0;
                r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                end
            p_SCCB_W_REGDATA: //д���Ĵ�������
                begin
                r_sclk_default <= 1'b0;
                r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                end
            p_SCCB_W_REGADDR: //д���Ĵ�����ַ
                begin
                r_sclk_default <= 1'b0;
                r_sccb_out <= r_sccb_wdata[3'd7 - r_bit_cnt];
                end
            p_SCCB_W_ACK1: //д��Ӧ��1
                begin
                r_sclk_default <= 1'b0;
                r_sccb_wdata <= CFG_data[15:8];//�м�λ�ļĴ�����ַ
                end
            p_SCCB_W_ACK2: //д��Ӧ��2
                begin
                r_sclk_default <= 1'b0;
                r_sccb_wdata <= CFG_data[7:0];//��λ��д������
                end
            p_SCCB_W_ACK3: //д��Ӧ��3
                begin
                r_sclk_default <= 1'b0;
                end
            p_SCCB_W_STOP: //д��ֹͣ
                begin
                r_sclk_default <= 1'b1;
                r_sccb_out <= 1'b0;
                end
            default: ;//
            endcase
    end
    
    //��4����̬�������飨��Ĵ���д���ݣ�
    //д�봫�����ݽ�����־
    wire w_transfer_end = (r_now_state == p_SCCB_W_STOP 
                         || r_now_state == p_SCCB_R_STOP2) ? 1'b1 : 1'b0;
    always @ (negedge CLK or negedge RST_n)
    begin
        if (!RST_n)//����
            CFG_index <= 0;
        else if (w_transfer_en)
            begin
            if (w_transfer_end && ACK == 1'b0)
                begin
                if (CFG_index < CFG_size)
                    CFG_index <= CFG_index + 1'b1;
                else
                    CFG_index <= CFG_size;
                end
            else
                CFG_index <= CFG_index;
            end
        else
            CFG_index <= CFG_index;
    end
    assign CFG_done = (CFG_index == CFG_size) ? 1'b1 : 1'b0;
    assign w_write_done = (CFG_index == (CFG_size - 1'b1)) ? 1'b1 : 1'b0;
    //��5�����ݲ���������ʱ���е��������
    always @ (negedge CLK or negedge RST_n)
    begin
        if (!RST_n)//���� 
            CFG_rdata <= 0;//CFG_rdata
        else if (w_capture_en)
            case (r_next_state)
            p_SCCB_R_REGDATA: //���Ĵ�������
                CFG_rdata <= {CFG_rdata[6:0], w_sccb_in};
            default:  ;
            endcase
    end
        
    //��6��λ����
    always @ (posedge r_sccb_clk or negedge RST_n)
    begin
        if (!RST_n)//����
            begin
            r_bit_cnt <= 0;//CFG_rdata
            end
        else
            begin
            case (r_next_state)
            p_SCCB_R_START1: //������ʼ1
                r_bit_cnt <= 0;
            p_SCCB_R_START2: //������ʼ2
                r_bit_cnt <= 0;
            p_SCCB_R_IDADDR1: //����д��Ҳ���Ƕ���ID��ַ
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_R_IDADDR2: //������ID��ַ
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_R_ACK1: //����Ӧ��1
                r_bit_cnt <= 0;
            p_SCCB_R_ACK2: //����Ӧ��2
                r_bit_cnt <= 0;
            p_SCCB_R_ACK3: //����Ӧ��3
                r_bit_cnt <= 0;
            p_SCCB_R_REGDATA: //�����Ĵ�������
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_R_REGADDR: //�����Ĵ�����ַ
                r_bit_cnt <= r_bit_cnt + 1'b1;
            /////////////////////////////
            p_SCCB_W_START: //д����ʼ
                r_bit_cnt <= 0; 
            p_SCCB_W_IDADDR: //д��ID��ַ
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_W_REGDATA: //д���Ĵ�������
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_W_REGADDR: //д���Ĵ�����ַ
                r_bit_cnt <= r_bit_cnt + 1'b1;
            p_SCCB_W_ACK1: //д��Ӧ��1
                r_bit_cnt <= 0;
            p_SCCB_W_ACK2: //д��Ӧ��2
                r_bit_cnt <= 0;
            p_SCCB_W_ACK3: //д��Ӧ��3
                r_bit_cnt <= 0;
            endcase
            end
    end

    //��7������Ӧ���ź�
    reg [2:0]r_ack;//3��Ӧ���źŵļ�¼
    always @ (posedge CLK or negedge RST_n)
    begin
        if (!RST_n)//����
            begin
            r_ack <= 3'b111;
            ACK <= 1'b1;
            end
        else if(w_capture_en)
            begin
            case(r_next_state)
            p_SCCB_IDLE: //����̬
                begin
                r_ack <= 3'b111;
                ACK <= 1'b1;
                end
            //******��Ӧ��******
            p_SCCB_R_ACK1:
                r_ack[0] <= w_sccb_in;
            p_SCCB_R_ACK2:
                r_ack[1] <= w_sccb_in;
            p_SCCB_R_ACK3:
                r_ack[2] <= w_sccb_in;
            p_SCCB_R_STOP2:
                ACK <= (r_ack[0] | r_ack[1] | r_ack[2]);
            //******дӦ��******
            p_SCCB_W_ACK1:
                r_ack[0] <= w_sccb_in;
            p_SCCB_W_ACK2:
                r_ack[1] <= w_sccb_in;
            p_SCCB_W_ACK3:
                r_ack[2] <= w_sccb_in;
            p_SCCB_W_STOP:
                ACK <= (r_ack[0] | r_ack[1] | r_ack[2]); 
            default: ;
            endcase
            end
        else
            begin
            r_ack <= r_ack;//����
            ACK <= ACK;
            end
    end
endmodule
