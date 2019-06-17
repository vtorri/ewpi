#! /bin/sh

. ../../common.sh

awk_ver=`awk -V |head -1|cut -f1 -d"."|cut -f3 -d " "`
if test "x${awk_ver}" = "x5" ; then
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' lang/cl/mkerrcodes.awk
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' src/mkerrcodes.awk
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' src/mkerrcodes1.awk
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' src/mkerrcodes2.awk
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' src/mkerrnos.awk
    sed -i -e 's|sub (/\#.+/, "");|sub (/#.+/, "");|g' src/mkstrtable.awk
    sed -i -e 's|namespace|pkg_namespace|g' src/Makefile.in
    sed -i -e 's|namespace|pkg_namespace|g' src/mkstrtable.awk
fi

./configure --prefix=$3 --host=$4 --disable-static > ../config.log 2>&1

make -j $jobopt $verbmake install > ../make.log 2>&1
