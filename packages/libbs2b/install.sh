#! /bin/sh

. ../../common.sh

sed -i -e 's/libbs2b_la_LDFLAGS =/libbs2b_la_LDFLAGS = -no-undefined/g' src/Makefile.in
case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
	sed -i -e 's/AC_FUNC_MALLOC//' configure.ac
    ;;
esac

./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
