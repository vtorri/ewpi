#! /bin/sh

. ../../common.sh

LR_CPPFLAGS="-DUSE_JPEG -DUSE_JPEG8 -DUSE_LCMS2 -I. -I$3/include"
LR_CFLAGS="-O3 -w -fopenmp -ljpeg -llcms2"
LR_LDFLAGS="-L$3/lib -s"

make -f Makefile.mingw lib/libraw.a -j $jobopt $verbmake CFLAGS="$LR_CPPFLAGS $LR_CFLAGS" LDADD=$LR_LDFLAGS  > ../make.log 2>&1

g++ -s -shared -Wl,--out-implib,libraw.dll.a \
	-o libraw-0.dll object/*.o -L$3/lib -ljpeg -llcms2 -lws2_32 >> ../make.log 2>&1

cp libraw-0.dll $3/bin
cp libraw.dll.a $3/lib
cp -R libraw $3/include

rm -rf libraw.pc
cp libraw.pc.in libraw.pc
sed -i -e "s|@prefix@|$3|g" libraw.pc
sed -i -e 's|@exec_prefix@|${prefix}|g;s|@libdir@|${exec_prefix}/lib|g;s|@includedir@|${prefix}/include|g;s|@PACKAGE_REQUIRES@|lcms2 libjpeg|g;s|@PACKAGE_VERSION@|0.20.2|g;s|@PC_OPENMP@| -fopenmp|g' libraw.pc
cp libraw.pc $3/lib/pkgconfig
