#! /bin/sh

. ../../common.sh

cd gettext-runtime/intl

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

./configure --prefix=$3 --host=$4 --disable-static --disable-c++ --disable-java --disable-native-java --enable-threads=windows --disable-rpath --disable-libasprintf --disable-curses --disable-acl --with-libiconv-prefix=$3 > ../../config.log 2>&1

make -j $jobopt $verbmake install > ../../make.log 2>&1
