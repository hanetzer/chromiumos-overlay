# Copyright 1999-2009 Gentoo Foundation
# Copyright 2010 Google, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

inherit autotools base eutils linux-info

DESCRIPTION="An open-source TCG Software Stack (TSS) v1.1 implementation"
HOMEPAGE="http://trousers.sf.net"
LICENSE="CPL-1.0"
SLOT="0"
IUSE="doc"
KEYWORDS="x86 amd64 arm"

RDEPEND=">=dev-libs/glib-2
	>=x11-libs/gtk+-2
	>=dev-libs/openssl-0.9.7"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

## TODO: Check if this patch is useful for us.
## PATCHES=(	"${FILESDIR}/${PN}-0.2.3-nouseradd.patch" )

src_unpack() {
	if [ -n "$CHROMEOS_ROOT" ] ; then
		local third_party="${CHROMEOS_ROOT}/src/third_party"
		local trousers="${third_party}/trousers"
		elog "Using trousers dir: $trousers"
		mkdir -p "${S}"
		cp -a "${trousers}"/* "${S}" || die
                (cd "${S}"; make clean)  # removes possible garbage
	else
		die CHROMEOS_ROOT is not set
	fi
}

pkg_setup() {
	# New user/group for the daemon
	enewgroup tss
	enewuser tss -1 -1 /var/lib/tpm tss
}

src_prepare() {
	base_src_prepare

	sed -e "s/-Werror //" -i configure.in
	eautoreconf
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM
        export CCFLAGS="$CFLAGS"
        emake
}

src_install() {
	keepdir /var/lib/tpm
	emake DESTDIR="${D}" install || die
	dodoc AUTHORS ChangeLog NICETOHAVES README TODO
	use doc && dodoc doc/*
	newinitd "${FILESDIR}/tcsd.initd" tcsd
	newconfd "${FILESDIR}/tcsd.confd" tcsd
}

pkg_postinst() {
	elog "If you have problems starting tcsd, please check permissions and"
	elog "ownership on /dev/tpm* and ~tss/system.data"
}
