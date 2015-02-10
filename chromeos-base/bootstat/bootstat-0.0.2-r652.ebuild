# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="58e4fa9c6d2a3f4df2fa0c7f10ff44f39f5f76a6"
CROS_WORKON_TREE="1691a27bf6623be625d6ae4de7c9024644904ff1"
CROS_WORKON_LOCALNAME="platform2"
CROS_WORKON_PROJECT="chromiumos/platform2"
CROS_WORKON_DESTDIR="${S}/platform2"

inherit cros-workon

DESCRIPTION="Chrome OS Boot Time Statistics Utilities"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="-asan -clang"
REQUIRED_USE="asan? ( clang )"

RDEPEND="sys-apps/rootdev"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_unpack() {
	cros-workon_src_unpack
	S+="/platform2/libchromeos/chromeos/bootstat"
}

src_configure() {
	clang-setup-env
	cros-workon_src_configure
	tc-export CC CXX AR PKG_CONFIG
}

src_install() {
	into /
	dosbin bootstat
	dosbin bootstat_archive
	dosbin bootstat_get_last
	dobin bootstat_summary
}
