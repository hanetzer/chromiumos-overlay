# Copyright 1999-2013 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libdrm/libdrm-2.4.50.ebuild,v 1.1 2013/12/04 12:08:51 chithanh Exp $

EAPI=4
inherit xorg-2

EGIT_REPO_URI="git://anongit.freedesktop.org/git/mesa/drm"

UPSTREAM_PKG="${P/-tests}"

DESCRIPTION="X.Org libdrm library"
HOMEPAGE="http://dri.freedesktop.org/"
if [[ ${PV} = 9999* ]]; then
	SRC_URI=""
else
	SRC_URI="http://dri.freedesktop.org/${PN}/${UPSTREAM_PKG}.tar.bz2"
fi

# This package uses the MIT license inherited from Xorg but fails to provide
# any license file in its source, so we add X as a license, which lists all
# the Xorg copyright holders and allows license generation to pick them up.
LICENSE="|| ( MIT X )"
KEYWORDS="*"
VIDEO_CARDS="exynos freedreno intel nouveau omap radeon vmware"
for card in ${VIDEO_CARDS}; do
	IUSE_VIDEO_CARDS+=" video_cards_${card}"
done

IUSE="${IUSE_VIDEO_CARDS} libkms"
RESTRICT="test" # see bug #236845

RDEPEND="dev-libs/libpthread-stubs
	sys-fs/udev
	video_cards_intel? ( >=x11-libs/libpciaccess-0.10 )
	~x11-libs/libdrm-${PV}"
DEPEND="${RDEPEND}"

S=${WORKDIR}/${UPSTREAM_PKG}

pkg_setup() {
	XORG_CONFIGURE_OPTIONS=(
		--enable-udev
		$(use_enable video_cards_exynos exynos-experimental-api)
		$(use_enable video_cards_freedreno freedreno-experimental-api)
		$(use_enable video_cards_intel intel)
		$(use_enable video_cards_nouveau nouveau)
		$(use_enable video_cards_omap omap-experimental-api)
		$(use_enable video_cards_radeon radeon)
		$(use_enable video_cards_vmware vmwgfx)
		$(use_enable libkms)
	)

	xorg-2_pkg_setup
}

src_compile() {
	xorg-2_src_compile

	# Manually build tests since they are not built automatically.
	# This should match the logic of tests/Makefile.am.  e.g. gem tests for
	# intel only.
	TESTS=( dr{i,m}stat )
	if use video_cards_intel; then
		TESTS+=( gem_{basic,flink,readwrite,mmap} )
	fi
	emake -C "${AUTOTOOLS_BUILD_DIR}"/tests "${TESTS[@]}"
}

src_install() {
	into /usr/local/
	dobin "${AUTOTOOLS_BUILD_DIR}"/tests/*/.libs/*
	dobin "${TESTS[@]/#/${AUTOTOOLS_BUILD_DIR}/tests/.libs/}"
}
