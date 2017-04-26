# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="b9b8f1de0ab9d4b0e1739d7c0dc4ec232b85a5c3"
CROS_WORKON_TREE="ed7bd798f46748b912df5aa7fb7dc8364d3d9048"
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
	if ! use x86 && ! use amd64 ; then
		einfo Skipping unit tests on non-x86 platform
	else
		# Needed for `cros_run_unit_tests`.
		cros-workon_src_test

		sudo LD_LIBRARY_PATH=${WORKDIR} \
			./rootdev_test.sh "${WORKDIR}/rootdev" || die
	fi
}

src_install() {
	cd "${WORKDIR}"
	dobin rootdev
	dolib.so librootdev.so*
	insinto /usr/include/rootdev
	doins "${S}"/rootdev.h
}
