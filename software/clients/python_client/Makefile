SRC_DIR = all_spark_cube_client
DIST_DIR = $(SRC_DIR)/dist
BUILD_DIR = `find . -name "*.egg-info"`


client: clean
	@cd $(SRC_DIR); python setup.py sdist -q


clean:
	@rm -rf $(DIST_DIR) $(BUILD_DIR)
	@find . -name "*.pyc" -delete


.PHONY: client clean

