#! /bin/sh

. ../../common.sh

export CPPFLAGS="-DFRIBIDI_ENTRY='__declspec(dllexport)'"

./configure --prefix=$3 --host=$4 --disable-static --disable-debug --disable-deprecated > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
