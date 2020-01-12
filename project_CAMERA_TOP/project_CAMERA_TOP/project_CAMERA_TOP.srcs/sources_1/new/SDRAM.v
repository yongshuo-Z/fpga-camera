`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 2018/12/25 21:28:08
// Design Name: 
// Module Name: SDRAM
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
//SDRAM����ģ�飬����ֻ���Ÿ�λ����дʱ�ӣ���д���ݿڣ���ʼ��д�����źš��Ƿ�����ڲ���װ����
module SDRAM(W_en, CLK_w, CLK_r, ADDR_in, ADDR_out, DAT_in, DAT_out);//, Write_en
    input W_en;//дʹ�ܣ��ߵ�ƽ��Ч
    input CLK_w;//д������ʱ��
    input CLK_r;//��ȡ����ʱ��  
    input [18:0]ADDR_in;//��ַд��
    input [18:0]ADDR_out;//��ַд��
    input [11:0]DAT_in;//12λ����д��
    output [11:0]DAT_out;//12λ���ض���

    blk_mem_gen_0 sdram_inst (
        .clka(CLK_w),    // дʱ��
        .wea(W_en),      // ʹ��
        .addra(ADDR_in),  // д��ַ  input wire [18 : 0] addra
        .dina(DAT_in),    // д����  input wire [11 : 0] dina
        .clkb(CLK_r),    // ��ʱ��  input wire clkb
        .addrb(ADDR_out),  // ����ַ  input wire [18 : 0] addrb
        .doutb(DAT_out)  //  ������  output wire [11 : 0] doutb
    );

endmodule
