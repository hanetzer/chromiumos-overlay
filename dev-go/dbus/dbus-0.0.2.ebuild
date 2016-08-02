# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="25c3068a42a0b50b877953fb249dbcffc6bd1bca"
CROS_WORKON_TREE="9de3ae512491f80bd387ed687ce943259acadd13"
CROS_WORKON_PROJECT="external/github.com/godbus/dbus"
CROS_WORKON_DESTDIR="${S}/src/github.com/godbus/dbus"

DESCRIPTION="D-Bus library for Go."
HOMEPAGE="https://github.com/godbus/dbus"

CROS_GO_PACKAGES=(
	"github.com/godbus/dbus"
	"github.com/godbus/dbus/prop"
	"github.com/godbus/dbus/introspect"
)

inherit cros-workon cros-go

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""

# The unit tests try to connect to the dbus on host and fail.
RESTRICT="binchecks strip test"

DEPEND=""
RDEPEND=""
