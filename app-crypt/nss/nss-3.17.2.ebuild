# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/dev-libs/nss/nss-3.17.2.ebuild,v 1.1 2014/10/14 21:10:22 axs Exp $

EAPI=5
inherit eutils flag-o-matic multilib toolchain-funcs multilib-minimal

NSPR_VER="4.10.6-r1"
RTM_NAME="NSS_${PV//./_}_RTM"
# Rev of https://git.fedorahosted.org/cgit/nss-pem.git
PEM_GIT_REV="015ae754dd9f6fbcd7e52030ec9732eb27fc06a8"
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

DEPEND=">=virtual/pkgconfig-0-r1[${MULTILIB_USEDEP}]
	>=dev-libs/nspr-${NSPR_VER}[${MULTILIB_USEDEP}]
	>=dev-libs/nss-${PV}[${MULTILIB_USEDEP}]"
RDEPEND=">=dev-libs/nspr-${NSPR_VER}[${MULTILIB_USEDEP}]
	>=dev-libs/nss-${PV}[${MULTILIB_USEDEP}]
	>=dev-db/sqlite-3.8.2[${MULTILIB_USEDEP}]
	>=sys-libs/zlib-1.2.8-r1[${MULTILIB_USEDEP}]
	abi_x86_32? (
		!<=app-emulation/emul-linux-x86-baselibs-20140508-r12
		!app-emulation/emul-linux-x86-baselibs[-abi_x86_32(-)]
	)"

RESTRICT="test"

S="${WORKDIR}/${P}/${PN}"


src_unpack() {
	unpack ${A}
	if use nss-pem ; then
		mv "${PEM_P}"/nss/lib/ckfw/pem/ "${S}"/lib/ckfw/ || die
	fi
}

src_prepare() {
	# Custom changes for gentoo
	epatch "${FILESDIR}/${PN}-3.17.1-gentoo-fixups.patch"
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

	pushd coreconf >/dev/null || die
	# hack nspr paths
	echo 'INCLUDES += -I$(DIST)/include/dbm' \
		>> headers.mk || die "failed to append include"

	# modify install path
	sed -e '/CORE_DEPTH/s:SOURCE_PREFIX.*$:SOURCE_PREFIX = $(CORE_DEPTH)/dist:' \
		-i source.mk || die

	# Respect LDFLAGS
	sed -i -e 's/\$(MKSHLIB) -o/\$(MKSHLIB) \$(LDFLAGS) -o/g' rules.mk
	popd >/dev/null || die

	# Fix pkgconfig file for Prefix
	sed -i -e "/^PREFIX =/s:= /usr:= ${EPREFIX}/usr:" \
		config/Makefile || die

	# use host shlibsign if need be #436216
	if tc-is-cross-compiler ; then
		sed -i \
			-e 's:"${2}"/shlibsign:shlibsign:' \
			cmd/shlibsign/sign.sh || die
	fi

	# dirty hack
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../freebl/\$(OBJDIR):" \
		lib/ssl/config.mk || die
	sed -i -e "/CRYPTOLIB/s:\$(SOFTOKEN_LIB_DIR):../../lib/freebl/\$(OBJDIR):" \
		cmd/platlibs.mk || die

	multilib_copy_sources

	strip-flags
}

multilib_src_configure() {
	# Ensure we stay multilib aware
	sed -i -e "/@libdir@/ s:lib64:$(get_libdir):" config/Makefile || die
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
	local cc cppflags="${1}CPPFLAGS" cflags="${1}CFLAGS"
	if [[ ${1} == BUILD_ ]]; then
		cc=$(tc-getBUILD_CC)
	else
		cc=$(tc-getCC)
	fi
	echo > "${T}"/test.c || die
	${cc} ${!cppflags} ${!cflags} -c "${T}"/test.c -o "${T}/${1}test.o" || die
	case $(file "${T}/${1}test.o") in
		*32-bit*x86-64*) echo USE_X32=1;;
		*64-bit*|*ppc64*|*x86_64*) echo USE_64=1;;
		*32-bit*|*ppc*|*i386*) ;;
		*) die "Failed to detect whether ${cc} builds 64bits or 32bits, disable distcc if you're using it, please";;
	esac
}

multilib_src_compile() {
	# use ABI to determine bit'ness, or fallback if unset
	local buildbits mybits
	case "${ABI}" in
		n32) mybits="USE_N32=1";;
		x32) mybits="USE_X32=1";;
		s390x|*64) mybits="USE_64=1";;
		${DEFAULT_ABI})
			einfo "Running compilation test to determine bit'ness"
			mybits=$(nssbits)
			;;
	esac
	# bitness of host may differ from target
	if tc-is-cross-compiler; then
		buildbits=$(nssbits BUILD_)
	fi

	local makeargs=(
		CC="$(tc-getCC)"
		AR="$(tc-getAR) rc \$@"
		RANLIB="$(tc-getRANLIB)"
		OPTIMIZER=
		${mybits}
	)

	# Take care of nspr settings #436216
	local myCPPFLAGS="${CPPFLAGS} $($(tc-getPKG_CONFIG) nspr --cflags)"
	unset NSPR_INCLUDE_DIR

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
	export FREEBL_NO_DEPEND=1
	export ASFLAGS=""

	local d

	# Build the host tools first.
	LDFLAGS="${BUILD_LDFLAGS}" \
	XCFLAGS="${BUILD_CFLAGS}" \
	NSPR_LIB_DIR="${T}/fakedir" \
	emake -j1 -C coreconf \
		CC="$(tc-getBUILD_CC)" \
		${buildbits:-${mybits}}
	makeargs+=( NSINSTALL="${PWD}/$(find -type f -name nsinstall)" )

	# Then build the target tools.
	for d in . lib/dbm ; do
		CPPFLAGS="${myCPPFLAGS}" \
		XCFLAGS="${CFLAGS} ${CPPFLAGS}" \
		NSPR_LIB_DIR="${T}/fakedir" \
		emake -j1 "${makeargs[@]}" -C ${d}
	done
}

multilib_src_install() {
	local f nssutils
	# The tests we do not need to install.
	#nssutils_test="bltest crmftest dbtest dertimetest
	#fipstest remtest sdrtest"
	nssutils="addbuiltin atob baddbdir btoa certcgi certutil checkcert
	cmsutil conflict crlutil derdump digest makepqg mangle modutil multinit
	nonspr10 ocspclnt oidcalc p7content p7env p7sign p7verify pk11mode
	pk12util pp rsaperf selfserv signtool signver ssltap strsclnt
	symkeyutil tstclnt vfychain vfyserv"
	pushd dist/*/bin >/dev/null || die
	into /usr/local
	for f in ${nssutils}; do
		# TODO(cmasone): switch to normal nss tool names
		dobin ${f}
		dosym ${f} /usr/local/bin/nss${f}
	done
	popd >/dev/null || die
}

