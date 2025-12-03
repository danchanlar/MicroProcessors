onerror {resume}
quietly WaveActivateNextPane {} 0
add wave -noupdate /MCPU_RAMControllertb/we
add wave -noupdate /MCPU_RAMControllertb/re
add wave -noupdate /MCPU_RAMControllertb/datawr
add wave -noupdate /MCPU_RAMControllertb/addr
add wave -noupdate /MCPU_RAMControllertb/instraddr
add wave -noupdate /MCPU_RAMControllertb/datard
add wave -noupdate /MCPU_RAMControllertb/instrrd
add wave -noupdate /MCPU_RAMControllertb/i
add wave -noupdate /MCPU_RAMControllertb/isCorrect
TreeUpdate [SetDefaultTree]
WaveRestoreCursors {{Cursor 1} {492 ps} 0}
quietly wave cursor active 1
configure wave -namecolwidth 205
configure wave -valuecolwidth 52
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
WaveRestoreZoom {490 ps} {504 ps}
