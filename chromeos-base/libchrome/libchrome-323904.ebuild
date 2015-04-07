# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Note: the ${PV} should represent the overall svn rev number of the
# chromium tree that we're extracting from rather than the svn rev of
# the last change actually made to the base subdir.

EAPI="4"
CROS_WORKON_PROJECT=("chromium/src/base" "chromium/src/dbus" "chromium/src/crypto" "chromium/src/sandbox")
CROS_WORKON_COMMIT=("527a20c667333befe9e996100c3b746e926ce4de" "242a92e8c5cede6e457dc5fa5731232ae15f8e64" "f48fa87d157ca2d017b21c5a39ecc29e58cc8d1f" "7fbff896d2c8752a29c7c93ab4cb014089bcc878")
CROS_WORKON_DESTDIR=("${S}/base" "${S}/dbus" "${S}/crypto" "${S}/sandbox")
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
RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
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

	# Temporarily revert base::WriteFile to the behavior in older revision
	# of libchrome until we sort out the expected file permissions at all
	# call sites of base::WriteFile in Chrome OS code.
	# TODO(benchan): Remove this workaround (crbug.com/412057).
	epatch "${FILESDIR}"/base-${SLOT}-revert-writefile-permissions.patch

	cp -r "${FILESDIR}"/components .

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
		base/numerics
		base/posix
		base/profiler
		base/process
		base/strings
		base/synchronization
		base/task
		base/threading
		base/time
		base/timer
		build
		components/timers
		dbus
		testing/gmock/include/gmock
		testing/gtest/include/gtest
	)
	for d in "${header_dirs[@]}" ; do
		insinto /usr/include/base-${SLOT}/${d}
		doins ${d}/*.h
	done

	insinto /usr/include/base-${SLOT}/crypto
	doins \
		crypto/crypto_export.h \
		crypto/hmac.h \
		crypto/nss_util.h \
		crypto/nss_util_internal.h \
		crypto/p224.h \
		crypto/p224_spake.h \
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
