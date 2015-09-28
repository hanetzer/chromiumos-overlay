# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="0c959e80d8acfedb1ecd50c9f14a58cee287dc95"
CROS_WORKON_TREE="cc3021ce1f12b5754bf924075f349f6447b76f4d"
CROS_WORKON_PROJECT="external/github.com/golang/protobuf"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/protobuf"

CROS_GO_PACKAGES=(
	"github.com/golang/protobuf/proto"
	"github.com/golang/protobuf/jsonpb"
)

CROS_GO_BINARIES=(
	"github.com/golang/protobuf/protoc-gen-go"
)

inherit cros-workon cros-go

DESCRIPTION="Go support for Google's protocol buffers"
HOMEPAGE="https://github.com/golang/protobuf"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE=""
RESTRICT="binchecks strip"

DEPEND=""
RDEPEND=""
