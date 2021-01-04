#! /bin/sh

. ../../common.sh

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

./configure --prefix=$3 --host=$4 --disable-static --disable-webp --with-zlib-include-dir=$3/include --with-zlib-lib-dir=$3/lib --with-jpeg-include-dir=$3/include --with-jpeg-lib-dir=$3/lib --with-lzma-include-dir=$3/include --with-lzma-lib-dir=$3/lib --disable-cxx > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
