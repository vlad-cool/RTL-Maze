SRC_DIR = ../src
OBJ_DIR = obj_dir
INCLUDE = include

# Replace delay with mock
SRC := $(wildcard $(SRC_DIR)/*.v)
SRC := $(filter-out $(SRC_DIR)/delay.v, $(SRC))
SRC += nodelay.v
SRC += $(wildcard $(SRC_DIR)/layouts/*.v)

CPP_SRC = $(wildcard $(OBJ_DIR)/*.cpp)
CPP_SRC += sim.cpp drawing_task.cpp
CPP_SRC += $(INCLUDE)/verilated.cpp

all: verilate compile
	./sim

verilate:
	verilator --cc $(SRC) --Wno-lint --top-module Maze  --Mdir $(OBJ_DIR)

compile:
	g++ $(CPP_SRC) -I$(INCLUDE) -lsfml-window -lsfml-graphics -lsfml-system -osim
