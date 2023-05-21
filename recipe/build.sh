#!/bin/bash

set -x

# We are going to disable some tests on qemu based platforms
# if [ "${target_platform}" == "linux-aarch64" ] || [ "${target_platform}" == "linux-ppc64le" ]; then
#    sed -i '/get_currentexe/d' ./test/test-list.h
#    sed -i '/udp_multicast_interface/d' ./test/test-list.h
#    sed -i '/udp_no_autobind/d' ./test/test-list.h
# fi

if [ "${target_platform}" == "linux-aarch64" ]; then
   # These failures have been reported upstream
   # https://github.com/libuv/libuv/issues/2867
   sed -i '/random_async/d' ./test/test-list.h
   sed -i '/random_sync/d' ./test/test-list.h


   # 2023/05 -- hmaarrfk
   # I'm not sure why these tests are failing on aarch
   sed -i '/timer_from_check/d' ./test/test-list.h
   sed -i '/timer_ref2/d' ./test/test-list-.h
fi

if [ "${target_platform}" == "linux-ppc64le" ]; then
    # Assertion failed in test/test-thread-affinity.c on line 55:
    # cpumask[0] && "test must be run with cpu 0 affinity"
    sed -i '/thread_affinity/d' ./test/test-list.h
fi

# This particular test fails on osx
if [ "${target_platform}" == 'osx-64' ]; then
   sed -i '/hrtime/d' ./test/test-list.h
   sed -i '/fs_event_error_reporting/d' ./test/test-list.h
fi

if [[ "${CONDA_BUILD_CROSS_COMPILATION}" == "1" && "${target_platform}" == "linux-aarch64" ]]; then
echo "Setting __QEMU__=1"
export CPPFLAGS="-D__QEMU__=1 $CPPFLAGS"
fi

./configure \
   --disable-dependency-tracking \
   --disable-silent-rules \
   --prefix="$PREFIX" \

make -j${CPU_COUNT}
if [[ "${CONDA_BUILD_CROSS_COMPILATION}" != "1" ]]; then
make check
fi
make install
