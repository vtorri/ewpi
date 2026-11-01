#!/usr/bin/env bash

function f_setup
{
    if [[ -f '/etc/os-release' ]]; then
        source '/etc/os-release'
        case ${ID:?} in
            msys2) return 0 ;;
            debian | ubuntu) sudo bash -c '
                apt-get update
                apt-get install -y clang-{tidy,format} shfmt {cpp,shell}check meson auto{conf,make} {lib,its}tool gettext cmake {y,n}asm gperf python3 perl ninja-build pkgconf g++-mingw-w64-x86-64 libgomp1 gcc nsis bison flex make
            ' ;;
            fedora | alma) sudo dnf install -y shfmt {cpp,shell}check meson auto{conf,make} libtool gettext cmake {y,n}asm gperf python{,3-pip} perl ninja-build pkgconf mingw64-{libgomp,gcc,gcc-c++,nsis} bison flex make gcc-c++ ;;
        esac 1>/dev/null
        shellcheck --external-sources "${0}" #~ packages/*/*.sh
        shfmt -ci -fn -i 4 -d "${0}"         #~ packages/*/*.sh
        #~ clang-tidy --warnings-as-errors=* ewpi*.{c,h}
        #~ clang-format --dry-run --Werror -style=Mozilla ewpi*.{c,h}
    fi
}

set -xeuo pipefail

f_setup

while read -r; do
    command -V "${REPLY}"
done < <(printf '%s\n' x86_64-w64-mingw32-{gcc,g++,ar,nm,ranlib,strip,windres} meson make{,nsis} python perl ninja {y,n}asm gperf wget bison flex)

gcc -W{all,extra,pedantic,shadow,conversion} -O2 -o ewpi{,*.c}

./ewpi --verbose
