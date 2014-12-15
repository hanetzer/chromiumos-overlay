# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="32cfa166d19a04d90029f9804a7381632352a322"
CROS_WORKON_TREE="b47f42e6f82f5ce2d4e56df82e67410213863cff"
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1

PLATFORM_SUBDIR="attestation"

inherit cros-workon platform user

DESCRIPTION="Attestation service for Chromium OS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="
	chromeos-base/libchromeos
	chromeos-base/system_api
	"

DEPEND="
	${RDEPEND}
	"

src_install() {
	insinto /etc/dbus-1/system.d
	doins server/org.chromium.Attestation.conf

	insinto /etc/init
	doins server/attestationd.conf

	dosbin "${OUT}"/attestationd
	dobin "${OUT}"/attestation

	insinto /usr/share/policy
	newins server/attestationd-seccomp-${ARCH}.policy attestationd-seccomp.policy
}

platform_pkg_test() {
	return 0
}
