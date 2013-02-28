# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="6d92043eb5736f293c39814c7818a3686aedb184"
CROS_WORKON_TREE="efda76ff82f69bbb21c40d376ee944dff6870c7b"
CROS_WORKON_PROJECT="chromiumos/third_party/tlsdate"

inherit autotools flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Update local time over HTTPS"
HOMEPAGE="https://github.com/ioerror/tlsdate"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="dbus"

DEPEND="dev-libs/openssl
	dbus? ( sys-apps/dbus )"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	# Our unprivileged group is called "nobody"
	econf $(use_enable dbus) --with-unpriv-group=nobody
}

src_compile() {
	tc-export CC
	emake CFLAGS="-Wall ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
}

src_install() {
	default
	insinto /etc/tlsdate
	doins "${FILESDIR}/tlsdated.conf"
}
