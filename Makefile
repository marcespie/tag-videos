MAN1DIR=`perl -MConfig -e 'print $$Config{siteman1dir}'`
LIBDIR=`perl -MConfig -e 'print $$Config{sitelib}'`
BINDIR=`perl -MConfig -e 'print $$Config{sitebin}'`


INSTALL_MAN = install -m 644
INSTALL_DIR = install -d -m 755
INSTALL_BIN = install -m 755
INSTALL_DATA = install -m 644

BINS = {tag-videos,view-tags,fix-filenames}
MODS = {Base,Model,Path}

DESTDIR =


install:
	@${INSTALL_BIN} ${BINS} $(DESTDIR)${BINDIR}
	@${INSTALL_MAN} ${BINS}.1 $(DESTDIR)${MAN1DIR}
	@${INSTALL_DIR} $(DESTDIR)${LIBDIR}/TagVideos
	@${INSTALL_DATA} lib/TagVideos/${MODS}.pm $(DESTDIR)${LIBDIR}/TagVideos

uninstall:
	@rm -f $(DESTDIR)${BINDIR}/${BINS}
	@rm -f $(DESTDIR)${MAN1DIR}/${BINS}.1
	@rm -f $(DESTDIR)${LIBDIR}/TagVideos/${MODS}
	@rmdir $(DESTDIR)${LIBDIR}/TagVideos

.PHONY: install uninstall
