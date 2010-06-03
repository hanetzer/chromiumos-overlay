# Copyright 1999-2009 Gentoo Foundation
# Copyright 2010 Google, Inc.
# Distributed under the terms of the GNU General Public License v2
# $Header$

EAPI="2"

KEYWORDS="~amd64 ~arm ~x86"
if [[ ${PV} != "9999" ]] ; then
	KEYWORDS="amd64 arm x86"
fi

inherit autotools base eutils git linux-info

DESCRIPTION="An open-source TCG Software Stack (TSS) v1.1 implementation"
HOMEPAGE="http://trousers.sf.net"
LICENSE="CPL-1.0"
CHROMEOS_GIT_REPO=${CHROMEOS_GIT_REPO:-"http://src.chromium.org/git"}
CHROMEOS_SRCROOT=${CHROMEOS_SRCROOT:-"${CHROMEOS_ROOT}/src/third_party/"}
EGIT_REPO_URI="${CHROMEOS_GIT_REPO}/trousers.git"
EGIT_COMMIT="master"

SLOT="0"
IUSE="doc"

RDEPEND=">=dev-libs/glib-2
	>=x11-libs/gtk+-2
	>=dev-libs/openssl-0.9.7"

DEPEND="${RDEPEND}
	dev-util/pkgconfig"

## TODO: Check if this patch is useful for us.
## PATCHES=(	"${FILESDIR}/${PN}-0.2.3-nouseradd.patch" )

src_unpack() {
	if [[ -n "${CHROMEOS_ROOT}" || "${PV}" == "9999" ]] ; then
		mkdir -p "${S}"
		cp -a "${CHROMEOS_SRCROOT}"/trousers/* "${S}" || die
                (cd "${S}"; make clean)  # removes possible garbage
	else
		git_src_unpack
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
