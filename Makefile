BUILDABLES = \
	asl-statmon \
	asl-cmdlink

ETCS = \
	allmon3.ini

ETCS_EXP = $(patsubst %, $(DESTDIR)/usr/local/etc/%, $(ETCS))

install: $(ETCS_EXP) web
	$(foreach dir, $(BUILDABLES), make -C $(dir) DESTDIR=$(realpath $(DESTDIR));)

$(DESTDIR)/usr/local/etc/%:	%
	-test ! -f $(DESTDIR)/usr/local/etc/allmon3.ini && install -D -m 0755 $< $@

.PHONY: web
web:
	-test ! -d $(DESTDIR)/var/www/html/allmon3 && mkdir -p $(DESTDIR)/var/www/html/allmon3
	rsync -av --exclude "api/passwords.php" --exclude "css/custom.css" web/* $(DESTDIR)/var/www/html/allmon3/
	-test ! -f $(DESTDIR)/var/www/html/allmon3/api/passwords.php && \
		install -m 0644 web/api/passwords.php $(DESTDIR)/var/www/html/allmon3/api/passwords.php
