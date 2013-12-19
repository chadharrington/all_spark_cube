PROJECTS = thrift clients server


projects: $(PROJECTS)
clients: thrift
server: thrift

$(PROJECTS):
	@$(MAKE) -C $@

install:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p install ); done

uninstall:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p uninstall ); done

clean:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p clean ); done


.PHONY: projects $(PROJECTS) install uninstall clean


