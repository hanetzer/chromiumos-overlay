# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.  This way packages
# from other locations (like libchrome_crypto) can be coordinated.

# XXX: This hits svn rev 180557 (for base) and 179809 (for dbus) instead of rev
# 180609, but that is correct. See above note.

EAPI="4"
CROS_WORKON_PROJECT=("chromium/src/base" "chromium/src/dbus")
CROS_WORKON_COMMIT=("94b9b5d64fa557377ab1e3a5e3bd6cca7d0b73d8" "e6c42306506191eed994158ed76a2dad2eb41d83")
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
	dev-libs/nss
	dev-libs/protobuf
	sys-apps/dbus"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	cros_host? ( dev-util/scons )"

src_prepare() {
	mkdir -p build
	cp -p "${FILESDIR}/build_config.h-${SLOT}" build/build_config.h || die

	cp -p "${FILESDIR}/SConstruct-${SLOT}" SConstruct || die
	epatch "${FILESDIR}"/gtest_include_path_fixup.patch

	epatch "${FILESDIR}"/base-125070-no-X.patch
	epatch "${FILESDIR}"/base-125070-x32.patch

	# Add stub headers for a few files that are usually checked out to Chrome's
	# toplevel third_party/ directory.
	mkdir -p third_party/libevent
	echo '#include <event.h>' > third_party/libevent/event.h

	mkdir -p third_party/protobuf/src/google/protobuf
	echo '#include <google/protobuf/message_lite.h>' > \
		third_party/protobuf/src/google/protobuf/message_lite.h
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
		base/debug
		base/files
		base/json
		base/memory
		base/metrics
		base/posix
		base/profiler
		base/strings
		base/synchronization
		base/threading
		build
		dbus
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-${SLOT}/${d}
		doins ${d}/*.h
	done

	insinto /usr/$(get_libdir)/pkgconfig
	doins libchrome-${SLOT}.pc
}
