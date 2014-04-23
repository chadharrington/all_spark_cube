NAME = cube_server
DIST_DIR = dist
INSTALL_DIR = /opt/adaptive/cube
DRIVER_NAME = cube_driver
SERVER_NAME = cube_server
PEEKER_NAME = peek_shmem
RULES_FILE = 99-libftdi.rules
RULES_DEST =  /etc/udev/rules.d/$(RULES_FILE)
CUBE_INIT_FILE = initialization.bin
SUPERVISORD_INIT = supervisord_init_script
SUPERVISORD_INIT_DEST = /etc/rc.d/init.d/supervisord
SUPERVISORD_CONF = supervisord.conf
SUPERVISORD_CONF_DEST = /etc/$(SUPERVISORD_CONF)
CC = gcc
CFLAGS = -O3 -Wall

all: server driver peeker

server: $(DIST_DIR)/$(SERVER_NAME)

driver: $(DIST_DIR)/$(DRIVER_NAME)

peeker: $(DIST_DIR)/$(PEEKER_NAME)

$(DIST_DIR)/$(DRIVER_NAME): $(DRIVER_NAME).c
	@mkdir -p $(DIST_DIR)
	@$(CC) $(CFLAGS) $<  -o $(DIST_DIR)/$(DRIVER_NAME) \
	    $(shell pkg-config --cflags --libs libftdi1)

 $(DIST_DIR)/$(SERVER_NAME): $(SERVER_NAME).c
	@mkdir -p $(DIST_DIR)
	@$(CC) $(CFLAGS) $< -o $@

 $(DIST_DIR)/$(PEEKER_NAME): $(PEEKER_NAME).c
	@mkdir -p $(DIST_DIR)
	@$(CC) $(CFLAGS) $< -o $@

install: driver server
	@mkdir -p $(INSTALL_DIR)
	@cp $(DIST_DIR)/$(DRIVER_NAME) $(INSTALL_DIR)
	@chmod ugo+x $(INSTALL_DIR)/$(DRIVER_NAME)
	@cp $(DIST_DIR)/$(SERVER_NAME) $(INSTALL_DIR)
	@chmod ugo+x $(INSTALL_DIR)/$(SERVER_NAME)
	@cp $(RULES_FILE) $(RULES_DEST)
	@chmod 644 $(RULES_DEST)
	@cp $(CUBE_INIT_FILE) $(INSTALL_DIR)
	@cp $(SUPERVISORD_INIT) $(SUPERVISORD_INIT_DEST)
	@chmod 755 $(SUPERVISORD_INIT_DEST)
	@cp $(SUPERVISORD_CONF) $(SUPERVISORD_CONF_DEST)
	@chmod 644 $(SUPERVISORD_CONF_DEST)

uninstall: clean
	@rm -rf $(INSTALL_DIR)
	@rm $(RULES_DEST)
	@rm $(SUPERVISORD_INIT_DEST)
	@rm $(SUPERVISORD_CONF_DEST)

clean:
	@-rm -rf $(DIST_DIR)


.PHONY: all driver server peeker install uninstall clean
