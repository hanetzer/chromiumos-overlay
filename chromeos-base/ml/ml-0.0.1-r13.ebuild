# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="0415e7bf95c1d09b63c903ae8fa6facda6c4de73"
CROS_WORKON_TREE=("5e90f79dec6430d855d27326141abc48491d5a63" "b641f52a79d1ef813c3ac6d05dc1dbee521530fe")
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_OUTOFTREE_BUILD=1
CROS_WORKON_INCREMENTAL_BUILD=1
CROS_WORKON_SUBTREE="common-mk ml"

PLATFORM_SUBDIR="ml"

inherit cros-workon platform user

DESCRIPTION="Machine learning service for Chromium OS"
HOMEPAGE="https://chromium.googlesource.com/chromiumos/platform2/+/master/ml"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND=""

DEPEND="${RDEPEND}"

src_install() {
	dobin "${OUT}"/ml_service

	insinto /etc/init
	doins init/*.conf

	# Install seccomp policy file.
	insinto /usr/share/policy
	newins "seccomp/ml_service-seccomp-${ARCH}.policy" ml_service-seccomp.policy
}

pkg_preinst() {
	enewuser "ml-service"
	enewgroup "ml-service"
}
