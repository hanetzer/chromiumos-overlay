# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

CROS_WORKON_COMMIT="a0b54062c11f49789141b6f72832405910517cdc"
CROS_WORKON_TREE=("0295472676671915bab943e84d561ed834ea7622" "74765a29c8f1b61027c98c1d16e6fe0ec92a2780")
CROS_WORKON_INCREMENTAL_BUILD="1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_SUBTREE="common-mk arc/adbd"

PLATFORM_SUBDIR="arc/adbd"
PLATFORM_GYP_FILE="adbd.gyp"

inherit cros-workon platform

DESCRIPTION="Container to run Android's adbd proxy."
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/arc/adbd"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"

src_install() {
	insinto /etc/init
	doins arc-adbd.conf

	exeinto /usr/sbin
	doexe "${OUT}/arc-adbd"
}
