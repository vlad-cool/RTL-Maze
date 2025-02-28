.PHONY: all upload init select_target syntesize

TARGET?=NO_TARGET

all: syntesize upload

ifeq ($(TARGET), C7)
__TARGET__ := EP4CE115F29C7
select_target:
	@echo "$(__TARGET__) selected as target"
else ifeq ($(TARGET), C8)
__TARGET__ := EP4CE6E22C8
select_target:
	@echo "$(__TARGET__) selected as target"
else
select_target:
	$(error TARGET not selected...)
endif

init: select_target
	python create_project.py $(__TARGET__)

syntesize: init
	quartus_map --read_settings_files=on --write_settings_files=off Maze -c Maze
	quartus_fit --read_settings_files=off --write_settings_files=off Maze -c Maze
	quartus_asm --read_settings_files=off --write_settings_files=off Maze -c Maze
	quartus_sta Maze -c Maze

upload:
	quartus_pgm -c "USB-Blaster [3-1]" -m JTAG -o p\;output_files/Maze.sof 
