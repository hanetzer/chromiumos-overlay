# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit toolchain-funcs autotools

DESCRIPTION="X.Org driver for MSM SOC"
LICENSE=""
SLOT="0"
KEYWORDS="arm"
IUSE="dri"

RDEPEND=">=x11-base/xorg-server-1.4
	chromeos-base/kernel-headers
	"
DEPEND="${RDEPEND}
	x11-proto/fontsproto
	x11-proto/renderproto
	x11-proto/xproto
	"

files="${CHROMEOS_ROOT}/src/third_party/xf86-video-msm"
if [[ -n "${ST1Q_SOURCES_QUALCOMM}" ]] ; then
	files="${CHROMEOS_ROOT}/${ST1Q_SOURCES_QUALCOMM}/xf86-video-msm"
fi

src_unpack() {
	elog "Using xf86-video-msm files: ${files}"

	mkdir -p "${S}"
	cp -a "${files}"/* "${S}" || die "xf86-video-msm copy failed"

	cd "${S}" || die

	eautoreconf || die
}

src_configure() {
	econf --enable-maintainer-mode || die
}

src_compile() {
	emake || die
}

src_install() {
	insinto /usr/lib/xorg/modules/drivers
	doins "${S}"/src/.libs/msm_drv.so
}
