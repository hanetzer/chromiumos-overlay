# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="1460fef6c50eda2b09825311dbad6f169feef3b3"
CROS_WORKON_TREE="b1c6dfa12957b0ab3e96b8ce47e57016d2466024"
CROS_WORKON_PROJECT="chromiumos/platform/touch_updater"
CROS_WORKON_OUTOFTREE_BUILD=1

inherit cros-workon

DESCRIPTION="Touch firmware and config updater"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="input_devices_synaptics
	input_devices_wacom
	input_devices_st
"

RDEPEND="
	input_devices_synaptics? ( chromeos-base/rmi4utils )
	input_devices_wacom? ( chromeos-base/wacom_fw_flash )
	input_devices_st? ( chromeos-base/st_flash )
"
src_install() {
	insinto "/etc/init"
	doins "scripts/chromeos-touch-update.conf"

	exeinto "/opt/google/touch/scripts"
	doexe scripts/*.sh

	if [ -d "policies/${ARCH}" ]; then
		insinto "/opt/google/touch/policies"
		doins policies/${ARCH}/*.policy
	fi
}
