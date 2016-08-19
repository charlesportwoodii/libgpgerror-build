SHELL := /bin/bash

# Dependency Versions
VERSION?=1.24
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
	mkdir -p /usr/share/man/libgpg-error/$(VERSION) && \
	./configure \
	    --prefix=/usr/local \
	    --mandir=/usr/share/man/libgpg-error/$(VERSION) \
	    --infodir=/usr/share/info/libgpg-error/$(VERSION) \
	    --docdir=/usr/share/doc/libgpg-error/$(VERSION) && \
	make -j$(CORES) && \
	make install

fpm_debian:
	echo "Packaging libgpg-error for Debian"

	cd /tmp/libgpg-error-$(VERSION) && make install DESTDIR=/tmp/libgpg-error-$(VERSION)-install

	fpm -s dir \
		-t deb \
		-n libgpg-error \
		-v $(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2) \
		-C /tmp/libgpg-error-$(VERSION)-install \
		-p libgpg-error_$(VERSION)-$(RELEASEVER)~$(shell lsb_release --codename | cut -f2)_$(shell arch).deb \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libgpg-error-build \
		--description "libgpg-error" \
		--deb-systemd-restart-after-upgrade

fpm_rpm:
	echo "Packaging libgpg-error for RPM"

	cd /tmp/libgpg-error-$(VERSION) && make install DESTDIR=/tmp/libgpg-error-$(VERSION)-install

	fpm -s dir \
		-t rpm \
		-n libgpg-error \
		-v $(VERSION)_$(RELEASEVER) \
		-C /tmp/libgpg-error-$(VERSION)-install \
		-p libgpg-error_$(VERSION)-$(RELEASEVER)_$(shell arch).rpm \
		-m "charlesportwoodii@erianna.com" \
		--license "GPLv3" \
		--url https://github.com/charlesportwoodii/libgpg-error-build \
		--description "libgpg-error" \
		--vendor "Charles R. Portwood II" \
		--rpm-digest sha384 \
		--rpm-compression gzip
