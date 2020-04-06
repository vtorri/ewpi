#! /bin/sh

. ../../common.sh

sed -i -e 's/<Windows.h>/<windows.h>/g' programs/timefn.h
sed -i -e 's|cp $(PRGDIR)/zstd$(EXT) .|cp $(PRGDIR)/zstd.exe .|g' Makefile

make -j $jobopt CC=$4-gcc WINDRES=$4-windres AR=$4-ar > ../make.log 2>&1
cp lib/dll/libzstd.dll $3/bin
cp lib/dll/libzstd.lib $3/lib/libzstd.dll.a
cp lib/zstd.h lib/common/zstd_errors.h lib/deprecated/zbuff.h lib/dictBuilder/zdict.h $3/include
