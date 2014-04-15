# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nss/nss-3.16.ebuild,v 1.9 2014/03/31 17:11:39 axs Exp $

EAPI=5
inherit eutils flag-o-matic multilib toolchain-funcs

NSPR_VER="4.10"
RTM_NAME="NSS_${PV//./_}_RTM"
# Rev of https://git.fedorahosted.org/cgit/nss-pem.git
PEM_GIT_REV="3ade37c5c4ca5a6094e3f4b2e4591405db1867dd"
PEM_P="${PN}-pem-${PEM_GIT_REV}"

DESCRIPTION="Mozilla's Network Security Services library that implements PKI support"
HOMEPAGE="http://www.mozilla.org/projects/security/pki/nss/"
SRC_URI="ftp://ftp.mozilla.org/pub/mozilla.org/security/nss/releases/${RTM_NAME}/src/${P}.tar.gz
	cacert? ( http://dev.gentoo.org/~anarchy/patches/${PN}-3.14.1-add_spi+cacerts_ca_certs.patch )
	nss-pem? ( https://git.fedorahosted.org/cgit/nss-pem.git/snapshot/${PEM_P}.tar.bz2 )"

LICENSE="|| ( MPL-2.0 GPL-2 LGPL-2.1 )"
SLOT="0"
KEYWORDS="*"
IUSE="+cacert +nss-pem"

DEPEND="virtual/pkgconfig
	>=dev-libs/nspr-${NSPR_VER}
	>=dev-libs/nss-${PV}"
RDEPEND=">=dev-libs/nspr-${NSPR_VER}
	>=dev-libs/nss-${PV}
	>=dev-db/sqlite-3.5
	sys-libs/zlib"

RESTRICT="test"

S="${WORKDIR}/${P}/${PN}"

src_setup() {
	export LC_ALL="C"
}

src_unpack() {
	unpack ${A}
	if use nss-pem ; then
		mv "${PEM_P}"/nss/lib/ckfw/pem/ "${S}"/lib/ckfw/ || die
	fi
}

src_prepare() {
	# Custom changes for gentoo
	epatch "${FILESDIR}/${PN}-3.15-gentoo-fixups.patch"
	epatch "${FILESDIR}/${PN}-3.15-gentoo-fixup-warnings.patch"
	use cacert && epatch "${DISTDIR}/${PN}-3.14.1-add_spi+cacerts_ca_certs.patch"
	use nss-pem && epatch "${FILESDIR}/${PN}-3.15.4-enable-pem.patch"
	epatch "${FILESDIR}/nss-3.14.2-solaris-gcc.patch"
	# Add a public API to set the certificate nickname (PKCS#11 CKA_LABEL
	# attribute). See http://crosbug.com/19403 for details.
	epatch "${FILESDIR}"/${PN}-3.15-chromeos-cert-nicknames.patch

	# Abort the process if /dev/urandom cannot be opened (eg: when sandboxed)
	# See http://crosbug.com/29623 for details.
	epatch "${FILESDIR}"/${PN}-3.15-abort-on-failed-urandom-access.patch

	# Backport NSS 3.16.2's RSA-OAEP enabling, along with the consistency
	# checks for AES-KW data and RSA private keys
	epatch "${FILESDIR}"/${PN}-3.16-chromeos-oaep-and-aeskw.patch

	cd coreconf
	# hack nspr paths
	echo 'INCLUDES += -I$(DIST)/include/dbm' \
		>> headers.mk || die "failed to append include"

	# modify install path
	sed -e 's:SOURCE_PREFIX = $(CORE_DEPTH)/\.\./dist:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk

	# Ensure we stay multilib aware
	sed -i -e "/@libdir@/ s:lib64:$(get_libdir):" "${S}"/config/Makefile

	# Fix pkgconfig file for Prefix
	sed -i -e "/^PREFIX =/s:= /usr:= ${EPREFIX}/usr:" \
		"${S}"/config/Makefile

	# use host shlibsign if need be #436216
	if tc-is-cross-compiler ; then
		sed -i \
			-e 's:"${2}"/shlibsign:shlibsign:' \
			"${S}"/cmd/shlibsign/sign.sh
	fi

	# dirty hack
	cd "${S}"
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../freebl/\$(OBJDIR):" \
		lib/ssl/config.mk
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../../lib/freebl/\$(OBJDIR):" \
		cmd/platlibs.mk
}

nssarch() {
	# Most of the arches are the same as $ARCH
	local t=${1:-${CHOST}}
	case ${t} in
	aarch64*)echo "aarch64";;
	hppa*)   echo "parisc";;
	i?86*)   echo "i686";;
	x86_64*) echo "x86_64";;
	*)       tc-arch ${t};;
	esac
}

