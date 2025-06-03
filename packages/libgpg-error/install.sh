#! /bin/sh

. ../../common.sh

./configure --prefix=$3 --host=$4 --disable-static --disable-install-gpg-error-config --disable-doc --disable-tests --disable-languages > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
