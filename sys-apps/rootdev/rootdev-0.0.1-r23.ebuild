# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="a4507857e42fcbb5211bc1e02213b6a87b8086a2"
CROS_WORKON_TREE="3ce43aa5a517868c9c6bceae8c0783a3e0a00db8"
CROS_WORKON_PROJECT="chromiumos/third_party/rootdev"
CROS_WORKON_OUTOFTREE_BUILD="1"

inherit toolchain-funcs cros-workon

DESCRIPTION="Chrome OS root block device tool/library"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export CC
}

src_compile() {
	emake OUT="${WORKDIR}"
}

src_test() {
	sudo LD_LIBRARY_PATH=${WORKDIR} \
		./rootdev_test.sh "${WORKDIR}/rootdev" || die
}

src_install() {
	cd "${WORKDIR}"
	dobin rootdev
	dolib.so librootdev.so*
	insinto /usr/include/rootdev
	doins "${S}"/rootdev.h
}
