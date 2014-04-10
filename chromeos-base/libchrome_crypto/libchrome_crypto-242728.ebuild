# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# See logic for ${PV} behavior in the libchrome ebuild.

# XXX: Yes, this hits svn rev 242277 instead of rev 242728, but
#      that is correct.  See above note.

EAPI="4"
CROS_WORKON_COMMIT="6860633530e108f702904900ceb9b17093f2e4db"
CROS_WORKON_PROJECT="chromium/src/crypto"
CROS_WORKON_BLACKLIST="1"

inherit cros-workon cros-debug toolchain-funcs scons-utils

DESCRIPTION="Chrome crypto/ library extracted for use on Chrome OS"
HOMEPAGE="http://dev.chromium.org/chromium-os/packages/libchrome"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="chromeos-base/libchrome:${PV}[cros-debug=]
	dev-libs/nss"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/crypto" &> /dev/null
	cp -p "${FILESDIR}/SConstruct-${PV}" "${S}/SConstruct" || die
	epatch "${FILESDIR}/memory_annotation.patch"
}

src_compile() {
	tc-export AR CC CXX PKG_CONFIG RANLIB
	cros-debug-add-NDEBUG

	BASE_VER=${PV} escons || die
}

src_install() {
	dolib.a libchrome_crypto.a

	insinto /usr/include/crypto
	doins \
		crypto_export.h \
		nss_util.h \
		nss_util_internal.h \
		rsa_private_key.h \
		scoped_nss_types.h \
		secure_hash.h \
		sha2.h \
		signature_creator.h \
		signature_verifier.h
}
