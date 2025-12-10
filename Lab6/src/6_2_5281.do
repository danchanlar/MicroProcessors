onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MCPU_Heilstone_5281_tb/reset
add wave -noupdate /MCPU_Heilstone_5281_tb/clk
add wave -noupdate /MCPU_Heilstone_5281_tb/i
add wave -noupdate -radix unsigned {/MCPU_Heilstone_5281_tb/cpuinst/regfileinst/R[4]}
add wave -noupdate -radix unsigned {/MCPU_Heilstone_5281_tb/cpuinst/regfileinst/R[3]}
add wave -noupdate -radix unsigned {/MCPU_Heilstone_5281_tb/cpuinst/regfileinst/R[2]}
add wave -noupdate -radix unsigned {/MCPU_Heilstone_5281_tb/cpuinst/regfileinst/R[1]}
add wave -noupdate -radix unsigned {/MCPU_Heilstone_5281_tb/cpuinst/regfileinst/R[0]}
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {0 ps} 0}
quietly wave cursor active 0
configure wave -namecolwidth 295
configure wave -valuecolwidth 102
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
WaveRestoreZoom {50 ps} {929 ps}
