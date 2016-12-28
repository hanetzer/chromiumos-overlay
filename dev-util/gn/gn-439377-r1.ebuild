# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

# When the time comes to roll to a new version, look up the SHA1 of the new
# gn binary at https://chromium.googlesource.com/chromium/buildtools/+/master/linux64/gn.sha1
# You can pull it down from gs://chromium-gn/
# and run `gn --version` to get the right version number for the ebuild.
# Once you do so, push the gn binary to gs://chromeos-localmirror/distfiles
# and be sure to mark it publicly visible:
#  gsutil cp gn gs://chromeos-localmirror/distfiles/gn-<SHA1>.bin
#  gsutil acl set public-read gs://chromeos-localmirror/distfiles/gn-<SHA1>.bin
#
# Once you've updated the ebuild, run `ebuild gn-<SVN>-r1 manifest` to generate
# the Manifest file.
GN_X64_SHA1="d2c9075aedbc0894ff2e573870d8ac35b37def57"

DESCRIPTION="GN (generate ninja) meta-build system"
HOMEPAGE="https://code.google.com/p/chromium/wiki/gn"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/gn-${GN_X64_SHA1}.bin"
RESTRICT="mirror"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="-* amd64"
IUSE=""

RDEPEND="dev-libs/libpcre
	dev-libs/glib"
DEPEND="net-misc/gsutil"

# See chromium:386603 for why we download a prebuilt binary instead of
# compiling it ourselves.

S="${WORKDIR}"  # Otherwise emerge fails because $S doesn't exist.

src_install() {
	newbin "${DISTDIR}/${A}" gn
}
