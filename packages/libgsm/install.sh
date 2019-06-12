#! /bin/sh

source ../../common.sh

echo "libgsmdll: \$(GSM_OBJECTS)
	\$(CC) -s \$(LFLAGS) -shared -Wl,--out-implib,libgsm.dll.a -o libgsm-1.dll \$(GSM_OBJECTS)" >> Makefile

make -j $5 $verbmake libgsmdll CC=$4-gcc > ../make.log 2>&1

cp libgsm-1.dll $3/bin
cp libgsm.dll.a $3/lib
cp inc/gsm.h $3/include
