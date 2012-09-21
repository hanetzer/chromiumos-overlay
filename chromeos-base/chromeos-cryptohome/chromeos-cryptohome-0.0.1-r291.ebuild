# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="0257b45305671347a6606f6d9e891d08c60e0658"
CROS_WORKON_TREE="342a0ba8b4fcc3663baaf087cfb8ddb50ccc3c8d"

EAPI=2
CROS_WORKON_PROJECT="chromiumos/platform/cryptohome"
inherit cros-debug cros-workon toolchain-funcs

DESCRIPTION="Encrypted home directories for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="test"

RDEPEND="
	app-crypt/trousers
	chromeos-base/chaps
	chromeos-base/libchromeos
	chromeos-base/libscrypt
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/libchrome:125070[cros-debug=]
	chromeos-base/system_api
	${RDEPEND}"

CROS_WORKON_LOCALNAME=$(basename ${CROS_WORKON_PROJECT})

# TODO(msb): fix this ugly hackery
src_unpack() {
	cros-workon_src_unpack
	pushd "${S}"
	mkdir "${CROS_WORKON_LOCALNAME}"
	mv * "${CROS_WORKON_LOCALNAME}"
	popd
}

src_compile() {
	cros-debug-add-NDEBUG
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	export CCFLAGS="$CFLAGS"

	pushd cryptohome
	# Build the daemon and command line client
	emake || die "make failed."
	popd
}

src_test() {
	cros-debug-add-NDEBUG
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	export CCFLAGS="$CFLAGS"

	pushd cryptohome
	# Only build the tests
	# TODO(wad) eclass-ify this.
	emake tests || die "tests failed."

	popd
}

src_install() {
	S="${S}/cryptohome"

	dosbin "${S}/cryptohomed"
	dosbin "${S}/cryptohome"
	dosbin "${S}/cryptohome-path"

	dobin "${S}/email_to_image"

	dodir /etc/dbus-1/system.d
	insinto /etc/dbus-1/system.d
	doins "${S}/etc/Cryptohome.conf"

	dodir /usr/share/dbus-1/services/
	insinto /usr/share/dbus-1/services/
	doins "${S}/share/org.chromium.Cryptohome.service"
}
