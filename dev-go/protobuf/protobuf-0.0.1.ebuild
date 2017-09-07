# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit hash manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="0a4f71a498b7c4812f64969510bcb4eca251e33a"
CROS_WORKON_PROJECT="external/github.com/golang/protobuf"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/protobuf"

CROS_GO_PACKAGES=(
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/jsonpb"
	"github.com/golang/protobuf/ptypes/..."
)

CROS_GO_BINARIES=(
	"github.com/golang/protobuf/protoc-gen-go"
)

inherit cros-workon cros-go

DESCRIPTION="Go support for Protocol Buffers"
HOMEPAGE="https://github.com/golang/protobuf"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="test"
RESTRICT="binchecks strip"

DEPEND="test? ( dev-go/sync )"
RDEPEND=""
