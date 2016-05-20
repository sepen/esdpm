DESTDIR =

PREFIX = /opt
BINDIR = $(PREFIX)/bin
DATAROOTDIR = $(PREFIX)/esdpm

.PHONY: all install clean

all: esdpm

esdpm: esdpm.bash
	@echo "===> Rendering espdm script ..."
	sed "s|ESDPM_BASE_DIR=.*|ESDPM_BASE_DIR=$(DATAROOTDIR)|" esdpm.bash > esdpm
	chmod +x esdpm

install: esdpm
	@echo "===> Installing ..."
	mkdir -p $(DESTDIR)$(BINDIR)
	install -v -m 0755 esdpm $(DESTDIR)$(BINDIR)/esdpm

clean:
	@echo "===> Cleaning up ..."
	rm -vf esdpm
