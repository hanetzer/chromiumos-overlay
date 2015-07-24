# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

GITHUB_PATH="github.com/guelfey/go.dbus"

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="f6a3a2366cc39b8479cadc499d3c735fb10fbdda"
CROS_WORKON_TREE="c252d5e5bcae7590b6cf913187f91eadd73ab1a8"
CROS_WORKON_PROJECT="external/${GITHUB_PATH}"
CROS_WORKON_DESTDIR="${S}/src/${GITHUB_PATH}"

DESCRIPTION="D-Bus library for Go."
HOMEPAGE="https://${GITHUB_PATH}"

CROS_GO_PACKAGES=(
	"${GITHUB_PATH}"
	"${GITHUB_PATH}/prop"
	"${GITHUB_PATH}/introspect"
)

inherit cros-workon cros-go

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
