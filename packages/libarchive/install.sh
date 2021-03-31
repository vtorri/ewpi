#! /bin/sh

. ../../common.sh

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

./configure --prefix=$3 --host=$4 --disable-static --enable-bsdtar=shared --enable-bsdcat=shared --enable-bsdcpio=shared --without-xml2 --with-expat --without-nettle > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
