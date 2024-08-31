MAN1DIR=`perl -MConfig -e 'print $$Config{siteman1dir}'`
LIBDIR=`perl -MConfig -e 'print $$Config{sitelib}'`
BINDIR=`perl -MConfig -e 'print $$Config{sitebin}'`


INSTALL_MAN = install -m 644
INSTALL_DIR = install -d -m 755
INSTALL_BIN = install -m 755
INSTALL_DATA = install -m 644

# with this construction, you can't have a binary without a manpage !
BINS = tag-videos view-tags fix-filenames merge-tags
MANS = ${BINS:=.1}
MODULES = {Base,Model,Path}.pm

DESTDIR =


install:
	@${INSTALL_BIN} ${BINS} $(DESTDIR)${BINDIR}
	@${INSTALL_MAN} ${MANS} $(DESTDIR)${MAN1DIR}
	@${INSTALL_DIR} $(DESTDIR)${LIBDIR}/TagVideos
	@${INSTALL_DATA} lib/TagVideos/${MODULES} $(DESTDIR)${LIBDIR}/TagVideos

uninstall:
	@rm -f $(DESTDIR)${BINDIR}/${BINS}
	@rm -f $(DESTDIR)${MAN1DIR}/${MANS}
	@rm -f $(DESTDIR)${LIBDIR}/TagVideos/${MODULES}
	@rmdir $(DESTDIR)${LIBDIR}/TagVideos

.PHONY: install uninstall
