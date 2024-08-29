MAN1DIR=`perl -MConfig -e 'print $$Config{siteman1dir}'`
LIBDIR=`perl -MConfig -e 'print $$Config{sitelib}'`
BINDIR=`perl -MConfig -e 'print $$Config{sitebin}'`


INSTALL_MAN = install -m 644
INSTALL_DIR = install -d -m 755
INSTALL_BIN = install -m 755
INSTALL_DATA = install -m 644

DESTDIR =


install:
	@${INSTALL_BIN} tag-videos $(DESTDIR)${BINDIR}
	@${INSTALL_BIN} view-tags $(DESTDIR)${BINDIR}
	@${INSTALL_MAN} tag-videos.1 $(DESTDIR)${MAN1DIR}
	@${INSTALL_MAN} view-tags.1 $(DESTDIR)${MAN1DIR}
	@${INSTALL_DIR} $(DESTDIR)${LIBDIR}/TagVideos
	@${INSTALL_DATA} lib/TagVideos/Base.pm $(DESTDIR)${LIBDIR}/TagVideos
	@${INSTALL_DATA} lib/TagVideos/Model.pm $(DESTDIR)${LIBDIR}/TagVideos

uninstall:
	@rm -f $(DESTDIR)${BINDIR}/{tag-videos,view-tags}
	@rm -f $(DESTDIR)${MAN1DIR}/{tag-videos,view-tags}.1
	@rm -f $(DESTDIR)${LIBDIR}/TagVideos/{Base.pm,Model.pm}
	@rmdir $(DESTDIR)${LIBDIR}/TagVideos

.PHONY: install uninstall
