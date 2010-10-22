# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

# (Crosstool-based) ChromeOS toolchain related variables.
COST_VERSION="v1"
COST_CL="41723"
COST_SUFFIX="cos_gg_${COST_VERSION}_${COST_CL}"
COST_PKG_VERSION="gcc-4.4.3_${COST_SUFFIX}-EXPERIMENTAL-9999"
EXTRA_ECONF="--with-bugurl=http://code.google.com/p/chromium-os/issues/entry\
 --with-pkgversion=${COST_PKG_VERSION} --enable-linker-build-id"

PATCH_VER="1.2"
UCLIBC_VER="1.0"

ETYPE="gcc-compiler"
GCC_FILESDIR="${PORTDIR}/sys-devel/gcc/files"

# Hardened gcc 4 stuff
PIE_VER="0.4.5"
SPECS_VER="0.2.0"
# arch/libc configurations known to be stable with {PIE,SSP}-by-default
PIE_GLIBC_STABLE="x86 amd64 ppc ppc64 arm ia64"
PIE_UCLIBC_STABLE="x86 amd64 arm ppc ppc64"
SSP_STABLE="amd64 x86 amd64 ppc ppc64 arm"
# uclibc need tls and nptl support for SSP support
SSP_UCLIBC_STABLE=""
#end Hardened stuff

inherit toolchain_crosstool

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking. This Compiler is based off of Crosstoolv14."

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS="~alpha ~amd64 ~arm -hppa ~ia64 ~mips ~ppc ~ppc64 ~sh -sparc ~x86 ~x86-fbsd"

RDEPEND=">=sys-libs/zlib-1.1.4
	>=sys-devel/gcc-config-1.4
	virtual/libiconv
	>=dev-libs/gmp-4.2.1
	>=dev-libs/mpfr-2.3.2
	graphite? (
		>=dev-libs/ppl-0.10
		>=dev-libs/cloog-ppl-0.15.4
	)
	!build? (
		gcj? (
			gtk? (
				x11-libs/libXt
				x11-libs/libX11
				x11-libs/libXtst
				x11-proto/xproto
				x11-proto/xextproto
				>=x11-libs/gtk+-2.2
				x11-libs/pango
			)
			>=media-libs/libart_lgpl-2.1
			app-arch/zip
			app-arch/unzip
		)
		>=sys-libs/ncurses-5.2-r2
		nls? ( sys-devel/gettext )
	)"
DEPEND="${RDEPEND}
	test? ( >=dev-util/dejagnu-1.4.4 >=sys-devel/autogen-5.5.4 )
	>=sys-apps/texinfo-4.8
	>=sys-devel/bison-1.875
	elibc_glibc? ( >=sys-libs/glibc-2.8 )
	amd64? ( multilib? ( gcj? ( app-emulation/emul-linux-x86-xlibs ) ) )
	ppc? ( >=${CATEGORY}/binutils-2.17 )
	ppc64? ( >=${CATEGORY}/binutils-2.17 )
	>=${CATEGORY}/binutils-2.15.94"
PDEPEND=">=sys-devel/gcc-config-1.4"
if [[ ${CATEGORY} != cross-* ]] ; then
	PDEPEND="${PDEPEND} elibc_glibc? ( >=sys-libs/glibc-2.8 )"
fi

SRC_URI=""
RESTRICT="fetch mirror strip"

MY_PV=4.4.3
MY_P=${PN}-${MY_PV}

src_unpack() {
  if [[ $(whoami) == root ]]
  then
    MY_USER=${SUDO_USER}
  else
    MY_USER=${USER}
  fi
  local GCCDIR=/home/${MY_USER}/toolchain_root/gcc/${MY_P}
  if [[ ! -d ${GCCDIR} ]] ; then
    die "gcc dir not mounted at: ${GCCDIR}"
  fi
	ln -s ${GCCDIR} ${S}
###  cp -r ${GCCDIR} ${S}
###  chmod -R +w ${S}

  # TODO(asharif): remove this and get the specs from the sources, if possible.
	if want_pie ; then
		[[ -n ${SPECS_VER} ]] && \
      cd ${DISTDIR}
      wget http://build.chromium.org/mirror/chromiumos/mirror/distfiles/gcc-4.4.3-specs-0.2.0.tar.bz2
      cd -
			unpack ${MY_P}-specs-${SPECS_VER}.tar.bz2
	fi

	use vanilla && return 0
}

