
ifndef PREFIX
	PREFIX = /usr/local
endif
ifndef MANPREFIX
	MANPREFIX = $(PREFIX)/share/man
endif

install: bin/ttParser
	mkdir -p $(DESTDIR)$(PREFIX)/bin
	cp -f bin/splanNotify bin/ttParser $(DESTDIR)$(PREFIX)/bin/
	chmod 755 $(DESTDIR)$(PREFIX)/bin/splanNotify $(DESTDIR)$(PREFIX)/bin/spanNotify
	mkdir -p $(DESTDIR)$(MANPREFIX)/man1
	cp -f splanNotify.1 $(DESTDIR)$(MANPREFIX)/man1/splanNotify.1
	chmod 644 $(DESTDIR)$(MANPREFIX)/man1/splanNotify.1


uninstall:
	rm -f $(DESTDIR)$(PREFIX)/bin/splanNotify $(DESTDIR)$(PREFIX)/bin/ttParser
	rm -f $(DESTDIR)$(MANPREFIX)/man1/splanNotify.1

ttParser: bin/ttParser

bin/ttParser: src/ttParser.c
	$(CC) $^ -o $@

.PHONY: install uninstall ttParser
