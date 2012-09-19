# Copyright (C) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE.makefile file.
CROS_WORKON_COMMIT=6a60a7512d5776f468196ab6abe490467e535d3d
CROS_WORKON_TREE="b7984b16762c61f9152aa29c7519352fff45a6f8"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/chaps"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="PKCS #11 layer over TrouSerS."
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm amd64 x86"
IUSE="test"

LIBCHROME_VERS="125070"

RDEPEND="
	app-crypt/trousers
	chromeos-base/chromeos-init
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/libchromeos
	dev-libs/dbus-c++
	dev-libs/openssl
	dev-cpp/gflags"

DEPEND="${RDEPEND}
	dev-cpp/gmock
	test? ( dev-cpp/gtest )
	dev-db/leveldb"

src_compile() {
	tc-export CXX OBJCOPY PKG_CONFIG STRIP
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
	emake OUT=build-opt
}

src_test() {
	cros-debug-add-NDEBUG
	emake OUT=build-opt tests
	emake OUT=build-opt more_tests
}

src_install() {
	dosbin build-opt/chapsd
	dobin build-opt/chaps_client
	dobin build-opt/p11_replay
	dolib.so build-opt/libchaps.so
	# Install D-Bus config file.
	insinto /etc/dbus-1/system.d
	doins org.chromium.Chaps.conf
	# Install D-Bus service file.
	insinto /usr/share/dbus-1/services
	doins org.chromium.Chaps.service
	# Install upstart config file.
	insinto /etc/init
	doins chapsd.conf
	# Install headers for use by clients.
	insinto /usr/include/chaps
	doins login_event_client.h
	insinto /usr/include/chaps/pkcs11
	doins pkcs11/*.h
}

