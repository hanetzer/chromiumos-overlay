# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/x11-libs/libva-intel-driver/libva-intel-driver-1.3.0.ebuild,v 1.2 2014/04/04 18:01:07 aballier Exp $

EAPI=5

SCM=""
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SCM=git-2
	EGIT_BRANCH=master
	EGIT_REPO_URI="git://anongit.freedesktop.org/git/vaapi/intel-driver"
fi

AUTOTOOLS_AUTORECONF="yes"
inherit autotools-multilib ${SCM}

DESCRIPTION="HW video decode support for Intel integrated graphics"
HOMEPAGE="http://www.freedesktop.org/wiki/Software/vaapi"
if [ "${PV%9999}" != "${PV}" ] ; then # Live ebuild
	SRC_URI=""
	S="${WORKDIR}/${PN}"
else
	SRC_URI="http://www.freedesktop.org/software/vaapi/releases/libva-intel-driver/${P}.tar.bz2"
fi

LICENSE="MIT"
SLOT="0"
if [ "${PV%9999}" = "${PV}" ] ; then
	KEYWORDS="-* amd64 x86 ~amd64-linux ~x86-linux"
else
	KEYWORDS=""
fi
IUSE="+drm wayland X hybrid_codec"

RDEPEND=">=x11-libs/libva-1.3.0[X?,wayland?,drm?,${MULTILIB_USEDEP}]
	!<x11-libs/libva-1.0.15[video_cards_intel]
	>=x11-libs/libdrm-2.4.45[video_cards_intel,${MULTILIB_USEDEP}]
	hybrid_codec? ( media-libs/intel-hybrid-driver )
	wayland? ( media-libs/mesa[egl,${MULTILIB_USEDEP}] >=dev-libs/wayland-1[${MULTILIB_USEDEP}] )"

DEPEND="${RDEPEND}
	virtual/pkgconfig"

src_prepare() {
	epatch "${FILESDIR}"/no_explicit_sync_in_va_sync_surface.patch
	epatch "${FILESDIR}"/Avoid-GPU-crash-with-malformed-streams.patch
	epatch "${FILESDIR}"/set_multisample_state_for_gen6.patch
	epatch "${FILESDIR}"/disable_vp8_encoding.patch
	epatch "${FILESDIR}"/i965_drv-add-support-for-per-codec-max-resolution.patch
	epatch "${FILESDIR}"/jpeg-enc-dec-gen9-Allow-up-to-8K-JPEG-max-resolution.patch
	epatch "${FILESDIR}"/Encoding-Encoding-reuses-aux_batchbuffer-instead-of-.patch
	epatch "${FILESDIR}"/Encoding-H264-uses-the-GPU-to-construct-the-PAK-obj-.patch
	epatch "${FILESDIR}"/Follow-the-HW-spec-to-set-the-surface-cache-attribut.patch
	epatch "${FILESDIR}"/check-the-result-of-hsw_veb_post_format_convert.patch
	epatch "${FILESDIR}"/Make-sure-a-right-VEBOX_IECP_STATE-is-used-on-BDW.patch
	epatch "${FILESDIR}"/Update-PCI-IDs-for-Kabylake.patch
	epatch "${FILESDIR}"/i965_encoder_shift32.patch
	epatch "${FILESDIR}"/Follow-the-HW-spec-to-configure-the-buffer-cache-on-.patch
	epatch "${FILESDIR}"/Fix-the-incorrect-configuration-of-media_pipeline-po.patch
	epatch "${FILESDIR}"/H264-Encoding-Free-aux_batchbuffer-to-configure-acce.patch
	eautoreconf
}

DOCS=( AUTHORS NEWS README )

multilib_src_configure() {
	local myeconfargs=(
		$(use_enable drm)
		$(use_enable wayland)
		$(use_enable X x11)
		$(use_enable hybrid_codec)
	)
	autotools-utils_src_configure
}
