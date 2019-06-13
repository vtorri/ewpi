#! /bin/sh

. ../../common.sh

make -j $5 -f win32/Makefile.gcc clean prefix=$3 PREFIX=$4- STATICLIB= SHARED_MODE=1 SHAREDLIB=zlib-1.dll BINARY_PATH=$3/bin LIBRARY_PATH=$3/lib INCLUDE_PATH=$3/include > ../make.log 2>&1
make -j $5 -f win32/Makefile.gcc install prefix=$3 PREFIX=$4- STATICLIB= SHARED_MODE=1 SHAREDLIB=zlib-1.dll BINARY_PATH=$3/bin LIBRARY_PATH=$3/lib INCLUDE_PATH=$3/include >> ../make.log 2>&1
