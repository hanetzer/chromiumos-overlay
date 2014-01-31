# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.

EAPI="4"
CROS_WORKON_COMMIT="0398d33e3041ffafee8468f551af9926acc28a8a"
CROS_WORKON_TREE="54eb77ebaf08643550f56420d69d789ee7e2085e"
CROS_WORKON_PROJECT="chromiumos/platform/chaps"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-debug cros-workon

DESCRIPTION="PKCS #11 layer over TrouSerS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="platform2 test"

LIBCHROME_VERS="180609"

RDEPEND="
	app-crypt/trousers
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	chromeos-base/platform2
	dev-libs/dbus-c++
	dev-libs/openssl
	dev-cpp/gflags"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )
	dev-db/leveldb"

# We only depend on this for the init script.
RDEPEND+="
	chromeos-base/chromeos-init"

RDEPEND="!platform2? ( ${RDEPEND} )"
DEPEND="!platform2? ( ${DEPEND} )"

src_prepare() {
	if use platform2; then
		printf '\n\n\n'
		ewarn "This package doesn't install anything with USE=platform2."
		ewarn "You want to use the new chromeos-base/platform2 package."
		printf '\n\n\n'
		return 0
	fi
	cros-workon_src_prepare
}

src_configure() {
	use platform2 && return 0
	cros-workon_src_configure
}

src_compile() {
	use platform2 && return 0
	cros-workon_src_compile
}

src_test() {
	use platform2 && return 0
	cros-workon_src_test
	emake more_tests
}

src_install() {
	use platform2 && return 0
	cros-workon_src_install
	dosbin "${OUT}"/chapsd
	dobin "${OUT}"/chaps_client
	dobin "${OUT}"/p11_replay
	dolib.so "${OUT}"/libchaps.so
	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins "${OUT}"/org.chromium.Chaps.conf
	# Install upstart config file.
	insinto /etc/init
	doins chapsd.conf
	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins token_manager_client.h
	doins token_manager_client_mock.h
	doins token_manager_interface.h
	doins isolate.h
	doins chaps_proxy_mock.h
	doins chaps_interface.h
	doins chaps.h
	doins attributes.h
	insinto /usr/include/chaps/pkcs11
	doins pkcs11/*.h
}

