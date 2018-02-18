#!/usr/bin/make -f

SYSNAME=cmanager

configure: configure-stamp

configure-stamp:
	touch configure-stamp

build: build-stamp

build-stamp: configure-stamp 
	touch build-stamp

clean:
	rm -f build-stamp configure-stamp *~

install:
	cp usr/bin/$(SYSNAME) $(DESTDIR)/usr/bin
	cp -ar usr/share/cmanager $(DESTDIR)/usr/share/${SYSNAME}
	cp -ar var/lib/cmanager $(DESTDIR)/var/lib/${SYSNAME}
	cp -ar etc/cmanager $(DESTDIR)/etc/${SYSNAME}
	cp etc/cron.d/$(SYSNAME) $(DESTDIR)/etc/cron.d/

.PHONY: build clean install configure
