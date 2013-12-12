NAME = cube_server
PKG_NAME = $(NAME).tar.gz
DIST_DIR = dist
SRC_DIR = src
DRIVER = $(SRC_DIR)/driver
BUILD_DIR = build
TAR_DIR = $(BUILD_DIR)/$(NAME)
ARTIFACT = $(DIST_DIR)/$(PKG_NAME)
THRIFT_DIRNAME = gen-py
CC = gcc
CFLAGS = -O3

server: clean $(DRIVER)
	@mkdir -p {$(DIST_DIR),$(TAR_DIR)}
	@cp -R ../thrift/$(THRIFT_DIRNAME) $(SRC_DIR)
	@cp -R $(SRC_DIR)/ $(TAR_DIR)
	@tar -czf  $(DIST_DIR)/$(PKG_NAME) -C $(BUILD_DIR) .

$(DRIVER):
	@$(CC) $(CFLAGS) $(DRIVER).c -o $(DRIVER) \
	$(shell pkg-config --cflags --libs libftdi1)

clean:
	@-rm -rf $(DIST_DIR) $(BUILD_DIR)
	@-rm -rf $(SRC_DIR)/$(THRIFT_DIRNAME)
	@-rm -f $(DRIVER)
        # remove .pyc files to prepare clean tarball
	@find . -name "*.pyc" -print0 | xargs -0 rm -rf

.PHONY: clean server
