# Copyright 2012 The Chromium OS Authors
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
CROS_WORKON_COMMIT="fc78f7e8d4c6acc8ab8bd82fa7d23648838c4009"
CROS_WORKON_TREE="ab25be94bc75a396c2db61d29fc663b5215b6de4"
CROS_WORKON_PROJECT="chromiumos/third_party/tlsdate"

inherit autotools flag-o-matic toolchain-funcs cros-workon cros-debug

DESCRIPTION="Update local time over HTTPS"
HOMEPAGE="https://github.com/ioerror/tlsdate"

LICENSE="BSD"
SLOT="0"
KEYWORDS="*"
IUSE="asan clang +dbus +seccomp"
REQUIRED_USE="asan? ( clang )"

DEPEND="dev-libs/openssl
	dev-libs/libevent
	dbus? ( sys-apps/dbus )"
RDEPEND="${DEPEND}
	chromeos-base/chromeos-ca-certificates
	!<chromeos-base/chromeos-init-0.0.6
"

src_prepare() {
	eautoreconf
}

src_configure() {
	# TODO(wad) Migrate off of proxystate by updating libCrosService
	cros-workon_src_configure \
		$(use_enable dbus) \
		$(use_enable seccomp seccomp-filter) \
		$(use_enable cros-debug seccomp-debugging) \
		--enable-cros \
		--with-dbus-client-group=chronos \
		--with-unpriv-user=proxystate \
		--with-unpriv-group=proxystate
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
	doins "${S}/dbus/org.torproject.tlsdate.conf"
	insinto /usr/share/dbus-1/interfaces
	doins "${S}/dbus/org.torproject.tlsdate.xml"
	insinto /usr/share/dbus-1/services
	doins "${S}/dbus/org.torproject.tlsdate.service"
	insinto /etc/init
	doins init/tlsdated.conf
}
