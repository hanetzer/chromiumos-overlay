# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="fd27896cbdd893ef3ccee7c19ed3d0d0511aa6e7"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS assets (images, sounds, etc.)"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

DEPEND="x11-apps/xcursorgen"
RDEPEND=""

REAL_CURSOR_NAMES="
	fleur
	hand2
	left_ptr
	sb_h_double_arrow
	sb_v_double_arrow
	top_left_corner
	top_right_corner
	xterm"

LINK_CURSORS="
	08e8e1c95fe2fc01f976f1e063a24ccd:watch
	bottom_left_corner:top_right_corner
	bottom_right_corner:top_left_corner
	bottom_side:sb_v_double_arrow
	double_arrow:sb_v_double_arrow
	left_ptr_watch:left_ptr
	left_side:sb_h_double_arrow
	right_side:sb_h_double_arrow
	top_side:sb_v_double_arrow
	watch:left_ptr"

CROS_WORKON_LOCALNAME="assets"
CROS_WORKON_PROJECT="assets"

src_install() {
	insinto /usr/share/chromeos-assets/images
	doins "${S}"/images/*

	insinto /usr/share/chromeos-assets/input_methods
	doins "${S}"/input_methods/*

	insinto /usr/share/fonts/droid-thai
	doins "${S}"/fonts/DroidThai*.ttf

	insinto /usr/share/fonts/chrome-droid
	doins "${S}"/fonts/ChromeDroid*.ttf

	local CURSOR_DIR="${D}"/usr/share/cursors/xorg-x11/chromeos/cursors

	mkdir -p "${CURSOR_DIR}"
	for i in ${REAL_CURSOR_NAMES}; do
		xcursorgen -p "${S}"/cursors "${S}"/cursors/$i.cfg >"${CURSOR_DIR}/$i"
	done

	for i in ${LINK_CURSORS}; do
		ln -s ${i#*:} "${CURSOR_DIR}/${i%:*}"
	done

	mkdir -p "${D}"/usr/share/cursors/xorg-x11/default
	echo Inherits=chromeos \
		>"${D}"/usr/share/cursors/xorg-x11/default/index.theme
}
