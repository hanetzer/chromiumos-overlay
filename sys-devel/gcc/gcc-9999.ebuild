# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

# (Crosstool-based) ChromeOS toolchain related variables.
COST_VERSION="v1"
COST_CL="41723"
COST_SUFFIX="cos_gg_${COST_VERSION}_${COST_CL}"
COST_PKG_VERSION="gcc-9999_${COST_SUFFIX}-EXPERIMENTAL-9999"
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

SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/gcc-4.4.3-specs-0.2.0.tar.bz2"
RESTRICT="mirror strip"

IUSE="mounted_sources"

MY_PV=4.4.3
MY_P=${PN}-${MY_PV}
GITDIR=${WORKDIR}/gitdir
GITHASH=717a8906a9b85e79f584824f693a338012905730

src_unpack() {
  local GCCDIR
  if use mounted_sources ; then
    GCCDIR=/usr/local/toolchain_root/gcc/${MY_P}
    if [[ ! -d ${GCCDIR} ]] ; then
      die "gcc dir not mounted/present at: ${GCCDIR}"
    fi
  else
    mkdir ${GITDIR}
    cd ${GITDIR} || die "Could not enter ${GITDIR}"
    git clone http://git.chromium.org/git/gcc.git . || die "Could not clone repo."
    git checkout ${GITHASH} || die "Could not checkout ${GITHASH}"
    cd -
    GCCDIR=${GITDIR}/gcc/${MY_P}
  fi
 	ln -sf ${GCCDIR} ${S}

  # TODO(asharif): remove this and get the specs from the sources, if possible.
	if want_pie ; then
		[[ -n ${SPECS_VER} ]] && \
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

src_install()
{
	${ETYPE}_src_install
  if [[ ${PV} != "4.4.3" ]] ; then
    cp -r ${D}/usr/lib/gcc/${CTARGET}/${PV}/* ${D}/usr/lib/gcc/${CTARGET}/${MY_PV}/
  fi
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
  if use mounted_sources ; then
    local GCCBUILDDIR="/usr/local/toolchain_root/build-gcc"
    if [[ ! -d ${GCCBUILDDIR} ]] ; then
      die "build-gcc dir not mounted/present at: ${GCCBUILDIR}"
    fi
  else
    local GCCBUILDDIR="${GITDIR}/build-gcc"
  fi

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

  source ${GCCBUILDDIR}/opts.sh
  confgcc="${confgcc} $(get_gcc_configure_options ${CTARGET})"

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
