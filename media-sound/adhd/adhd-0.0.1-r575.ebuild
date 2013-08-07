# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

EAPI=4
CROS_WORKON_COMMIT="57f84543a3ab60e7708bad7e8d4b9aecfde68bef"
CROS_WORKON_TREE="580d49d8d5b0acfae76ec4b958d00460218c415d"
CROS_WORKON_PROJECT="chromiumos/third_party/adhd"
CROS_WORKON_LOCALNAME="adhd"

inherit toolchain-funcs autotools cros-workon cros-board

DESCRIPTION="Google A/V Daemon"
HOMEPAGE="http://www.chromium.org"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND=">=media-libs/alsa-lib-1.0.24.1
	media-libs/sbc
	media-libs/speex
	dev-libs/iniparser
	>=sys-apps/dbus-1.4.12
	dev-libs/libpthread-stubs
	sys-fs/udev"
DEPEND="${RDEPEND}
	media-libs/ladspa-sdk"

src_prepare() {
	cd cras
	eautoreconf
}

src_configure() {
	cd cras
	cros-workon_src_configure
}

src_compile() {
	local board=$(get_current_board_with_variant)
	emake BOARD=${board} CC="$(tc-getCC)" || die "Unable to build ADHD"
}

src_test() {
	if ! use x86 && ! use amd64 ; then
		elog "Skipping unit tests on non-x86 platform"
	else
		cd cras
		emake check
	fi
}

src_install() {
	local board=$(get_current_board_with_variant)
	local board_no_variant=$(get_current_board_no_variant)
	emake BOARD=${board} DESTDIR="${D}" install

	# install ucm config files
	insinto /usr/share/alsa/ucm
	local board_dir
	for board_dir in ${board} ${board_no_variant} ; do
		if [[ -d ucm-config/${board_dir} ]] ; then
			doins -r ucm-config/${board_dir}/*
			break
		fi
	done

	# install dbus config allowing cras access
	insinto /etc/dbus-1/system.d
	doins dbus-config/org.chromium.cras.conf
}
