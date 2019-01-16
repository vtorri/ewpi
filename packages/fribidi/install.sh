#! /bin/sh

set -e

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

CPPFLAGS="-DFRIBIDI_ENTRY='__declspec(dllexport)'" ./configure --prefix=$3 --host=$4 --disable-static --disable-debug --disable-deprecated > ../config.log 2>&1

make -j $jobopt install > ../make.log 2>&1
