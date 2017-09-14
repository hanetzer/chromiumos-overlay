# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="75c72d7311f647388987f513a20e738cc64b6b2a"
CROS_WORKON_TREE="4b6f5e60b102d060690b5cce851c2941845b6387"
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
