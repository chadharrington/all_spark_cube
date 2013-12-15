THRIFT_SRC = cube_interface.thrift 
THRIFT_ARTIFACTS = gen-py gen-perl
THRIFT_COMPILER = thrift

artifacts: $(THRIFT_ARTIFACTS)


gen-py: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen py:new_style $(THRIFT_SRC)

gen-perl: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen perl $(THRIFT_SRC)

clean:
	@-rm -rf $(THRIFT_ARTIFACTS)

.PHONY: clean artifacts
