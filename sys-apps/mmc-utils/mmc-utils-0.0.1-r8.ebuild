# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="0f757347024b34237b867b43fa6faf87d502ec87"
CROS_WORKON_TREE="2a972513a0386062424d093910e6897118ad23c0"
CROS_WORKON_PROJECT="chromiumos/third_party/mmc-utils"

inherit cros-constants cros-workon toolchain-funcs

# original Announcement of project:
#	http://permalink.gmane.org/gmane.linux.kernel.mmc/12766
#
# Upstream GIT:
#   https://git.kernel.org/cgit/linux/kernel/git/cjb/mmc-utils.git/
#
# To grab a local copy of the mmc-utils source tree:
#   git clone git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git
#
# or to reference upstream in local mmc-utils tree:
#   git remote add upstream git://git.kernel.org/pub/scm/linux/kernel/git/cjb/mmc-utils.git
#   git remote update

DESCRIPTION="Userspace tools for MMC/SD devices"
HOMEPAGE="${CROS_GIT_HOST_URL}/${CROS_WORKON_PROJECT}"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE=""

src_configure() {
	cros-workon_src_configure
	tc-export CC
	export prefix=/usr
}
