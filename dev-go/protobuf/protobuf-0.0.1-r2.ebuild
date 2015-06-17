# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

# Disable cros-workon auto-uprev since this is an external package.
# Must manage commit/tree hashes manually.
CROS_WORKON_BLACKLIST="1"
CROS_WORKON_COMMIT="aece6fb931241ad332956db4f62798dfbea944b3"
CROS_WORKON_TREE="1e854c00c6a5fbb07ef61eb7a836c75b59cf25eb"
CROS_WORKON_PROJECT="external/github.com/golang/protobuf"
CROS_WORKON_DESTDIR="${S}/src/github.com/golang/protobuf"

CROS_GO_PACKAGES=(
	"github.com/golang/protobuf/proto"
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

src_compile() {
	cros_go build -v "github.com/golang/protobuf/protoc-gen-go"
}

src_install() {
	dobin protoc-gen-go
	cros-go_src_install
}
