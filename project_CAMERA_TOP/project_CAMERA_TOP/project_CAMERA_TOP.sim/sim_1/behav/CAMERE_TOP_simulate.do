######################################################################
#
# File name : CAMERE_TOP_simulate.do
# Created on: Fri Jan 04 15:14:51 +0800 2019
#
# Auto generated by Vivado for 'behavioral' simulation
#
######################################################################
vsim -voptargs="+acc" -L unisims_ver -L unimacro_ver -L secureip -L xil_defaultlib -L xpm -L blk_mem_gen_v8_3_3 -lib xil_defaultlib xil_defaultlib.CAMERE_TOP xil_defaultlib.glbl

do {CAMERE_TOP_wave.do}

view wave
view structure
view signals

do {CAMERE_TOP.udo}

run 1000ns