# TODO(asharif) Move the make command parameters to a different file.
# TODO(asharif) Try this with an arm board.
src_compile()
{
  src_configure
  pushd ${WORKDIR}/build
  make -j4 LDFLAGS=-Wl,-O1 'STAGE1_CFLAGS=-O2 -pipe' LIBPATH=/usr/lib/gcc/${CTARGET}/${GCC_CONFIG_VER} BOOT_CFLAGS=-O2 all 
  popd
}

pkg_setup() {
	gcc_pkg_setup

	if use graphite ; then
		ewarn "Graphite support is still experimental and unstable."
		ewarn "Any bugs resulting from the use of Graphite will not be fixed."
	fi
}

# TODO(asharif): Move this into a separate file and source it.
src_configure()
{
  local confgcc
	# Set configuration based on path variables
	confgcc="${confgcc} \
		--prefix=${PREFIX} \
		--bindir=${BINPATH} \
		--includedir=${INCLUDEPATH} \
		--datadir=${DATAPATH} \
		--mandir=${DATAPATH}/man \
		--infodir=${DATAPATH}/info \
		--with-gxx-include-dir=${STDCXX_INCDIR}"
	confgcc="${confgcc} --host=${CHOST}"
  confgcc="${confgcc} --target=${CTARGET}"
  confgcc="${confgcc} --build=${CBUILD}"
  # TODO(asharif): Build without these options.
  confgcc="${confgcc} --disable-libmudflap"
  confgcc="${confgcc} --disable-libssp"
  confgcc="${confgcc} --disable-libgomp"
  # Hardened option.
  confgcc="${confgcc} --enable-esp"
  # Language options for stage1/stage2.
  if use nocxx
  then
    GCC_LANG="c"
  else
    GCC_LANG="c,c++,fortran"
  fi
  confgcc="${confgcc} --enable-languages=${GCC_LANG}"

  local needed_libc="glibc"
  if [[ -n ${needed_libc} ]] ; then
    if ! has_version ${CATEGORY}/${needed_libc} ; then
      confgcc="${confgcc} --disable-shared --disable-threads --without-headers"
    elif built_with_use --hidden --missing false ${CATEGORY}/${needed_libc} crosscompile_opts_headers-only ; then
      confgcc="${confgcc} --disable-shared --with-sysroot=${PREFIX}/${CTARGET}"
    else
      confgcc="${confgcc} --with-sysroot=${PREFIX}/${CTARGET}"
    fi
  fi

	case $(tc-arch) in
		arm)	#264534
			local arm_arch="${CTARGET%%-*}"
			# Only do this if arm_arch is armv*
			if [[ ${arm_arch} == armv* ]] ; then
				# Convert armv7{a,r,m} to armv7-{a,r,m}
				[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}
				# Remove endian ('l' / 'eb')
				[[ ${arm_arch} == *l  ]] && arm_arch=${arm_arch%l}
				[[ ${arm_arch} == *eb ]] && arm_arch=${arm_arch%eb}
				confgcc="${confgcc} --with-arch=${arm_arch}"
			fi

			# Enable hardvfp
			if [[ ${CTARGET##*-} == *eabi ]] && [[ $(tc-is-hardfloat) == yes ]] && \
			    tc_version_is_at_least "4.5" ; then
			        confgcc="${confgcc} --with-float=hard"
			fi
			;;
		x86)
			confgcc="${confgcc} --with-arch=atom"
			;;
	esac
  confgcc="${confgcc} ${EXTRA_ECONF}"

  	# Build in a separate build tree
	mkdir -p "${WORKDIR}"/build
	pushd "${WORKDIR}"/build > /dev/null

	# and now to do the actual configuration
	addwrite /dev/zero
  echo "Running this:"
  echo "configure ${confgcc}"
	echo "${S}"/configure "$@"
	"${S}"/configure ${confgcc} || die "failed to run configure"
  popd > /dev/null
}
