#! /bin/sh

. ../../common.sh

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
	sed -i -e 's/AC_FUNC_MALLOC//g;s/AC_FUNC_REALLOC//g;s/HW_FUNC_VSNPRINTF//g;s/HW_FUNC_SNPRINTF//g' configure.ac
	autoreconf -vif
    ;;
esac

export LIBS="-lregex $LIBS"

./configure --prefix=$3 --host=$4 --disable-static --disable-subunit > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
