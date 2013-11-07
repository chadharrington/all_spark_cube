DRIVER = cube_driver
DRIVER_SRCS = cube_driver.c
THRIFT_STUBS = gen-py
THRIFT_SRCS = cube_interface.thrift 

LDFLAGS = -lftd2xx
CFLAGS = -Wall -Wextra -O3
CC = gcc
THRIFT_COMPILER = thrift
THRIFT_COMPILER_FLAGS = -gen py:new_style


all: $(DRIVER) $(THRIFT_STUBS)

$(DRIVER): $(DRIVER_SRCS)
	@$(CC) $(CFLAGS) $(LDFLAGS) $^ -o $@

$(THRIFT_STUBS): $(THRIFT_SRCS)
	@$(THRIFT_COMPILER) $(THRIFT_COMPILER_FLAGS) $^

clean:
	@rm -f $(DRIVER) 
	@rm -rf $(THRIFT_STUBS)
