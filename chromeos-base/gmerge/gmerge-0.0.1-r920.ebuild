# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="420ed5114684d1f0cbe1acb8cda4b00b2f0ef24b"
CROS_WORKON_TREE="210c6a2c19215f6f0734f16f3bc4b53b0cdf951d"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"

inherit cros-workon

DESCRIPTION="A util for installing packages using the CrOS dev server"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="app-shells/bash
	dev-lang/python
	dev-util/shflags
	net-misc/wget
	sys-apps/portage"
DEPEND="${RDEPEND}"

CHROMEOS_PROFILE="/usr/local/portage/chromiumos/profiles/targets/chromeos"

src_install() {
	# Install tools from platform/dev into /usr/local/bin
	into /usr/local
	dobin gmerge stateful_update crdev

	# Setup package.provided so that gmerge will know what packages to ignore.
	# - $ROOT/etc/portage/profile/package.provided contains compiler tools and
	#   and is setup by setup_board. We know that that file will be present in
	#   $ROOT because the initial compile of packages takes place in
	#   /build/$BOARD.
	# - $CHROMEOS_PROFILE/package.provided contains packages that we don't
	#   want to install to the device.
	insinto /usr/local/etc/portage/make.profile/package.provided
	newins "${SYSROOT}"/etc/portage/profile/package.provided compiler
	newins "${CHROMEOS_PROFILE}"/package.provided chromeos
}
