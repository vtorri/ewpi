#! /bin/sh

. ../../common.sh

cp include/{regex,glob}.h src/regex

cd src/regex

mkdir -p bits
cat >> bits/alltypes.h << EOF
#include <stdint.h>
typedef intptr_t regoff_t;
#define CHARCLASS_NAME_MAX 14
#define LCTRANS_CUR(msg) (msg)
#define RE_DUP_MAX 255
EOF

sed -i \
    -e '/#include <features.h>/ d' \
    -e '/#include "locale_impl.h"/ d' \
    -e '/#include "libc.h"/ d' \
    *.h *.c ../../include/regex.h

sed -i \
    -e 's/define _REGEX_H/define _REGEX_H\n\n#include <stdlib.h>/g' \
    ../../include/regex.h

sed -i \
    -e 's/(long)/(intptr_t)/g' \
    tre.h

sed -i \
    -e 's/hidden //g' \
    tre.h

$4-gcc -std=c99 -Wall -Wextra -O2 -pipe -march=$1 -s -shared \
       -o libregex-1.dll -Wl,--out-implib,libregex.dll.a \
       regcomp.c regerror.c regexec.c tre-mem.c \
       -I. \
       > ../../../make.log 2>&1

mkdir -p $3/{bin,include,lib}
$4-strip libregex-1.dll
cp libregex-1.dll $3/bin
cp libregex.dll.a $3/lib

cd ../..

sed '/#include <bits.alltypes.h>/ s/.*/typedef intptr_t regoff_t;/' \
  < include/regex.h \
  > $3/include/regex.h
