# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="9313baa13d9262e49d07b20ed57dceafcd7240cc"
CROS_WORKON_TREE="ff5ac4f882fe80a20d838792b0d7d4c405a6797a"
CROS_WORKON_REPO="https://go.googlesource.com"
CROS_WORKON_PROJECT="net"
CROS_WORKON_DESTDIR="${S}/src/golang.org/x/net"

CROS_GO_PACKAGES=(
	"golang.org/x/net/bpf"
	"golang.org/x/net/context"
	"golang.org/x/net/internal/iana"
	"golang.org/x/net/internal/netreflect"
	"golang.org/x/net/ipv4"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Go supplementary network libraries"
HOMEPAGE="https://golang.org/x/net"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
