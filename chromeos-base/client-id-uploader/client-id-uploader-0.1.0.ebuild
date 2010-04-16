# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Client ID uploading script."

LICENSE="BSD"
SLOT="0"
KEYWORDS="arm x86"
IUSE=""

RDEPEND=""
DEPEND="dev-lang/python
        ${RDEPEND}"

src_install() {
	local platform="${CHROMEOS_ROOT}/src/platform"
	into /
	dodir /usr/bin
	install --owner=root --group=root --mode=0755 \
	  "${platform}/dev/client_id_uploader.py" "${D}/usr/bin"
}
