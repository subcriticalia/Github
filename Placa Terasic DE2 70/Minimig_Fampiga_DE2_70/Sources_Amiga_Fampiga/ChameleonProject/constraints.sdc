## Generated SDC file "hello_led.out.sdc"

## Copyright (C) 1991-2011 Altera Corporation
## Your use of Altera Corporation's design tools, logic functions 
## and other software and tools, and its AMPP partner logic 
## functions, and any output files from any of the foregoing 
## (including device programming or simulation files), and any 
## associated documentation or information are expressly subject 
## to the terms and conditions of the Altera Program License 
## Subscription Agreement, Altera MegaCore Function License 
## Agreement, or other applicable license agreement, including, 
## without limitation, that your use is for the sole purpose of 
## programming logic devices manufactured by Altera and sold by 
## Altera or its authorized distributors.  Please refer to the 
## applicable agreement for further details.


## VENDOR  "Altera"
## PROGRAM "Quartus II"
## VERSION "Version 11.1 Build 216 11/23/2011 Service Pack 1 SJ Web Edition"

## DATE    "Fri Jul 06 23:05:47 2012"

##
## DEVICE  "EP3C25Q240C8"
##


#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

create_clock -name {clk8} -period 125.000 -waveform { 0.000 0.500 } [get_ports {clk8}]
# create_clock -name spi_clock -period 35.000 Fampiga:myFampiga|cfide:mycfide|sck

#**************************************************************
# Create Generated Clock
#**************************************************************

derive_pll_clocks 
create_generated_clock -name sd1clk_pin -source [get_pins {mypll|altpll_component|auto_generated|pll1|clk[1]}] [get_ports {sd_clk}]

#**************************************************************
# Set Clock Latency
#**************************************************************


#**************************************************************
# Set Clock Uncertainty
#**************************************************************

derive_clock_uncertainty;

#**************************************************************
# Set Input Delay
#**************************************************************

set_input_delay -clock sd1clk_pin -max 6.4 [get_ports sd_data*]
set_input_delay -clock sd1clk_pin -min 1.0 [get_ports sd_data*]

#**************************************************************
# Set Output Delay
#**************************************************************

set_output_delay -clock sd1clk_pin -max 1.5 [get_ports sd_*]
set_output_delay -clock sd1clk_pin -min -0.8 [get_ports sd_*]

#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************



#**************************************************************
# Set Multicycle Path
#**************************************************************

set_multicycle_path -from [get_clocks {sd1clk_pin}] -to [get_clocks {mypll|altpll_component|auto_generated|pll1|clk[0]}] -setup -end 2

#set_multicycle_path -from [get_clocks {mypll|altpll_component|auto_generated|pll1|clk[0]}] -to [get_clocks {sd2clk_pin}] -setup -end 2

# set_multicycle_path -setup -to   {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|ram_block1a*~portb_address_reg*} 4
#set_multicycle_path -setup -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -to * -end 4 
#set_multicycle_path -setup -to {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -from * -end 4 
#set_multicycle_path -setup -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -to * -end 4 
#set_multicycle_path -setup -to {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -from * -end 4 
#
#set_multicycle_path -from * -to {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -hold -end 4
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -to * -hold -end 4
#
#set_multicycle_path -from {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -to * -setup -end 4
#set_multicycle_path -to {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -from * -setup -end 4
#set_multicycle_path -from {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -to * -setup -end 4
#set_multicycle_path -to {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -from * -setup -end 4
#
#set_multicycle_path -from * -to {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -hold -end 4
#set_multicycle_path -from * -to {Fampiga:myFampiga|TG68KdotC_Kernel:myhostcpu|altsyncram:regfile_high_rtl_0|altsyncram_qqd1:auto_generated|*} -hold -end 4
#
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|regfile_low_rtl_*} -to * -setup -end 4
#set_multicycle_path -to {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|regfile_low_rtl_*} -from * -setup -end 4
#
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_1|altsyncram_qqd1:auto_generated|ram_block1a0~portb_address_reg0} -to * -setup -end 4
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_1|altsyncram_qqd1:auto_generated|ram_block1a0~portb_address_reg0} -to * -hold -end 4
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_1|altsyncram_qqd1:auto_generated|ram_block1a0~portb_address_reg0} -to * -setup -end 4
#set_multicycle_path -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_high_rtl_1|altsyncram_qqd1:auto_generated|ram_block1a0~portb_address_reg0} -to * -hold -end 4
#
#set_multicycle_path -from * -to {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -hold -end 4
#set_multicycle_path -to * -from {Fampiga:myFampiga|TG68K:MainCPU|TG68KdotC_Kernel:pf68K_Kernel_inst|altsyncram:regfile_low_rtl_0|altsyncram_qqd1:auto_generated|*} -hold -end 4



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************

