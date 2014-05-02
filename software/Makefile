PROJECTS = clients server


projects: $(PROJECTS)

$(PROJECTS):
	@$(MAKE) -C $@

clean:
	@-for p in $(PROJECTS); do ($(MAKE) -C $$p clean ); done


.PHONY: projects $(PROJECTS) clean


