# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="7a27e99e3423c070aa2f7ce1bea0c9b20114a25a"
CROS_WORKON_TREE="865c86d688917b4d7359bf6041a9151879ce2009"
CROS_WORKON_PROJECT="chromiumos/third_party/tlsdate"

inherit autotools flag-o-matic toolchain-funcs cros-workon

DESCRIPTION="Update local time over HTTPS"
HOMEPAGE="https://github.com/ioerror/tlsdate"

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="+dbus"

DEPEND="dev-libs/openssl
	dbus? ( sys-apps/dbus )"
RDEPEND="${DEPEND}"

src_prepare() {
	eautoreconf
}

src_configure() {
	# Our unprivileged group is called "nobody"
	cros-workon_src_configure \
		$(use_enable dbus) \
		--with-unpriv-user=tlsdate \
		--with-unpriv-group=tlsdate \
		--with-dbus-user=tlsdate-dbus \
		--with-dbus-group=tlsdate-dbus
}

src_compile() {
	tc-export CC
	emake CFLAGS="-Wall ${CFLAGS} ${CPPFLAGS} ${LDFLAGS}"
}

src_install() {
	default
	insinto /etc/tlsdate
	doins "${FILESDIR}/tlsdated.conf"
	insinto /etc/dbus-1/system.d
	doins "${FILESDIR}/org.torproject.tlsdate.conf"
}
