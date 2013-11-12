
NAME = perl_client
PKG_NAME = $(NAME).tar.gz
DIST_DIR = dist
SRC_DIR = src
ARTIFACT = $(DIST_DIR)/$(PKG_NAME)
THRIFT_DIRNAME = gen-perl
SRCS = $(SRC_DIR)/AllSparkCubeClient.pm $(SRC_DIR)/client_demo.pl

client: $(SRCS) clean
	@mkdir -p $(DIST_DIR)
	@cp -R ../../thrift/$(THRIFT_DIRNAME) $(SRC_DIR)
	@mkdir -p $(DIST_DIR)
	@tar -czf $(DIST_DIR)/$(PKG_NAME) $(SRC_DIR)

clean:
	@-rm -f $(ARTIFACT)
	@-rm -rf $(SRC_DIR)/$(THRIFT_DIRNAME)


.PHONY: clean client
