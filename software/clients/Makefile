CLIENTS = perl_client python_client java_client

clients: $(CLIENTS)

$(CLIENTS):
	@$(MAKE) -C $@

clean:
	@-for p in $(CLIENTS); do ($(MAKE) -C $$p clean ); done

.PHONY: clients $(CLIENTS) clean 
