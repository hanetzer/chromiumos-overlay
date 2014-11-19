# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="00e2e3c548c8d1c1d603b70b65ed7f289aca80bc"
CROS_WORKON_TREE="9971c6eaa3b2d2fdeb638343a42f025ad8e960fa"
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
