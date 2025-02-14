SRC_DIR = ../src

# Replace delay with mock
SRC := $(wildcard $(SRC_DIR)/*.v)
SRC := $(filter-out $(SRC_DIR)/delay.v, $(SRC))
SRC += nodelay.v
SRC += $(wildcard $(SRC_DIR)/layouts/*.v)

all:
	verilator --cc $(SRC) --Wno-lint --top-module Maze
