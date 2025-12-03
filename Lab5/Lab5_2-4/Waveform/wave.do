onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MCPU_reg_tb/reset
add wave -noupdate /MCPU_reg_tb/clk
add wave -noupdate /MCPU_reg_tb/file
add wave -noupdate /MCPU_reg_tb/i
add wave -noupdate /MCPU_reg_tb/memi
add wave -noupdate /MCPU_reg_tb/cpuinst/opcode
add wave -noupdate /MCPU_reg_tb/cpuinst/operand1
add wave -noupdate /MCPU_reg_tb/cpuinst/operand2
add wave -noupdate /MCPU_reg_tb/cpuinst/operand3
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[215]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[214]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[213]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[212]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[211]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[210]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[209]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[208]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[207]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[206]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[205]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[204]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[203]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[202]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[201]}
add wave -noupdate -radix unsigned {/MCPU_reg_tb/cpuinst/raminst/mem[200]}
add wave -noupdate -radix unsigned -childformat {{{/MCPU_reg_tb/cpuinst/regfileinst/R[15]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[14]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[13]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[12]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[11]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[10]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[9]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[8]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[7]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[6]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[5]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[4]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[3]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[2]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[1]} -radix unsigned} {{/MCPU_reg_tb/cpuinst/regfileinst/R[0]} -radix unsigned}} -expand -subitemconfig {{/MCPU_reg_tb/cpuinst/regfileinst/R[15]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[14]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[13]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[12]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[11]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[10]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[9]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[8]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[7]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[6]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[5]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[4]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[3]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[2]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[1]} {-height 15 -radix unsigned} {/MCPU_reg_tb/cpuinst/regfileinst/R[0]} {-height 15 -radix unsigned}} /MCPU_reg_tb/cpuinst/regfileinst/R
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 251
configure wave -valuecolwidth 100
configure wave -justifyvalue left
configure wave -signalnamewidth 0
configure wave -snapdistance 10
configure wave -datasetprefix 0
configure wave -rowmargin 4
configure wave -childrowmargin 2
configure wave -gridoffset 0
configure wave -gridperiod 1
configure wave -griddelta 40
configure wave -timeline 0
configure wave -timelineunits ps
update
WaveRestoreZoom {0 ps} {3400 ps}
