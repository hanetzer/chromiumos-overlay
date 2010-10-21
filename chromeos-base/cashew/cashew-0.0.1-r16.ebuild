# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="ab45a69eed6581c29224db2b806d768ac21ae157"

inherit cros-workon autotools

DESCRIPTION="Chromium OS network usage tracking daemon"
HOMEPAGE="http://src.chromium.org"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

RDEPEND="chromeos-base/libchrome
	dev-cpp/gflags
	dev-cpp/glog
	dev-libs/dbus-c++
        dev-libs/glib
	net-misc/curl"

DEPEND="${RDEPEND}"

src_prepare() {
	eautoreconf
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
		"${S}"/cashew.conf "${D}"/etc/init

	# install D-Bus config file.
	dodir /etc/dbus-1/system.d
	install --owner=root --group=root --mode=0644 \
		"${S}"/org.chromium.Cashew.conf "${D}"/etc/dbus-1/system.d

	# TODO(vlaviano): install introspection xml files somewhere?
}
