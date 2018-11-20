#! /bin/sh

# $1 : name
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : taropt
# $6 : jobopt

cd packages/$1 > /dev/null
dir_name=`tar t$5 $2 | head -1 | cut -f1 -d"/"`
cd $dir_name

cp include/{regex,glob,fnmatch}.h src/regex

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
    -e 's/(long)/(intptr_t)/g' \
    tre.h

$4-gcc -std=c99 -Wall -Wextra -O2 -shared \
       -o libregex-1.dll -Wl,--out-implib,libregex.dll.a \
       fnmatch.c regcomp.c regerror.c regexec.c tre-mem.c \
       -I. \
       > ../make.log 2>&1

mkdir -p $3/{bin,include,lib}
cp libregex-1.dll $3/bin
cp libregex.dll.a $3/lib

cd ../..

sed '/#include <bits.alltypes.h>/ s/.*/typedef intptr_t regoff_t;/' \
  < include/regex.h \
  > $3/include/regex.h

sed -i -e 's/installed: no/installed: yes/g' ../$1.ewpi
