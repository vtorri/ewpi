#! /bin/sh

. ../../common.sh

if test "x$4" = "xi686-w64-mingw32"; then
    cpu=x86
else
    cpu=x86-64
fi

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

ewpi_autoconf --disable-static --with-cpu=$cpu --enable-int-quality --with-audio=win32_wasapi
