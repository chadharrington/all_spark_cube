CLIENTS = perl_client python_client

clients: $(CLIENTS)

$(CLIENTS):
	@$(MAKE) -C $@

clean:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p clean ); done

install:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p install ); done

.PHONY: clients $(CLIENTS) install clean 
