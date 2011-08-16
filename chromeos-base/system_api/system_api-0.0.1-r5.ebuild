# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="45f2113018be863501e582d9e9e4045e154ee6ae"
CROS_WORKON_PROJECT="chromiumos/platform/system_api"

inherit cros-workon toolchain-funcs

DESCRIPTION="Chrome OS system API (D-Bus service names, etc.)"
HOMEPAGE="http://www.chromium.org/"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

# The blocker dependency is added to block libcros-0.0.1-r303 or older,
# that installs chromeos_wm_ipc_enums.h, to avoid a collision of the file.
# TODO(satorux): We'll leave this blocker around for at least a month
# so that people running build_packages don't see warnings. Then, we'll
# remove this.
RDEPEND="!<=chromeos-base/libcros-0.0.1-r303"
DEPEND="${RDEPEND}"

CROS_WORKON_LOCALNAME="$(basename ${CROS_WORKON_PROJECT})"

src_install() {
	insinto /usr/include/cros
	doins window_manager/chromeos_wm_ipc_enums.h
}