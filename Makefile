.PHONY: all upload

all: src/* Maze.qsf
	~/intelFPGA_lite/23.1std/quartus/bin/quartus_map --read_settings_files=on --write_settings_files=off Maze -c Maze
	~/intelFPGA_lite/23.1std/quartus/bin/quartus_fit --read_settings_files=off --write_settings_files=off Maze -c Maze
	~/intelFPGA_lite/23.1std/quartus/bin/quartus_asm --read_settings_files=off --write_settings_files=off Maze -c Maze
	~/intelFPGA_lite/23.1std/quartus/bin/quartus_sta Maze -c Maze

upload:
	~/intelFPGA_lite/23.1std/quartus/bin/quartus_pgm -c "USB-Blaster [3-1]" -m JTAG -o p\;output_files/Maze.pof 
