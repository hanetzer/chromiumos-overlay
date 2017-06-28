# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="ce3d4cfc062faac7115d44e5befec8b5a08c3faa"
CROS_WORKON_PROJECT="external/github.com/google/subcommands"
CROS_WORKON_DESTDIR="${S}/src/github.com/google/subcommands"

CROS_GO_PACKAGES=(
	"github.com/google/subcommands"
)

inherit cros-workon cros-go

DESCRIPTION="Go subcommand library"
HOMEPAGE="https://github.com/google/subcommands"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
