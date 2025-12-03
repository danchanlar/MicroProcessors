onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MCPU_RAMControllertb2/we
add wave -noupdate /MCPU_RAMControllertb2/re
add wave -noupdate -radix unsigned /MCPU_RAMControllertb2/datawr
add wave -noupdate /MCPU_RAMControllertb2/addr
add wave -noupdate /MCPU_RAMControllertb2/instraddr
add wave -noupdate -radix unsigned /MCPU_RAMControllertb2/datard
add wave -noupdate /MCPU_RAMControllertb2/instrrd
add wave -noupdate /MCPU_RAMControllertb2/i
add wave -noupdate /MCPU_RAMControllertb2/isCorrect
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {517 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 203
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
WaveRestoreZoom {0 ps} {57 ps}
