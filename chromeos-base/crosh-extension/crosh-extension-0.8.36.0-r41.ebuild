# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="08d33b48a474cf40486f066d6cdfab748052654b"
CROS_WORKON_TREE="21aecc59eba1fed49e4a744594f23a9cf744da0b"
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
