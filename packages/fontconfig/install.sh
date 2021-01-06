#! /bin/sh

. ../../common.sh

sed -i -e 's/po-conf test/po-conf/g' Makefile.in

# for fontconfig DLL
export PATH=${EWPI_PWD}/src/.libs:$PATH

# detection of RM
sed -i -e 's|_predefined_rm=.*$|_predefined_rm=|p' configure

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

./configure --prefix=$3 --host=$4 --disable-static --enable-iconv --with-libiconv=$3 --with-expat=$3 --disable-docs > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
