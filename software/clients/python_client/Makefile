SRC_DIR = all_spark_cube_client
THRIFT_DIR = ../../thrift/gen-py
THRIFT_INTERFACE_DIRNAME = cube_interface
DIST_DIR = $(SRC_DIR)/dist
BUILD_DIR = `find . -name "*.egg-info"`


client: clean
	@cp -R $(THRIFT_DIR)/$(THRIFT_INTERFACE_DIRNAME) $(SRC_DIR)
	@cd $(SRC_DIR); python setup.py sdist -q


clean:
	@rm -rf $(SRC_DIR)/$(THRIFT_INTERFACE_DIRNAME)
	@rm -rf $(DIST_DIR) $(BUILD_DIR)
	@find . -name "*.pyc" -delete


.PHONY: client clean

