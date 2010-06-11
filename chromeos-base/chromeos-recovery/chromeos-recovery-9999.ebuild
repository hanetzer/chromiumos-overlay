# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-workon

DESCRIPTION="Chrome OS Recovery Image Installer"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="~x86 ~arm"
IUSE=""

DEPEND=""

RDEPEND="chromeos-base/chromeos-installer
         chromeos-base/chromeos-init"

CROS_WORKON_LOCALNAME="recovery_installer"
CROS_WORKON_PROJECT="recovery_installer"

src_install() {
	insinto /etc/init
	doins recovery_install.conf
}

pkg_postinst() {
	# Mark this image as being a recovery install shim.
	touch "${ROOT}/root/.recovery_installer"

	# Remove ui.conf startup script, which will make sure chrome doesn't
	# run, since it tries to update on startup
	# TODO(tgao): take this out once we have a nice GUI for progress bar
	# from Chrome so that Chrome runs
	sed -i 's/start on stopping startup/start on never/' \
		"${ROOT}/etc/init/ui.conf"
}
