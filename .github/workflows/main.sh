#!/usr/bin/env bash
# lint  — shellcheck, shfmt, clang-format, clang-tidy, host compile, --help
# smoke — cross-build the zlib recipe only (Ubuntu and MSYS2)
# all   — both, when the host can do both

mode=${1:-all}

set -euo pipefail

is_msys=0
if [[ -n ${MSYSTEM:-} || ${OSTYPE:-} == msys* ]]; then
    is_msys=1
fi

f_setup_lint()
{
    if [[ ! -f /etc/os-release ]]; then
        return 0
    fi
    # shellcheck disable=SC1091
    set +u
    source /etc/os-release
    set -u
    case ${ID:?} in
        msys2) return 0 ;;
        debian | ubuntu)
            sudo apt-get update
            sudo apt-get install -y \
                clang-tidy shfmt shellcheck gcc
            ;;
        fedora | alma)
            sudo dnf install -y \
                clang-tools-extra clang shfmt shellcheck gcc
            ;;
        *)
            echo "unsupported distro: ${ID}" >&2
            return 1
            ;;
    esac
}

f_setup_smoke()
{
    if [[ ! -f /etc/os-release ]]; then
        return 0
    fi
    # shellcheck disable=SC1091
    set +u
    source /etc/os-release
    set -u
    case ${ID:?} in
        msys2) return 0 ;;
        debian | ubuntu)
            sudo apt-get update
            sudo apt-get install -y \
                meson autoconf automake libtool itstool gettext \
                cmake yasm nasm gperf python3 perl ninja-build pkgconf \
                g++-mingw-w64-x86-64 libgomp1 gcc nsis bison flex make
            ;;
        fedora | alma)
            sudo dnf install -y \
                meson autoconf automake libtool gettext cmake yasm nasm gperf \
                python python3-pip perl ninja-build pkgconf \
                mingw64-libgomp mingw64-gcc mingw64-gcc-c++ mingw64-nsis \
                bison flex make gcc-c++ itstool
            ;;
        *)
            echo "unsupported distro: ${ID}" >&2
            return 1
            ;;
    esac
}

f_lint()
{
    if [[ ${is_msys} -eq 1 ]]; then
        echo "lint runs on Ubuntu; skipping on MSYS2"
        return 0
    fi

    f_setup_lint

    shellcheck --severity=error --external-sources --source-path=SCRIPTDIR \
        "${0}" common.sh drivers.sh packages/*/*.sh efl_nsis.sh ewpi_nsis.sh
    shellcheck --severity=warning --external-sources --source-path=SCRIPTDIR \
        "${0}" common.sh drivers.sh packages/*/*.sh efl_nsis.sh ewpi_nsis.sh
    shfmt -ci -fn -i 4 -d \
        "${0}" common.sh drivers.sh packages/*/*.sh efl_nsis.sh ewpi_nsis.sh

    # clang-format is available for local use (.clang-format). The historical
    # sources are not a single clang-format style, so this job does not fail
    # on drift. clang-tidy is required.
    clang-tidy --config-file=.clang-tidy \
        ewpi.c ewpi_map.c ewpi_spawn.c -- \
        -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wconversion

    gcc -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -O2 \
        -o ewpi ewpi.c ewpi_map.c ewpi_spawn.c
    ./ewpi --help >/dev/null
}

f_smoke()
{
    local -a tools
    local prefix dll ewpi_bin

    if [[ ${is_msys} -eq 0 ]]; then
        f_setup_smoke
        tools=(
            x86_64-w64-mingw32-gcc
            x86_64-w64-mingw32-g++
            x86_64-w64-mingw32-nm
            x86_64-w64-mingw32-ranlib
            x86_64-w64-mingw32-strip
            x86_64-w64-mingw32-windres
            x86_64-w64-mingw32-dlltool
            meson cmake make makensis python perl ninja yasm nasm gperf wget bison flex
        )
        prefix="$(pwd)/ewpi-prefix"
    else
        # MINGW64 names the compiler gcc. ewpi copies it to the triplet name.
        tools=(gcc g++ ar nm ranlib strip windres dlltool meson cmake make makensis python perl ninja yasm nasm gperf wget bison flex)
        prefix="$(cygpath -m "$(pwd)/ewpi-prefix")"
    fi

    local tool
    for tool in "${tools[@]}"; do
        command -V "${tool}"
    done

    # A previously checked-in Linux ewpi binary must not shadow the one
    # just built. On MSYS2, gcc -o ewpi writes ewpi.exe and leaves an
    # extensionless file alone, so ./ewpi would try to run that ELF.
    rm -f ewpi ewpi.exe
    gcc -std=c99 -Wall -Wextra -Wpedantic -Wshadow -Wconversion -O2 \
        -o ewpi ewpi.c ewpi_map.c ewpi_spawn.c
    if [[ ${is_msys} -eq 1 ]]; then
        local gccdir tool tooldir

        # gcc.exe finds cc1 relative to its own directory. Modern MinGW
        # already installs the triplet name as the same file; only copy
        # when that name is missing.
        gccdir="$(dirname "$(command -v gcc)")"
        for tool in gcc g++ ar dlltool nm ranlib strip windres; do
            src="${gccdir}/${tool}.exe"
            dest="${gccdir}/x86_64-w64-mingw32-${tool}.exe"
            if [[ ! -e ${dest} ]]; then
                cp -f "${src}" "${dest}"
            fi
        done
        tooldir="$(cygpath -w "${gccdir}")"
        export EWPI_TOOLDIR="${tooldir}"
        ewpi_bin=./ewpi.exe
    else
        ewpi_bin=./ewpi
    fi
    "${ewpi_bin}" --help >/dev/null
    if ! "${ewpi_bin}" --package=zlib --prefix="${prefix}" --jobs=2; then
        echo "ewpi failed; recipe logs:" >&2
        find "${prefix}" -name '*.log' -exec tail -n 60 {} \; >&2 || true
        return 1
    fi

    dll="${prefix}/bin/zlib-1.dll"
    if [[ ! -f ${dll} ]]; then
        echo "zlib smoke build did not produce ${dll}" >&2
        find "${prefix}" -maxdepth 3 -type f -print >&2 || true
        return 1
    fi
}

case ${mode} in
    lint) f_lint ;;
    smoke) f_smoke ;;
    all)
        f_lint
        f_smoke
        ;;
    *)
        echo "usage: $0 [lint|smoke|all]" >&2
        exit 2
        ;;
esac
