# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="5424cd563e7879d981b79db99372638091474f3d"
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
	chromeos-base/libscrypt
	chromeos-base/metrics
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/nss
	dev-libs/opencryptoki
	dev-libs/openssl
	dev-libs/protobuf
	sys-apps/keyutils
	sys-fs/ecryptfs-utils"

DEPEND="
	test? ( dev-cpp/gtest )
	chromeos-base/libchrome
	chromeos-base/libchromeos
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
	scons cryptohomed || die "cryptohomed compile failed."
	scons cryptohome || die "cryptohome compile failed."
	scons cryptohome-path || die "cryptohome-path compile failed."
	popd
}

src_test() {
	cros-debug-add-NDEBUG
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	export CCFLAGS="$CFLAGS"

	pushd cryptohome
	# Only build the tests
	# TODO(wad) eclass-ify this.
	scons cryptohome_testrunner ||
		die "cryptohome_testrunner compile failed."	

	if use x86 ; then
		# Create data for unittests
		./init_cryptohome_data.sh test_image_dir
		./cryptohome_testrunner ${GTEST_ARGS} || \
		    die "unit tests (with ${GTEST_ARGS}) failed!"
	fi
	popd
}

src_install() {
	S="${S}/cryptohome"

	dosbin "${S}/cryptohomed"
	dosbin "${S}/cryptohome"
	dosbin "${S}/cryptohome-path"
	dolib "${S}/libcryptohome.so"

	dobin "${S}/email_to_image"

	dodir /etc/dbus-1/system.d
	insinto /etc/dbus-1/system.d
	doins "${S}/etc/Cryptohome.conf"

	dodir /usr/share/dbus-1/services/
	insinto /usr/share/dbus-1/services/
	doins "${S}/share/org.chromium.Cryptohome.service"

	# For opencryptoki.
	dodir /etc/skel/.tpm
}
