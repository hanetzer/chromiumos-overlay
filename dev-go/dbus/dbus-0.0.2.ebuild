# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

GITHUB_PATH="github.com/godbus/dbus"

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="25c3068a42a0b50b877953fb249dbcffc6bd1bca"
CROS_WORKON_TREE="9de3ae512491f80bd387ed687ce943259acadd13"
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
