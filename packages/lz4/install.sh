#! /bin/sh

source ../../common.sh

make -j $5 $verbmake PREFIX=$3 BUILD_STATIC=no CC=$4-gcc WINDRES=$4-windres SHARED_EXT_VER=1 OS=Windows_NT install > ../make.log 2>&1
