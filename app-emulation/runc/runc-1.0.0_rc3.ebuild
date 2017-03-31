# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Use ebuild version to checkout the corresponding tag.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="v${PV/_/-}"
CROS_WORKON_PROJECT="external/github.com/opencontainers/runc"
CROS_WORKON_DESTDIR="${S}/src/github.com/opencontainers/runc"

CROS_GO_BINARIES=(
	"github.com/opencontainers/runc"
)

inherit cros-workon cros-go

DESCRIPTION="CLI tool for spawning and running containers according to the OCI specification"
HOMEPAGE="http://runc.io"

LICENSE="Apache-2.0"
SLOT="0"
KEYWORDS="-* amd64 ~arm64"
IUSE=""

RESTRICT="binchecks strip"

DEPEND="dev-go/go-sys"
RDEPEND=""

PATCHES=(
	"${FILESDIR}/runc-1.0.0_rc3-cpuset-noprefix.patch"
)

src_prepare() {
	cd "${CROS_WORKON_DESTDIR}"
	epatch "${PATCHES[@]}"
}
