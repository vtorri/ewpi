#! /bin/sh
# $1 : arch
# $2 : tarname
# $3 : prefix
# $4 : host
# $5 : jobopt
# $6 : verbose
# $7 : winver

ewpi_arch=$1
ewpi_tarname=$2
ewpi_prefix=$3
ewpi_host=$4
jobopt=$5
verbose=$6

set -e

unset PKG_CONFIG_PATH

EWPI_OS=$(uname)
case "${EWPI_OS}" in
    MSYS* | MINGW*)
        prefix_unix=$(cygpath -u "${ewpi_prefix}")
        ;;
    *)
        prefix_unix=${ewpi_prefix}
        ;;
esac

if test "x$7" = "xwin7"; then
    winver="0x0601"
else
    winver="0x0A00"
fi

export PATH="${prefix_unix}/bin:${PATH}"
export PKG_CONFIG_DIR=
export PKG_CONFIG_LIBDIR="${ewpi_prefix}/lib/pkgconfig"
export PKG_CONFIG_SYSROOT_DIR="${ewpi_prefix}"
export CPPFLAGS="-D__USE_MINGW_ANSI_STDIO=0 -D_WIN32_WINNT=${winver} -I${ewpi_prefix}/include"
export CFLAGS="-O2 -pipe -march=${ewpi_arch}"
export CXXFLAGS="-O2 -pipe -march=${ewpi_arch}"
export LDFLAGS="-L${ewpi_prefix}/lib -s"

if test "x${jobopt}" = "xno"; then
    jobopt=""
fi

if test "x${verbose}" = "xyes"; then
    verbmake="V=1"
    verbcmake="ON"
    verbninja="-v"
    verbff="V=1"
else
    verbmake="V=0"
    verbcmake="OFF"
    verbninja=""
    verbff=""
fi

export verbmake verbcmake verbninja verbff
export ewpi_arch ewpi_tarname ewpi_prefix ewpi_host jobopt verbose winver prefix_unix

# Recipes run from $prefix/share/ewpi/packages/<name>. This file and
# drivers.sh are both two directories above that, matching the layout
# under packages/ in the repository.
# shellcheck source=../../drivers.sh
. ../../drivers.sh

case "${ewpi_tarname}" in
    *.git)
        bn=$(basename "${ewpi_tarname}")
        dir_name=${bn%.*}
        ;;
    *.xz | *.lzma | *.lz)
        dir_name=$(tar tJf "${ewpi_tarname}" | head -1 | cut -f1 -d"/")
        ;;
    *.bz2)
        dir_name=$(tar tjf "${ewpi_tarname}" | head -1 | cut -f1 -d"/")
        ;;
    *.gz | *.tgz)
        dir_name=$(tar tzf "${ewpi_tarname}" | head -1 | cut -f1 -d"/")
        ;;
esac

cd "${dir_name}" || exit

EWPI_PWD="$(pwd)"
export EWPI_PWD
