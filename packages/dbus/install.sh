#! /bin/sh

. ../../common.sh

sed -i -e 's/-m 700//g' test/Makefile.in

./configure --prefix=$3 --host=$4 --disable-static --disable-embedded-tests --disable-modular-tests --disable-tests --with-dbus-session-bus-default-address=autolaunch: > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
