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

src_install() {
	local year=$(echo "${PV}" | cut -d. -f1)
	local month=$(echo "${PV}" | cut -d. -f2)
	local day=$(echo "${PV}" | cut -d. -f3)
	local package="gsutil_${month}-${day}-${year}.tar.gz"
	local path="${D}/usr/local/lib"

	elog "${path}"
	elog "${FILESDIR}/${package}"

	mkdir -p "${path}" || die
	cd "${path}" || die

	tar xzpf "${FILESDIR}/${package}" || die "Failed to untar ${package}"
	dosym /usr/local/lib/gsutil/gsutil /usr/local/bin/gsutil || die
}
