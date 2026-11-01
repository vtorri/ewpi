#! /bin/sh

. ../../common.sh

case ${EWPI_OS} in
    MSYS* | MINGW*) ;;
    *)
        sed -i -e "s/INFINITY;/__builtin_inff();/g" src/graphene-ray.c
        ;;
esac

ewpi_meson \
    -Dgtk_doc=false \
    -Dgobject_types=true \
    -Dintrospection=disabled \
    -Darm_neon=false \
    -Dtests=false \
    -Dinstalled_tests=false
