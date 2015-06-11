# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="5"

DESCRIPTION="Install all runtime dependencies of cbuildbot"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="${RDEPEND}
	app-arch/pbzip2
	app-arch/unzip
	app-arch/xz-utils
	app-crypt/gnupg
	dev-libs/protobuf
	dev-python/google-api-python-client
	dev-python/mysql-python
	dev-python/python-statsd
	dev-python/sqlalchemy
	dev-vcs/git
	dev-vcs/repo
	dev-vcs/subversion
	sys-apps/gawk
"

DEPEND=""
