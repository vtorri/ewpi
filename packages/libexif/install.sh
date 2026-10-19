#! /bin/sh

. ../../common.sh

sed -i -e "s/lt_cv_deplibs_check_method='file_magic ^x86 archive import|^x86 DLL'/lt_cv_deplibs_check_method=pass_all/g" configure

ewpi_autoconf --disable-static --disable-internal-docs --disable-ship-binaries --disable-docs
