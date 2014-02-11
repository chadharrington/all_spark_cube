THRIFT_SRC = cube_interface.thrift 
THRIFT_ARTIFACTS = gen-py gen-perl gen-c_glib gen-cpp gen-java gen-rb
THRIFT_COMPILER = thrift

artifacts: $(THRIFT_ARTIFACTS)


gen-py: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen py:new_style $(THRIFT_SRC)

gen-perl: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen perl $(THRIFT_SRC)

gen-c_glib: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen c_glib $(THRIFT_SRC)

gen-cpp: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen cpp $(THRIFT_SRC)

gen-java: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen java $(THRIFT_SRC)

gen-rb: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen rb $(THRIFT_SRC)

clean:
	@-rm -rf $(THRIFT_ARTIFACTS)


.PHONY: artifacts $(THRIFT_ARTIFACTS) clean
