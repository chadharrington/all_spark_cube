PKG = com/allsparkcube
THRIFT_DIR = ../../../thrift/gen-java/$(PKG)
THRIFT_INTERFACE_FILE = CubeInterface.java
SRC_DIR = src/main/java/$(PKG)

client: clean
	@cp $(THRIFT_DIR)/$(THRIFT_INTERFACE_FILE) $(SRC_DIR)
	@mvn package

clean:
	@-rm $(SRC_DIR)/$(THRIFT_INTERFACE_FILE)
	@mvn clean

.PHONY: client clean

