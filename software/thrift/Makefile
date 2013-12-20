THRIFT_SRC = cube_interface.thrift 
THRIFT_ARTIFACTS = gen-py gen-perl gen-c gen-cpp gen-java gen-ruby
THRIFT_COMPILER = thrift

artifacts: $(THRIFT_ARTIFACTS)


gen-py: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen py:new_style $(THRIFT_SRC)

gen-perl: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen perl $(THRIFT_SRC)

gen-c: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen c_glib $(THRIFT_SRC)

gen-cpp: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen cpp $(THRIFT_SRC)

gen-java: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen java $(THRIFT_SRC)

gen-ruby: clean $(THRIFT_SRC)
	@$(THRIFT_COMPILER) -gen rb $(THRIFT_SRC)

install:
	@echo "Nothing to install..."

uninstall:
	@echo "Nothing to uninstall..."

clean:
	@-rm -rf $(THRIFT_ARTIFACTS)


.PHONY: artifacts $(THRIFT_ARTIFACTS) install uninstall clean
