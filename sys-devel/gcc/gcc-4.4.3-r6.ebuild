# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

# (Crosstool-based) ChromeOS toolchain related variables.
COST_PKG_VERSION="${P}_cos_gg"

inherit eutils

GCC_FILESDIR="${PORTDIR}/sys-devel/gcc/files"

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

RESTRICT="mirror strip"

IUSE="gcj graphite gtk hardened hardfp mounted_sources multislot nls nocxx vanilla"

GCC_CONFIG_VER=${PV}
MY_PV=4.4.3
MY_P=${PN}-${MY_PV}
GITDIR=${WORKDIR}/gitdir
GITHASH=504a43ace5ea4e85a84bf7cddd3860d288d7ea01

is_crosscompile() { [[ ${CHOST} != ${CTARGET} ]] ; }

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

if use multislot ; then
	SLOT="${CTARGET}-${GCC_CONFIG_VER}"
else
	SLOT="${CTARGET}"
fi

PREFIX=/usr
LIBPATH=${PREFIX}/lib/gcc/${CTARGET}/${GCC_CONFIG_VER}
INCLUDEPATH=${LIBPATH}/include
if is_crosscompile ; then
	BINPATH=${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
else
	BINPATH=${PREFIX}/${CTARGET}/gcc-bin/${GCC_CONFIG_VER}
fi
DATAPATH=${PREFIX}/share/gcc-data/${CTARGET}/${GCC_CONFIG_VER}
STDCXX_INCDIR=${LIBPATH}/include/g++-v${GCC_CONFIG_VER}

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
		git clone http://git.chromium.org/chromiumos/third_party/gcc.git . || die "Could not clone repo."
		if [[ "${PV}" != "${MY_PV}" ]] ; then
			GITHASH=$(git rev-list --max-count=1 --all)
			echo "Getting latest hash: ${GITHASH}..."
		fi
		git checkout ${GITHASH} || die "Could not checkout ${GITHASH}"
		cd -
		GCCDIR=${GITDIR}/gcc/${MY_P}
		cd ${GCCDIR}
		CL=$(git log --pretty=format:%s -n1 | grep -o '[0-9]\+')
		cd -
	fi
	if [[ ! -z ${CL} ]] ; then
		COST_PKG_VERSION="${COST_PKG_VERSION}_${CL}"
	fi
	ln -sf ${GCCDIR} ${S}

	use vanilla && return 0
}

src_compile()
{
	src_configure
	pushd ${WORKDIR}/build
	ORIG_CFLAGS=$(portageq envvar CFLAGS)
	HARD_CFLAGS=''
	if use hardened && [[ ${CTARGET} != arm* ]] ;
	then
		HARD_CFLAGS='-DEFAULT_PIE_SSP -DEFAULT_RELRO -DEFAULT_BIND_NOW'
	fi
	emake CFLAGS="${HARD_CFLAGS} ${ORIG_CFLAGS}" LDFLAGS=-Wl,-O1 'STAGE1_CFLAGS=-O2 -pipe' LIBPATH=${LIBPATH} BOOT_CFLAGS=-O2 all
	popd
}

src_install()
{
	cd ${WORKDIR}/build
	emake DESTDIR="${D}" install || die "Could not install gcc"

	find "${D}" -name libiberty.a -exec rm -f "{}" \;

	TODIR="${D}/${PREFIX}/lib/gcc/${CTARGET}/${PV}"
	FROMDIR="${D}/${PREFIX}/${CTARGET}/lib"

	# setup_board expects libgcc_s.so, etc. to be in ${TODIR}
	rsync -a "${FROMDIR}/" "${TODIR}/"

	# gcc itself expects libgcc_s.so to be in the ${MY_PV} dir.
	if [[ "${PV}" != "${MY_PV}" ]] ; then
		rsync -a "${FROMDIR}/" "${D}/${PREFIX}/lib/gcc/${CTARGET}/${MY_PV}/"
	fi

	dodir /etc/env.d/gcc
	insinto /etc/env.d/gcc
	cat <<-EOF > env.d
LDPATH="${LIBPATH}"
MANPATH="${DATAPATH}/man"
INFOPATH="${DATAPATH}/info"
STDCXX_INCDIR="${STDCXX_INCDIR}"
CTARGET=${CTARGET}
GCC_PATH="${BINPATH}"
EOF
	newins env.d ${CTARGET}-${GCC_CONFIG_VER}
	cd -

	cd ${D}${BINPATH}
	cp --preserve=all "${FILESDIR}/sysroot_wrapper" .
	for x in c++ cpp g++ gcc; do
		if [[ -f "${CTARGET}-${x}" ]]; then
			mv "${CTARGET}-${x}" "${CTARGET}-${x}.real"
			ln -sf -T sysroot_wrapper "${CTARGET}-${x}"
		fi
		CCACHE_BIN=$(which ccache || true)
		mkdir -p "${D}/usr/lib/ccache/bin"
		if [ -f "${CCACHE_BIN}" ]; then
			ln -sf "${CCACHE_BIN}" "${D}/usr/lib/ccache/bin/${CTARGET}-${x}"
		fi
	done
}

pkg_postinst()
{
	gcc-config ${CTARGET}-${GCC_CONFIG_VER}
}

pkg_postrm()
{
	if is_crosscompile ; then
		if [[ -z $(ls "${ROOT}"/etc/env.d/gcc/${CTARGET}* 2>/dev/null) ]] ; then
			rm -f "${ROOT}"/etc/env.d/gcc/config-${CTARGET}
			rm -f "${ROOT}"/etc/env.d/??gcc-${CTARGET}
			rm -f "${ROOT}"/usr/bin/${CTARGET}-{gcc,{g,c}++}{,32,64}
		fi
		return 0
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
		GCC_LANG="c,c++"
	fi
	confgcc="${confgcc} --enable-languages=${GCC_LANG}"

	if use hardfp && [[ ${CTARGET} == arm* ]] ;
	then
		confgcc="${confgcc} --with-float=hard"
	fi

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

	EXTRA_ECONF="--with-bugurl=http://code.google.com/p/chromium-os/issues/entry\
 --with-pkgversion=${COST_PKG_VERSION} --enable-linker-build-id"
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
