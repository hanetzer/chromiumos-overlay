# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

inherit udev

DESCRIPTION="Chrome OS trigger allowing chrome to access cros-ec-accel device"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

RDEPEND="
	virtual/modutils
	virtual/udev
"

S=${WORKDIR}

src_test() {
	local cmd=(
		"${FILESDIR}"/tests/accelerometer-init-test.sh
	)
	echo "${cmd[@]}"
	"${cmd[@]}" || die
}

src_install() {
	udev_dorules "${FILESDIR}"/udev/99-cros-ec-accel.rules
	exeinto $(udev_get_udevdir)
	doexe "${FILESDIR}"/udev/accelerometer-init.sh

	insinto /etc/init
	doins "${FILESDIR}"/init/cros-ec-accel.conf
}
