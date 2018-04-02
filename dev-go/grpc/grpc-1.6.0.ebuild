# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
# The dev-go/grpc* packages are all built from this repo.  They should
# be updated together.
CROS_WORKON_COMMIT="v${PV}"
CROS_WORKON_PROJECT="external/github.com/grpc/grpc-go"
CROS_WORKON_DESTDIR="${S}/src/google.golang.org/grpc"

CROS_GO_PACKAGES=(
	"google.golang.org/grpc"
	"google.golang.org/grpc/benchmark/stats"
	"google.golang.org/grpc/codes"
	"google.golang.org/grpc/connectivity"
	"google.golang.org/grpc/credentials"
	"google.golang.org/grpc/grpclb/grpc_lb_v1/messages"
	"google.golang.org/grpc/grpclog"
	"google.golang.org/grpc/internal"
	"google.golang.org/grpc/keepalive"
	"google.golang.org/grpc/metadata"
	"google.golang.org/grpc/naming"
	"google.golang.org/grpc/peer"
	"google.golang.org/grpc/stats"
	"google.golang.org/grpc/status"
	"google.golang.org/grpc/tap"
	"google.golang.org/grpc/transport"
)

CROS_GO_TEST=(
	"${CROS_GO_PACKAGES[@]}"
)

inherit cros-workon cros-go

DESCRIPTION="Go implementation of gRPC"
HOMEPAGE="https://grpc.io/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND="
	dev-go/genproto
	dev-go/net
"
