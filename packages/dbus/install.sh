#! /bin/sh

. ../../common.sh

sed -i -e 's/-m 700//g' test/Makefile.in

./configure --prefix=$3 --host=$4 --disable-static --disable-embedded-tests --disable-modular-tests --disable-tests --disable-relocation --disable-selinux --disable-apparmor --disable-libaudit --disable-inotify --disable-kqueue --disable-launchd --disable-systemd --disable-epoll --disable-x11-autolaunch --with-dbus-session-bus-default-address=autolaunch: > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
