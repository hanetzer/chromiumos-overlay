# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.  This way packages
# from other locations (like libchrome_crypto) can be coordinated.

EAPI="4"
CROS_WORKON_PROJECT=("chromium/src/base" "chromium/src/dbus")
CROS_WORKON_COMMIT=("c683753f6613efa9a553ce4a9e2c159afbc9277e" "4141b1c78f98c14ce690ea59df3c104fbe719199")
CROS_WORKON_DESTDIR=("${S}/base" "${S}/dbus")
CROS_WORKON_BLACKLIST="1"

inherit cros-workon cros-debug flag-o-matic toolchain-funcs scons-utils

DESCRIPTION="Chrome base/ and dbus/ libraries extracted for use on Chrome OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/libchrome"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="${PV}"
KEYWORDS="*"
IUSE="cros_host"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/protobuf
	sys-apps/dbus"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	dev-cpp/gmock
	cros_host? ( dev-util/scons )"

src_prepare() {
	mkdir -p build
	cp -p "${FILESDIR}/build_config.h-${SLOT}" build/build_config.h || die
	cp -p "${FILESDIR}/SConstruct-${SLOT}" SConstruct || die

	# Temporarily patch base::MessageLoopForUI to use base::MessagePumpGlib
	# so that daemons like shill can be upgraded to libchrome:293168.
	# TODO(benchan): Remove this workaround (crbug.com/361635).
	epatch "${FILESDIR}"/base-${SLOT}-message-loop-for-ui.patch

	# Temporarily work around an issue with the compiler failing to handle
	# an arraysize() call in base/cpu.cc on arm.
	# TODO(benchan): Remove this workaround (crbug.com/411508).
	epatch "${FILESDIR}"/base-${SLOT}-arm-arraysize-fix.patch

	# Temporarily revert base::WriteFile to the behavior in older revision
	# of libchrome until we sort out the expected file permissions at all
	# call sites of base::WriteFile in Chrome OS code.
	# TODO(benchan): Remove this workaround (crbug.com/412057).
	epatch "${FILESDIR}"/base-${SLOT}-revert-writefile-permissions.patch

	# Add stub headers for a few files that are usually checked out to locations
	# outside of base/ in the Chrome repository.
	mkdir -p third_party/libevent
	echo '#include <event.h>' > third_party/libevent/event.h

	mkdir -p third_party/protobuf/src/google/protobuf
	echo '#include <google/protobuf/message_lite.h>' > \
		third_party/protobuf/src/google/protobuf/message_lite.h

	mkdir -p testing/gtest/include/gtest
	echo '#include <gtest/gtest_prod.h>' > \
		testing/gtest/include/gtest/gtest_prod.h

	mkdir -p testing/gmock/include/gmock
	echo '#include <gmock/gmock.h>' > \
		testing/gmock/include/gmock/gmock.h

	# base/files/file_posix.cc expects 64-bit off_t, which requires
	# enabling large file support.
	append-lfs-flags
}

src_configure() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
}

src_compile() {
	BASE_VER=${SLOT} CHROME_INCLUDE_PATH="${S}" escons -k
}

src_install() {
	dolib.so libbase*-${SLOT}.so
	dolib.a libbase*-${SLOT}.a

	local d header_dirs=(
		base/third_party/icu
		base/third_party/nspr
		base/third_party/valgrind
		base/third_party/dynamic_annotations
		base
		base/containers
		base/debug
		base/files
		base/json
		base/memory
		base/message_loop
		base/metrics
		base/posix
		base/profiler
		base/process
		base/strings
		base/synchronization
		base/threading
		base/time
		base/timer
		build
		dbus
		testing/gmock/include/gmock
		testing/gtest/include/gtest
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-${SLOT}/${d}
		doins ${d}/*.h
	done

	insinto /usr/$(get_libdir)/pkgconfig
	doins libchrome*-${SLOT}.pc
}
