# Copyright (c) 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.  This way packages
# from other locations (like libchrome_crypto) can be coordinated.

# XXX: This hits svn rev 242679 (for base) and 241222 (for dbus) instead of rev
# 242728, but that is correct. See above note.

EAPI="4"
CROS_WORKON_PROJECT=("chromium/src/base" "chromium/src/dbus")
CROS_WORKON_COMMIT=("37fffd496542c30313d406e79b3a0a102e56fa40" "16a4d78cee9b359c311849aaf2323608a668dd72")
CROS_WORKON_DESTDIR=("${S}/base" "${S}/dbus")
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
	cros_host? ( dev-util/scons )"

src_prepare() {
	mkdir -p build
	cp -p "${FILESDIR}/build_config.h-${SLOT}" build/build_config.h || die
	cp -p "${FILESDIR}/SConstruct-${SLOT}" SConstruct || die

	# Temporarily patch base::MessageLoopForUI to use base::MessagePumpGlib
	# so that daemons like shill can be upgraded to libchrome:242728.
	# TODO(benchan): Remove this workaround (crbug.com/361635).
	epatch "${FILESDIR}"/base-${SLOT}-no-X.patch

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
		base/strings
		base/synchronization
		base/threading
		base/time
		base/timer
		build
		dbus
		testing/gtest/include/gtest
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-${SLOT}/${d}
		doins ${d}/*.h
	done

	insinto /usr/$(get_libdir)/pkgconfig
	doins libchrome-${SLOT}.pc
}
