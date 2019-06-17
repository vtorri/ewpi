#! /bin/sh

. ../../common.sh

make -j $jobopt $verbmake PREFIX=$3 BUILD_STATIC=no CC=$4-gcc WINDRES=$4-windres SHARED_EXT_VER=1 TARGET_OS=Windows_NT OS=Windows_NT install > ../make.log 2>&1
