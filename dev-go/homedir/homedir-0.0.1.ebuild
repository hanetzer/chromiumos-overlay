# Copyright 2018 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="b8bc1bf767474819792c23f32d8286a45736f1c6"
CROS_WORKON_PROJECT="external/github.com/mitchellh/go-homedir"
CROS_WORKON_DESTDIR="${S}/src/github.com/mitchellh/go-homedir"

CROS_GO_PACKAGES=(
	"github.com/mitchellh/go-homedir"
)

inherit cros-workon cros-go

DESCRIPTION="Go library for detecting the user's home directory"
HOMEPAGE="https://github.com/mitchellh/go-homedir"

LICENSE="MIT"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND="${DEPEND}"
