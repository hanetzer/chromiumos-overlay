# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

PYTHON_COMPAT=( python2_7 )
inherit distutils-r1

# To uprev, replace the hash with the desired revision.
# revision="4d467626b0b9f59a85fb81ca4d7ea9eca99b9d8f"
# timestamp=$(TZ=UTC git show ${revision} --date=format-local:%Y.%m.%d.%H%M%S -s --format=%cd)
# git archive ${revision} -o gyp-${timestamp}.tar.gz --prefix=gyp-${timestamp}/
# gsutil cp -a public-read gyp-${timestamp}.tar.gz gs://chromeos-localmirror/distfiles/gyp-${timestamp}.tar.gz
# Rename the existing .ebuild file to gyp-${timestamp}.ebuild, updating the revision.
# ebuild gyp-${timestamp}.ebuild manifest

DESCRIPTION="GYP, a tool to generates native build files"
HOMEPAGE="https://gyp.gsrc.io/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${P}.tar.gz"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE=""

PATCHES=(
	"${FILESDIR}"/${P}-shlex-split-fix.patch
	"${FILESDIR}"/${P}-ninja-symlink-fix.patch
)
