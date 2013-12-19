CLIENTS = perl_client python_client

clients: $(CLIENTS)

$(CLIENTS):
	@$(MAKE) -C $@

install:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p install ); done

uninstall:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p uninstall ); done

clean:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p clean ); done


.PHONY: clients $(CLIENTS) install uninstall clean 
