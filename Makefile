INSTALL=install
FILES=solpkg.pl make_package
DOCUMENTS=buildrpm.txt
PREFIX=/usr/local
BINDIR=$(PREFIX)/bin
MAN1DIR=$(PREFIX)/man/man1
MAN1FILES=solpkg.pl.1
VERSION=1.2
DESTDIR=
MKTEMP=$(shell which mktemp)
TEMPDIR:=$(shell $(MKTEMP) -d /tmp/solpkg.XXXXXX)
install:
	if [ ! -d $(DESTDIR)$(BINDIR) ];then \
	    mkdir -p $(DESTDIR)$(BINDIR);\
	fi
	if [ ! -d $(DESTDIR)$(MAN1DIR) ];then \
	    mkdir -p $(DESTDIR)$(MAN1DIR);\
	fi
	for file in $(FILES);do \
	    $(INSTALL) $$file $(DESTDIR)$(BINDIR)/$$file; \
	done
	for file in $(MAN1FILES);do \
	    $(INSTALL) $$file $(DESTDIR)$(MAN1DIR)/$$file; \
	done

dist:
	mkdir -p $(TEMPDIR)/solpkg-$(VERSION)
	cp $(DOCUMENTS) $(MAN1FILES) $(FILES) Makefile $(TEMPDIR)/solpkg-$(VERSION)
	tar -cvf solpkg-$(VERSION).tar -C $(TEMPDIR) solpkg-$(VERSION)
	gzip --best solpkg-$(VERSION).tar
	rm -rf $(TEMPDIR)

man:	solpkg.pl
	pod2man solpkg.pl solpkg.pl.1

clean:
	@rm -f *~ solpkg-$(VERSION).tar.gz solpkg.pl.1
