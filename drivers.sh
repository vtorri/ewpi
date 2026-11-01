#! /bin/sh
# shellcheck disable=SC2154
# Shared cmake / meson / autotools drivers.
# common.sh sets ewpi_arch, ewpi_prefix, ewpi_host, jobopt, winver and the
# verb* variables before sourcing this file. Extra arguments are passed
# through unchanged. cmake and meson run in a subshell so later recipe
# steps stay in the source tree. ewpi_autoconf does not change directory.

ewpi_prep_cross()
{
    if test "x${ewpi_host}" = "xx86_64-w64-mingw32"; then
        proc="AMD64"
        cpu_family="x86_64"
        cpu="x86_64"
    else
        proc="X86"
        cpu_family="x86"
        cpu="i686"
    fi

    cp ../cross_toolchain.txt .
    sed -i \
        -e "s|@prefix@|${ewpi_prefix}|g" \
        -e "s|@host@|${ewpi_host}|g" \
        -e "s|@proc@|${proc}|g" \
        -e "s|@winver@|${winver}|g" \
        -e "s|@arch@|${ewpi_arch}|g" \
        -e "s|@cpu_family@|${cpu_family}|g" \
        -e "s|@cpu@|${cpu}|g" \
        cross_toolchain.txt
}

ewpi_ninja()
{
    if test -n "${jobopt}" && test -n "${verbninja}"; then
        ninja -j "${jobopt}" "${verbninja}" "$@"
    elif test -n "${jobopt}"; then
        ninja -j "${jobopt}" "$@"
    elif test -n "${verbninja}"; then
        ninja "${verbninja}" "$@"
    else
        ninja "$@"
    fi
}

ewpi_make()
{
    if test -n "${jobopt}"; then
        make -j "${jobopt}" "$@"
    else
        make "$@"
    fi
}

ewpi_cmake()
{
    _ewpi_gen=$1
    shift

    (
        ewpi_prep_cross
        rm -rf builddir
        mkdir builddir
        cd builddir || exit

        cmake \
            -DCMAKE_TOOLCHAIN_FILE=../cross_toolchain.txt \
            -DCMAKE_INSTALL_PREFIX="${prefix_unix}" \
            -DCMAKE_VERBOSE_MAKEFILE:BOOL="${verbcmake}" \
            -DCMAKE_BUILD_TYPE=Release \
            "$@" \
            -G "${_ewpi_gen}" \
            .. >../../config.log 2>&1

        if test "${_ewpi_gen}" = "Ninja"; then
            ewpi_ninja install >../../make.log 2>&1
        else
            ewpi_make "${verbmake}" install >../../make.log 2>&1
        fi
    )
}

ewpi_meson()
{
    (
        ewpi_prep_cross
        rm -rf builddir

        meson setup \
            --prefix="${ewpi_prefix}" \
            --libdir=lib \
            --buildtype=release \
            --strip \
            --cross-file cross_toolchain.txt \
            --default-library shared \
            "$@" \
            builddir >../config.log 2>&1

        ewpi_ninja -C builddir install >../make.log 2>&1
    )
}

ewpi_autoconf()
{
    if test "x$1" = "x--autoreconf"; then
        shift
        case "${EWPI_OS}" in
            MSYS* | MINGW*) ;;
            *)
                autoreconf -vif
                ;;
        esac
    fi

    ./configure --prefix="${ewpi_prefix}" --host="${ewpi_host}" "$@" >../config.log 2>&1

    ewpi_make "${verbmake}" install >../make.log 2>&1
}
