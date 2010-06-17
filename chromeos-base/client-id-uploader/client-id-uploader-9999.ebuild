# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="Client ID uploading script."

inherit cros-workon

LICENSE="BSD"
SLOT="0"
KEYWORDS="~amd64 ~arm ~x86"
IUSE=""

RDEPEND=""
DEPEND="dev-lang/python
        ${RDEPEND}"

CROS_WORKON_LOCALNAME="dev"
CROS_WORKON_PROJECT="dev-util"

src_install() {
	dobin client_id_uploader.py || die
}
