# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9fbcc126f375dd73b19ccc2ba1e23409e3de4a9b"
CROS_WORKON_TREE="d90788ae809e120f85e274b8f59bc2a6c7900420"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/dev-util"
CROS_WORKON_LOCALNAME="dev"

inherit cros-workon

DESCRIPTION="A util for installing packages using the CrOS dev server"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="app-shells/bash
	dev-lang/python
	dev-util/shflags
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
	insinto /usr/local/etc/make.profile/package.provided
	newins "${ROOT}"/etc/portage/profile/package.provided compiler
	newins "${CHROMEOS_PROFILE}"/package.provided chromeos
}

