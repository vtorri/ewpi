#! /bin/sh

. ../../common.sh

case ${EWPI_OS} in
    MSYS*|MINGW*)
    ;;
    *)
	rm -rf source_native && cp -r source source_native
	cd source_native
	CWD=$(pwd)
	./runConfigureICU Linux --prefix=$CWD/build --enable-tools --disable-tests --disable-samples > ../../config_unix.log 2>&1
	make -j $jobopt > ../../make_unix.log 2>&1
	cd ..
	cross="--with-cross-build=$CWD"
    ;;
esac

cd source

CXXFLAGS="$CXXFLAGS -fext-numeric-literals"
./runConfigureICU MinGW \
                  --prefix=$3 \
                  --host=$4 \
                  $cross \
                  -enable-release \
                  --enable-shared \
                  --disable-static \
                  --enable-tools \
                  --disable-tests \
                  --disable-samples \
                  > ../../config.log 2>&1

make -j $jobopt > ../../make.log 2>&1
make install >> ../../make.log 2>&1
