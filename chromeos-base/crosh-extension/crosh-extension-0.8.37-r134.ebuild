# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="44fc4707142a3cf08d21eb913ec9e8d49e1e732f"
CROS_WORKON_TREE="72075e8c3f1c20c4bfeae339893a7658078aae31"
CROS_WORKON_PROJECT="apps/libapps"
CROS_WORKON_LOCALNAME="../third_party/libapps"
CROS_WORKON_USE_VCSID="true"

inherit cros-workon

DESCRIPTION="The Chromium OS Shell extension (the HTML/JS rendering part)"
HOMEPAGE="https://chromium.googlesource.com/apps/libapps/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

RDEPEND="!<chromeos-base/common-assets-0.0.2"

e() {
	echo "$@"
	"$@" || die
}

src_compile() {
	cd nassh
	e ./bin/mkdeps.sh
	e ./bin/mkzip.sh
	e ./bin/mkcrosh.sh dist/zip/*.zip
}

src_install() {
	insinto /usr/share/chromeos-assets/crosh_builtin
	unzip -d crosh_builtin_deploy/ nassh/bin/crosh_builtin.zip || die
	doins -r crosh_builtin_deploy/*
}
