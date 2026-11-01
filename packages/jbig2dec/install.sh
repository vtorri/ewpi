#! /bin/sh

. ../../common.sh

sed -i -e "s/bin_PROGRAMS/#bin_PROGRAMS/g;s/jbig2dec_SOURCES/#jbig2dec_SOURCES/g;s/jbig2dec_LDADD/#jbig2dec_LDADD/g" Makefile.in

ewpi_autoconf --disable-static
