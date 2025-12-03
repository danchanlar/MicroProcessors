onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MCPU_reg_tb/reset
add wave -noupdate /MCPU_reg_tb/clk
add wave -noupdate /MCPU_reg_tb/i
add wave -noupdate /MCPU_reg_tb/cpuinst/opcode
add wave -noupdate /MCPU_reg_tb/cpuinst/pc
add wave -noupdate /MCPU_reg_tb/cpuinst/STATE_AS_STR
add wave -noupdate /MCPU_reg_tb/cpuinst/regfileinst/datatoload
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[15]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[14]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[13]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[12]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[11]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[10]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[9]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[8]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[7]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[6]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[5]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[4]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[3]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[2]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[1]}
add wave -noupdate {/MCPU_reg_tb/cpuinst/regfileinst/R[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {829 ps} 0}
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
WaveRestoreZoom {0 ps} {917 ps}
