# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.

EAPI="5"

CROS_WORKON_PROJECT="aosp/platform/external/libchrome"
CROS_WORKON_COMMIT="6430a2797e1dfb3af1b83a17640150d216037698"
CROS_WORKON_LOCALNAME="aosp/external/libchrome"
CROS_WORKON_BLACKLIST="1"

inherit cros-workon cros-debug flag-o-matic toolchain-funcs scons-utils

DESCRIPTION="Chrome base/ and dbus/ libraries extracted for use on Chrome OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/libchrome"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="${PV}"
KEYWORDS="*"
IUSE="cros_host"

# TODO(avakulenko): Put dev-libs/nss behind a USE flag to make sure NSS is
# pulled only into the configurations that require it.
RDEPEND="dev-libs/glib:2=
	dev-libs/libevent:=
	dev-libs/modp_b64:=
	dev-libs/nss:=
	dev-libs/openssl:=
	dev-libs/protobuf:=
	sys-apps/dbus:="
DEPEND="${RDEPEND}
	dev-cpp/gtest
	dev-cpp/gmock
	cros_host? ( dev-util/scons )"

src_prepare() {
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
		base
		base/allocator
		base/containers
		base/debug
		base/files
		base/json
		base/memory
		base/message_loop
		base/metrics
		base/numerics
		base/posix
		base/profiler
		base/process
		base/strings
		base/synchronization
		base/task
		base/third_party/icu
		base/third_party/nspr
		base/third_party/valgrind
		base/threading
		base/time
		base/timer
		base/trace_event
		base/trace_event/common
		build
		components/timers
		components/policy
		components/policy/core/common
		dbus
		testing/gmock/include/gmock
		testing/gtest/include/gtest
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-${SLOT}/${d}
		doins ${d}/*.h
	done

	insinto /usr/include/base-${SLOT}/base/test
	doins \
		base/test/simple_test_clock.h \
		base/test/simple_test_tick_clock.h \

	insinto /usr/include/base-${SLOT}/crypto
	doins \
		crypto/crypto_export.h \
		crypto/hmac.h \
		crypto/nss_key_util.h \
		crypto/nss_util.h \
		crypto/nss_util_internal.h \
		crypto/openssl_util.h \
		crypto/p224.h \
		crypto/p224_spake.h \
		crypto/random.h \
		crypto/rsa_private_key.h \
		crypto/scoped_nss_types.h \
		crypto/scoped_openssl_types.h \
		crypto/scoped_test_nss_db.h \
		crypto/secure_hash.h \
		crypto/secure_util.h \
		crypto/sha2.h \
		crypto/signature_creator.h \
		crypto/signature_verifier.h

	insinto /usr/$(get_libdir)/pkgconfig
	doins libchrome*-${SLOT}.pc
}
