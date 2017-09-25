# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

inherit toolchain-funcs eutils

DESCRIPTION="U2F reference code and test tools"
HOMEPAGE="https://github.com/google/u2f-ref-code"

GIT_SHA1="2efd344c23ac3ce57731ecd57ae57e8c26af6485"
MY_P=${PN}-2efd344
SRC_URI="http://github.com/google/u2f-ref-code/archive/${GIT_SHA1}.tar.gz -> ${MY_P}.tar.gz
		https://android.googlesource.com/platform/system/core/+archive/lollipop-release.tar.gz -> android-system-core-lollipop-release.tar.gz"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="dev-libs/hidapi
	virtual/libudev"
DEPEND="${RDEPENDS}"

S="${WORKDIR}/${PN}-${GIT_SHA1}"

TESTDIR="${S}/u2f-tests/HID"

src_prepare() {
	ln -s "${WORKDIR}" "${TESTDIR}/core"
}

src_configure() {
	tc-export CC CXX PKG_CONFIG
}

src_compile() {
	emake -C "${TESTDIR}"
}

src_install() {
	dobin "${TESTDIR}/U2FTest"
	dobin "${TESTDIR}/HIDTest"
}
