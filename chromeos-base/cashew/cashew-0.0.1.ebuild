# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit autotools cros-workon

DESCRIPTION="Chromium OS network usage tracking daemon"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE=""

RDEPEND="dev-cpp/gflags
	dev-cpp/glog
	dev-libs/dbus-c++"

DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	econf
}

src_compile() {
	emake clean-generic || die "emake clean failed"
	emake || die "emake failed"
}

src_test() {
	# TODO(vlaviano): build and run unit tests
	true
}

src_install() {
	emake DESTDIR="${D}" install || die "emake install failed"

	# TODO(vlaviano): do the following in autotools `make install` instead?

	# install upstart config file.
	dodir /etc/init
	install --owner=root --group=root --mode=0644 \
		"${S}"/src/cashew.conf "${D}"/etc/init/

	# create log directory
	dodir /var/log/cashew/
}
