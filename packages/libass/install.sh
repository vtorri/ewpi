#! /bin/sh

. ../../common.sh

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

CPPFLAGS="$CPPFLAGS -I$HOME/ewpi_64/include -I$HOME/ewpi_64/include/fribidi -I$HOME/ewpi_64/include/freetype2 -I$HOME/ewpi_64/include/harfbuzz" ./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
