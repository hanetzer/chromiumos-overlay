# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="3"

EGIT_REPO_URI="git://git.kernel.org/pub/scm/utils/util-linux/util-linux.git"
AUTOTOOLS_AUTO_DEPEND="no"
inherit eutils toolchain-funcs libtool autotools
if [[ ${PV} == "9999" ]] ; then
	inherit git-2 autotools
	#KEYWORDS=""
else
	KEYWORDS="*"
fi

MY_PV=${PV/_/-}
MY_P=util-linux-${MY_PV}
S=${WORKDIR}/${MY_P}

DESCRIPTION="Just builds libuuid from util-linux"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/util-linux/"
if [[ ${PV} == "9999" ]] ; then
	SRC_URI=""
else
	SRC_URI="mirror://kernel/linux/utils/util-linux/v${PV:0:4}/${MY_P}.tar.xz"
fi

LICENSE="GPL-2 GPL-3 LGPL-2.1 BSD-4 MIT public-domain"
SLOT="0"
IUSE="static-libs uclibc"

RDEPEND="!sys-apps/util-linux"
DEPEND="${RDEPEND}
	virtual/os-headers
	uclibc? ( ${AUTOTOOLS_DEPEND} )"

src_prepare() {
	if [[ ${PV} == "9999" ]] ; then
		po/update-potfiles
		eautoreconf
	fi
	if use uclibc ; then
		epatch "${FILESDIR}"/${PN}-2.21.1-no-printf-alloc.patch #406303
		eautoreconf
	fi
	elibtoolize
}

lfs_fallocate_test() {
	# Make sure we can use fallocate with LFS #300307
	cat <<-EOF > "${T}"/fallocate.c
	#define _GNU_SOURCE
	#include <fcntl.h>
	main() { return fallocate(0, 0, 0, 0); }
	EOF
	append-lfs-flags
	$(tc-getCC) ${CFLAGS} ${CPPFLAGS} ${LDFLAGS} "${T}"/fallocate.c -o /dev/null >/dev/null 2>&1 \
		|| export ac_cv_func_fallocate=no
	rm -f "${T}"/fallocate.c
}

src_configure() {
	lfs_fallocate_test
	econf \
		--enable-fs-paths-extra=/usr/sbin \
		--disable-kill \
		--disable-last \
		--disable-mesg \
		--disable-reset \
		--disable-login-utils \
		--enable-schedutils \
		--disable-wall \
		$(use_enable static-libs static) \
		$(tc-has-tls || echo --disable-tls)
}

src_make() {
	emake -C libuuid
	emake -C libblkid
}

src_install() {
	emake -C libuuid install DESTDIR="${D}" || die
	emake -C libblkid install DESTDIR="${D}" || die
	
	# need the libs in /
	gen_usr_ldscript -a blkid uuid
	# e2fsprogs-libs didnt install .la files, and .pc work fine
	find "${ED}" -name '*.la' -delete
}

