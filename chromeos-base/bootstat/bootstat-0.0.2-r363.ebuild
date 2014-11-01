# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4

CROS_WORKON_COMMIT="34f389c09d54d79a993743315c924ab6e4b7c2d1"
CROS_WORKON_TREE="3be3592ae2186a4dcef533ae3eeb14bc1273cdf3"
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
