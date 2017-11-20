# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="40cd89a237f797ad9aa0ed36e5e1fde59c4c7b25"
CROS_WORKON_TREE="db7b61715d5b607a8b9906477827848a3563e9f8"
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
