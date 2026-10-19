#! /bin/sh

. ../../common.sh

ewpi_cmake "Unix Makefiles" \
    -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
    -DBUILD_EXAMPLES=FALSE \
    -DWITH_DEV_TRACE=FALSE
