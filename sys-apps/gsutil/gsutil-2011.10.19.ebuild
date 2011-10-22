# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="2"

inherit eutils

DESCRIPTION="Google Storage utility library"
HOMEPAGE="http://code.google.com/p/gsutil/"

LICENSE="Apache-2"
SLOT="0"
KEYWORDS="x86 amd64"

RDEPEND=">=dev-lang/python-2.5.1"
BUCKET="http://commondatastorage.googleapis.com/chromeos-localmirror"
SRC_URI="${BUCKET}/distfiles/gsutil_${PV}.tar.gz"

src_install() {
	local path="${D}/usr/local/lib"
	elog "${path}"
	mkdir -p "${path}" || die
	cp -r $(dirname ${S})/* ${path} || die
	dosym /usr/local/lib/gsutil/gsutil /usr/local/bin/gsutil || die
}
