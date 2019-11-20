#! /bin/sh

. ../../common.sh

make -j $jobopt CC=$4-gcc WINDRES=$4-windres AR=$4-ar > ../make.log 2>&1
cp lib/dll/libzstd.dll $3/bin
cp lib/dll/libzstd.lib $3/lib/libzstd.dll.a
cp lib/zstd.h lib/common/zstd_errors.h lib/deprecated/zbuff.h lib/dictBuilder/zdict.h $3/include
