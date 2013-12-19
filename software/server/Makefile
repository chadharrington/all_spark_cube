NAME = cube_server
BUILD_DIR = build
INSTALL_DIR = /opt/adaptive/cube
THRIFT_DIR = ../thrift
PYTHON_THRIFT_DIR = gen-py
DRIVER_NAME = driver
SERVER_FILE = cube_server.py
RULES_FILE = 99-libftdi.rules
INIT_FILE = initialization.bin
CC = gcc
CFLAGS = -O3

all: clean server $(DRIVER) 

server: 
	@$(CC) $(CFLAGS) $(DRIVER_NAME).c -o $(BUILD_DIR)/$(DRIVER_NAME) \
	    $(shell pkg-config --cflags --libs libftdi1)
	@cp $(SERVER_FILE) $(BUILD_DIR)
	@cp -R $(THRIFT_DIRNAME)/$(PYTHON_THRIFT_DIR) $(BUILD_DIR)	
	@cp $(RULES_FILE) $(BUILD_DIR)
	@cp $(INIT_FILE) $(BUILD_DIR)

clean:
	@find . -name "*.pyc" -print0 | xargs -0 rm -rf
	@-rm -rf $(BUILD_DIR)
	@mkdir -p $(BUILD_DIR)

install: all


.PHONY: all server clean  install
