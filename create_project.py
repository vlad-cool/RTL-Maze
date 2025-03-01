from sys import argv
import os

if(len(argv) < 2):
    print("You should enter FPGA name...")
    exit(-1)

with open("Maze.qsf", "w") as file:
    file.write("set_global_assignment -name FAMILY \"Cyclone IV E\"\n")
    file.write(f"set_global_assignment -name DEVICE {argv[1]}\n")
    file.write("set_global_assignment -name TOP_LEVEL_ENTITY Maze\n")
    file.write("set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files\n")
    file.write("set_global_assignment -name VERILOG_MACRO \"PLAYER_SPEED_FACTOR=32\"\n")
    for root, dirs, src_files in os.walk("src"):
        for src_file in src_files:
            if src_file[-2:] != '.v':
                continue
            file.write(f"set_global_assignment -name VERILOG_FILE {os.path.join(root, src_file)}\n")
    with open(f"pins_config/{argv[1]}.txt", "r") as config:
        file.write(config.read())
