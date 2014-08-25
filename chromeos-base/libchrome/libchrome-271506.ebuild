# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.  This way packages
# from other locations (like libchrome_crypto) can be coordinated.

EAPI="4"
CROS_WORKON_PROJECT=("chromium/src/base" "chromium/src/dbus" "chromium/src/components/feedback")
CROS_WORKON_COMMIT=("a3027e7de45d1a575d66f20ae79aa30dccd2af3d" "4629b538b25843b3e03f8621c2aac0b19b3d63e2" "79207b2d7fc8fd19c7929fbc9b3b0c907117a47d")
CROS_WORKON_DESTDIR=("${S}/base" "${S}/dbus" "${S}/components/feedback")
CROS_WORKON_BLACKLIST="1"

inherit cros-workon cros-debug toolchain-funcs scons-utils

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
	# so that daemons like shill can be upgraded to libchrome:271506.
	# TODO(benchan): Remove this workaround (crbug.com/361635).
	epatch "${FILESDIR}"/base-${SLOT}-message-loop-for-ui.patch

	# Patch md5.cc to avoid a compiler warning on unsafe conversion.
	# (crbug.com/377085)
	epatch "${FILESDIR}"/base-${SLOT}-md5-compile-warning.patch

	# Temporarily patch dbus::MessageReader to add a GetSignature method
	# (https://codereview.chromium.org/502793002/).
	# TODO(benchan): Remove this patch after we roll a new libchrome.
	epatch "${FILESDIR}"/base-${SLOT}-dbus-get-signature.patch

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
}

src_configure() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"
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
		components/feedback
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
