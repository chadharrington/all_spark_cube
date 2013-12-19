PROJECTS = thrift clients server


projects: $(PROJECTS)
clients: thrift
server: thrift

$(PROJECTS):
	@$(MAKE) -C $@

clean:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p clean ); done

install:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p install ); done

.PHONY: projects $(PROJECTS) clean install


