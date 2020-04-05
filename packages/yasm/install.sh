#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 > ../config.log 2>&1

#sed -i -e 's|$(top_builddir)/genstring$(EXEEXT) license_msg $@ $(srcdir)/COPYING|echo "static const char *license_msg[] = { \"Yasm\", \"BSD\" };" > license.c|g' Makefile

make -j $jobopt $verbmake install > ../make.log 2>&1
