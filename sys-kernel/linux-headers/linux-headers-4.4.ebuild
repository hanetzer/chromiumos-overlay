# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

ETYPE="headers"
H_SUPPORTEDARCH="alpha amd64 arc arm arm64 avr32 bfin cris frv hexagon hppa ia64 m32r m68k metag microblaze mips mn10300 nios2 openrisc ppc ppc64 s390 score sh sparc tile x86 xtensa"
inherit kernel-2
detect_version

PATCH_VER="1"
SRC_URI="mirror://gentoo/gentoo-headers-base-${PV}.tar.xz
	${PATCH_VER:+mirror://gentoo/gentoo-headers-${PV}-${PATCH_VER}.tar.xz}"

KEYWORDS="*"

DEPEND="app-arch/xz-utils
	dev-lang/perl"
RDEPEND="!!media-sound/alsa-headers"

S=${WORKDIR}/gentoo-headers-base-${PV}

src_unpack() {
	unpack ${A}
}

src_prepare() {
	[[ -n ${PATCH_VER} ]] && EPATCH_SUFFIX="patch" epatch "${WORKDIR}"/${PV}

	epatch "${FILESDIR}/0001-CHROMIUM-media-headers-Import-V4L2-headers-from-Chro.patch"
	epatch "${FILESDIR}/0002-CHROMIUM-v4l-Add-VP8-low-level-decoder-API-controls.patch"
	epatch "${FILESDIR}/0003-v4l-add-pixelformat-change-event.patch"
	epatch "${FILESDIR}/0004-v4l-add-force-key-frame-control.patch"
	epatch "${FILESDIR}/0005-UPSTREAM-sched-new-clone-flag-CLONE_NEWCGROUP-for-cg.patch"
	epatch "${FILESDIR}/0006-CHROMIUM-v4l-Add-V4L2_PIX_FMT_VP9-definition.patch"
	epatch "${FILESDIR}/0007-CHROMIUM-v4l-Add-VP9-low-level-decoder-API-controls.patch"
	epatch "${FILESDIR}/0008-CHROMIUM-v4l-Add-V4L2_CID_MPEG_VIDEO_H264_SPS_PPS_BE.patch"
	epatch "${FILESDIR}/0009-BACKPORT-v4l-Add-YUV-4-2-2-and-YUV-4-4-4-tri-planar-.patch"
	epatch "${FILESDIR}/0010-UPSTREAM-Input-uinput-add-new-UINPUT_DEV_SETUP-and-U.patch"
	epatch "${FILESDIR}/0011-CHROMIUM-kernel-device_jail.patch"
	epatch "${FILESDIR}/0012-UPSTREAM-uapi-add-missing-install-of-dma-buf.h.patch"
	epatch "${FILESDIR}/0013-Input-introduce-KEY_ASSISTANT.patch"
}

src_install() {
	kernel-2_src_install

	# hrm, build system sucks
	find "${ED}" '(' -name '.install' -o -name '*.cmd' ')' -delete
	find "${ED}" -depth -type d -delete 2>/dev/null
}

src_test() {
	# Make sure no uapi/ include paths are used by accident.
	egrep -r \
		-e '# *include.*["<]uapi/' \
		"${D}" && die "#include uapi/xxx detected"

	einfo "Possible unescaped attribute/type usage"
	egrep -r \
		-e '(^|[[:space:](])(asm|volatile|inline)[[:space:](]' \
		-e '\<([us](8|16|32|64))\>' \
		.

	einfo "Missing linux/types.h include"
	egrep -l -r -e '__[us](8|16|32|64)' "${ED}" | xargs grep -L linux/types.h

	emake ARCH=$(tc-arch-kernel) headers_check
}