nssbits() {
	local cc="${1}CC" cppflags="${1}CPPFLAGS" cflags="${1}CFLAGS"
	echo > "${T}"/test.c || die
	${!cc} ${!cppflags} ${!cflags} -c "${T}"/test.c -o "${T}"/test.o || die
	case $(file "${T}"/test.o) in
	*32-bit*x86-64*) echo USE_X32=1;;
	*64-bit*|*ppc64*|*x86_64*) echo USE_64=1;;
	*32-bit*|*ppc*|*i386*) ;;
	*) die "Failed to detect whether your arch is 64bits or 32bits, disable distcc if you're using it, please";;
	esac
}

src_compile() {
	strip-flags

	tc-export AR RANLIB {BUILD_,}{CC,PKG_CONFIG}
	local makeargs=(
		CC="${CC}"
		AR="${AR} rc \$@"
		RANLIB="${RANLIB}"
		OPTIMIZER=
		$(nssbits)
	)

	# Take care of nspr settings #436216
	append-cppflags $(${PKG_CONFIG} nspr --cflags)
	append-ldflags $(${PKG_CONFIG} nspr --libs-only-L)
	unset NSPR_INCLUDE_DIR
	export NSPR_LIB_DIR=${T}/fake-dir

	# Do not let `uname` be used.
	if use kernel_linux ; then
		makeargs+=(
			OS_TARGET=Linux
			OS_RELEASE=2.6
			OS_TEST="$(nssarch)"
		)
	fi

	export BUILD_OPT=1
	export NSS_USE_SYSTEM_SQLITE=1
	export NSDISTMODE=copy
	export NSS_ENABLE_ECC=1
	export XCFLAGS="${CFLAGS} ${CPPFLAGS}"
	export FREEBL_NO_DEPEND=1
	export ASFLAGS=""

	local d

	# Build the host tools first.
	LDFLAGS="${BUILD_LDFLAGS}" \
	XCFLAGS="${BUILD_CFLAGS}" \
	emake -j1 -C coreconf \
		CC="${BUILD_CC}" \
		$(nssbits BUILD_)
	makeargs+=( NSINSTALL="${PWD}/$(find -type f -name nsinstall)" )

	# Then build the target tools.
	for d in . lib/dbm ; do
		emake -j1 "${makeargs[@]}" -C ${d}
	done
}

src_install() {
	local f nssutils
	# The tests we do not need to install.
	#nssutils_test="bltest crmftest dbtest dertimetest
	#fipstest remtest sdrtest"
	nssutils="addbuiltin atob baddbdir btoa certcgi certutil checkcert
	cmsutil conflict crlutil derdump digest makepqg mangle modutil multinit
	nonspr10 ocspclnt oidcalc p7content p7env p7sign p7verify pk11mode
	pk12util pp rsaperf selfserv signtool signver ssltap strsclnt
	symkeyutil tstclnt vfychain vfyserv"
	cd "${S}"/dist/*/bin/
	into /usr/local
	for f in ${nssutils}; do
		# TODO(cmasone): switch to normal nss tool names
		dobin ${f}
		dosym ${f} /usr/local/bin/nss${f}
	done
}

