# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/net-misc/openvpn/openvpn-2.1.4.ebuild,v 1.8 2011/03/21 08:22:40 xarthisius Exp $

EAPI=4

inherit eutils multilib toolchain-funcs autotools flag-o-matic user

DESCRIPTION="Robust and highly flexible tunneling application compatible with many OSes."
SRC_URI="http://swupdate.openvpn.org/community/releases/${P}.tar.gz"
HOMEPAGE="http://openvpn.net/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="down-root eurephia examples iproute2 ipv6 +lzo minimal pam passwordsave pkcs11 selinux ssl static userland_BSD"

DEPEND="kernel_linux? (
		iproute2? ( sys-apps/iproute2[-minimal] ) !iproute2? ( sys-apps/net-tools )
	)
	lzo? ( >=dev-libs/lzo-1.07 )
	!minimal? ( pam? ( virtual/pam ) )
	selinux? ( sec-policy/selinux-openvpn )
	ssl? ( >=dev-libs/openssl-0.9.6 )
	pkcs11? ( >=dev-libs/pkcs11-helper-1.05 )"
RDEPEND="${DEPEND}"

src_prepare() {
	epatch "${FILESDIR}"/openvpn-2.3.2-pkcs11-slot.patch
	epatch "${FILESDIR}"/openvpn-2.3.2-iv_plat.patch
	epatch "${FILESDIR}"/openvpn-2.3.2-redirect-gateway.patch
	eautoreconf
}

src_configure() {
	use static && LDFLAGS="${LDFLAGS} -Xcompiler -static"
	econf \
		$(use_enable passwordsave password-save) \
		$(use_enable pkcs11) \
		$(use_enable ssl) \
		$(use_enable ssl crypto) \
		$(use_enable iproute2) \
		$(use_enable lzo)
		$(use_enable pam plugin-auth-pam) \
		$(use_enable down-root plugin-down-root)
}

src_install() {
	default
	find "${ED}/usr" -name '*.la' -delete
}

pkg_postinst() {
	# Add openvpn user so openvpn servers can drop privs
	# Clients should run as root so they can change ip addresses,
	# dns information and other such things.
	enewgroup openvpn
	enewuser openvpn "" "" "" openvpn
}
