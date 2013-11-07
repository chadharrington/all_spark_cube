PROGRAM = cube_driver

CC = gcc
CFLAGS = -Wall -Wextra -O3
LDFLAGS = -lftd2xx
SRCS = cube_driver.c

all: $(PROGRAM)

cube_driver: $(CDSRCS)
	@$(CC) $(CFLAGS) $(LDFLAGS) $(SRCS) -o $@

clean:
	@rm -f $(PROGRAM) 
