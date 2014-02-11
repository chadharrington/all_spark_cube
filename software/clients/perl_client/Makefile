NAME = cube_perl_client
PKG_NAME = $(NAME).tar.gz
DIST_DIR = dist
SRC_DIR = src
BUILD_DIR = build
TAR_DIR = $(BUILD_DIR)/$(NAME)
ARTIFACT = $(DIST_DIR)/$(PKG_NAME)
THRIFT_DIRNAME = gen-perl
SRCS = $(SRC_DIR)/AllSparkCubeClient.pm $(SRC_DIR)/client_demo.pl

client: $(SRCS) clean
	@mkdir -p {$(DIST_DIR),$(TAR_DIR)}
	@cp -R ../../thrift/$(THRIFT_DIRNAME) $(SRC_DIR)	
	@cp -R $(SRC_DIR)/ $(TAR_DIR)
	@tar -czf  $(DIST_DIR)/$(PKG_NAME) -C $(BUILD_DIR) .

clean:
	@-rm -rf $(DIST_DIR) $(BUILD_DIR)
	@-rm -rf $(SRC_DIR)/$(THRIFT_DIRNAME)


.PHONY: client install uninstall clean
