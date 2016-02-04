SHELL := /bin/bash

# Dependency Versions
VERSION?=1.21
RELEASEVER?=1

# Bash data
SCRIPTPATH=$(shell pwd -P)
CORES=$(shell grep -c ^processor /proc/cpuinfo)
RELEASE=$(shell lsb_release --codename | cut -f2)

major=$(shell echo $(VERSION) | cut -d. -f1)
minor=$(shell echo $(VERSION) | cut -d. -f2)
micro=$(shell echo $(VERSION) | cut -d. -f3)

build: clean libgpgerror

clean:
	rm -rf /tmp/libgpg-error-$(VERSION).tar.bz2
	rm -rf /tmp/libgpg-error-$(VERSION)

libgpgerror:
	cd /tmp && \
	wget ftp://ftp.gnupg.org/gcrypt/libgpg-error/libgpg-error-$(VERSION).tar.bz2 && \
	tar -xf libgpg-error-$(VERSION).tar.bz2 && \
	cd libgpg-error-$(VERSION) && \
	mkdir -p /usr/share/man/libgpg-error-$(VERSION) && \
	./configure \
	    --prefix=/usr/local \
	    --mandir=/usr/share/man/libgpg-error-$(VERSION) \
	    --infodir=/usr/share/info/libgpg-error-$(VERSION) \
	    --docdir=/usr/share/doc/libgpg-error-$(VERSION) && \
	make -j$(CORES) && \
	make install

package:
	cd /tmp/libgpg-error-$(VERSION) && \
	checkinstall \
	    -D \
	    --fstrans \
	    -pkgrelease "$(RELEASEVER)"-"$(RELEASE)" \
	    -pkgrelease "$(RELEASEVER)"~"$(RELEASE)" \
	    -pkgname "libgpg-error" \
	    -pkglicense GPLv3 \
	    -pkggroup GPG \
	    -maintainer charlesportwoodii@ethreal.net \
	    -provides "libgpg-error-$(VERSION)" \
	    -pakdir /tmp \
	    -y