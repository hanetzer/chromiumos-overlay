# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

EAPI=1

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
	>=dev-libs/mpc-0.8.1
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

IUSE="gcj graphite gtk hardened hardfp mounted_gcc multilib multislot nls
			nocxx openmp tests +thumb upstream_gcc vanilla"

if [[ "${PV}" == "9999" ]]
then
	if [[ -z $GCC_PV ]]
	then
		GCC_PV=4.6.0
	fi
else
	GCC_PV=${PV}
fi
MY_P=${PN}-${GCC_PV}
GITDIR=${WORKDIR}/gitdir

is_crosscompile() { [[ ${CHOST} != ${CTARGET} ]] ; }

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} = ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

if use multislot ; then
	SLOT="${CTARGET}-${PV}"
else
	SLOT="${CTARGET}"
fi

PREFIX=/usr
LIBDIR=${PREFIX}/lib/gcc/${CTARGET}/${GCC_PV}
INCLUDEDIR=${LIBDIR}/include
if is_crosscompile ; then
	BINDIR=${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/${GCC_PV}
else
	BINDIR=${PREFIX}/${CTARGET}/gcc-bin/${GCC_PV}
fi
DATADIR=${PREFIX}/share/gcc-data/${CTARGET}/${GCC_PV}

GCC_CONFIG_FILE=${CTARGET}-${GCC_PV}


src_unpack() {

	if use mounted_gcc ; then
		if [[ ! -d "$(get_gcc_dir)" ]] ; then
			die "gcc dir not mounted/present at: $(get_gcc_dir)"
		fi
	elif use upstream_gcc ; then
		GCC_MIRROR=ftp://mirrors.kernel.org/gnu/gcc
		GCC_TARBALL=${GCC_MIRROR}/${MY_P}/${MY_P}.tar.bz2
		wget $GCC_TARBALL
		tar xf ${GCC_TARBALL##*/}
	else
		mkdir ${GITDIR}
		cd ${GITDIR} || die "Could not enter ${GITDIR}"
		git clone http://git.chromium.org/chromiumos/third_party/gcc.git . || die "Could not clone repo."
		if [[ "${PV}" == "9999" ]] ; then
			: ${GCC_GITHASH:=gcc.gnu.org/branches/google/gcc-4_6-mobile}
		else
			GCC_GITHASH=23c043ea7578b21b46f96ea39d1a0ec0ac95bae6
		fi
		einfo "Checking out ${GCC_GITHASH}."
		git checkout ${GCC_GITHASH} || \
			die "Could not checkout ${GCC_GITHASH}"
		cd -
		CL=$(cd ${GITDIR}; git log --pretty=format:%s -n1 | grep -o '[0-9]\+')
	fi


	if [[ ! -z ${CL} ]] ; then
		COST_PKG_VERSION="${COST_PKG_VERSION}_${CL}"
	fi

	if [[ "$(readlink -f $(get_gcc_dir))" != "$(readlink -f ${S})" ]]
	then
		ln -sf "$(get_gcc_dir)" "${S}"
	fi

	use vanilla && return 0
}

src_compile()
{
	src_configure
	cd $(get_gcc_build_dir) || "Build dir $(get_gcc_build_dir) not found"
	GCC_CFLAGS="$(portageq envvar CFLAGS)"
	TARGET_FLAGS=""

	if use hardened && [[ ${CTARGET} != arm* ]]
	then
		TARGET_FLAGS="${TARGET_FLAGS} -fstack-protector-all -D_FORTIFY_SOURCE=2"
	fi

	emake CFLAGS="${GCC_CFLAGS}" \
		LDFLAGS="-Wl,-O1" \
		STAGE1_CFLAGS="-O2 -pipe" \
		BOOT_CFLAGS="-O2" \
		CFLAGS_FOR_TARGET="$(get_make_var CFLAGS_FOR_TARGET) ${TARGET_FLAGS}" \
		CXXFLAGS_FOR_TARGET="$(get_make_var CXXFLAGS_FOR_TARGET) ${TARGET_FLAGS}" \
		all || die
}

src_install()
{
	cd $(get_gcc_build_dir) || "Build dir $(get_gcc_build_dir) not found"
	emake DESTDIR="${D}" install || die "Could not install gcc"

	find "${D}" -name libiberty.a -exec rm -f "{}" \;

	# Move the libraries to the proper location
	gcc_movelibs

	# Move pretty-printers to gdb datadir to shut ldconfig up
	gcc_move_pretty_printers

	dodir /etc/env.d/gcc
	insinto /etc/env.d/gcc

	local LDPATH=${LIBDIR}/gcc/${CTARGET}/$(get_gcc_base_ver)
	for SUBDIR in 32 64 ; do
		if [[ -d ${D}/${LDPATH}/${SUBDIR} ]]
		then
			LDPATH="${LDPATH}:${LDPATH}/${SUBDIR}"
		fi
	done

	cat <<-EOF > env.d
LDPATH="${LDPATH}"
MANPATH="${DATADIR}/man"
INFOPATH="${DATADIR}/info"
STDCXX_INCDIR="$(get_stdcxx_incdir)"
CTARGET=${CTARGET}
GCC_PATH="${BINDIR}"
EOF
	newins env.d $GCC_CONFIG_FILE
	cd -

	if is_crosscompile ; then
		if use hardened && [[ ${CTARGET} != arm* ]]
		then
			SYSROOT_WRAPPER_FILE=sysroot_wrapper.hardened
		else
			SYSROOT_WRAPPER_FILE=sysroot_wrapper
		fi

		cd ${D}${BINDIR}
		exeinto "${BINDIR}"
		doexe "${FILESDIR}/${SYSROOT_WRAPPER_FILE}" || die
		for x in c++ cpp g++ gcc; do
			if [[ -f "${CTARGET}-${x}" ]]; then
				mv "${CTARGET}-${x}" "${CTARGET}-${x}.real"
				dosym "${SYSROOT_WRAPPER_FILE}" "${BINDIR}/${CTARGET}-${x}" || die
			fi
		done
	fi

	if use tests
	then
		TEST_INSTALL_DIR="usr/local/dejagnu/gcc"
		dodir ${TEST_INSTALL_DIR}
		cd ${D}/${TEST_INSTALL_DIR}
		tar -czf "tests.tar.gz" ${WORKDIR}
	fi
}

pkg_postinst()
{
	gcc-config $GCC_CONFIG_FILE
	CCACHE_BIN=$(which ccache || true)
	if is_crosscompile && [[ -f "${CCACHE_BIN}" ]] ; then
		mkdir -p "/usr/lib/ccache/bin"
		for x in c++ cpp g++ gcc; do
			dosym "${CCACHE_BIN}" "/usr/lib/ccache/bin/${CTARGET}-${x}" || die
		done
	fi
}

pkg_postrm()
{
	if is_crosscompile ; then
		if [[ -z $(ls "${ROOT}"/etc/env.d/gcc/${CTARGET}* 2>/dev/null) ]] ; then
			rm -f "${ROOT}"/etc/env.d/gcc/config-${CTARGET}
			rm -f "${ROOT}"/etc/env.d/??gcc-${CTARGET}
			rm -f "${ROOT}"/usr/bin/${CTARGET}-{gcc,{g,c}++}{,32,64}
		fi
	fi
	if is_crosscompile &&
		[[ $(equery l gcc | grep i686-pc-linux-gnu | wc -l) -eq 1 ]] ; then
		for x in c++ cpp g++ gcc; do
			rm -rf "/usr/lib/ccache/bin/${CTARGET}-${x}"
		done
	fi
}

src_configure()
{
	if use mounted_gcc && [[ -f $(get_gcc_build_dir)/Makefile ]] ; then
		return
	fi
	SLIBDIR="${LIBDIR}/gcc/${CTARGET}/$(get_gcc_base_ver)"

	# Set configuration based on path variables
	local confgcc="$(use_enable multilib)
		--prefix=${PREFIX} \
		--with-slibdir=${SLIBDIR} \
		--libdir=${LIBDIR} \
		--bindir=${BINDIR} \
		--includedir=${INCLUDEDIR} \
		--datadir=${DATADIR} \
		--mandir=${DATADIR}/man \
		--infodir=${DATADIR}/info \
		--enable-version-specific-runtime-libs \
		--with-gxx-include-dir=$(get_stdcxx_incdir)"
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

	if use thumb && [[ ${CTARGET} == arm* ]] ;
	then
		confgcc="${confgcc} --with-mode=thumb"
	fi

	if is_crosscompile ; then
		local needed_libc="glibc"
		if [[ -n ${needed_libc} ]] ; then
			if ! has_version ${CATEGORY}/${needed_libc} ; then
				confgcc="${confgcc} --disable-shared --disable-threads --without-headers"
			elif built_with_use --hidden --missing false ${CATEGORY}/${needed_libc} crosscompile_opts_headers-only ; then
				confgcc="${confgcc} --disable-shared --with-sysroot=/usr/${CTARGET}"
			else
				confgcc="${confgcc} --with-sysroot=/usr/${CTARGET}"
			fi
		fi
	else
		confgcc="${confgcc} --enable-shared --enable-threads=posix"
	fi

	confgcc="${confgcc} $(get_gcc_configure_options ${CTARGET})"

	EXTRA_ECONF="--with-bugurl=http://code.google.com/p/chromium-os/issues/entry\
	--with-pkgversion=${COST_PKG_VERSION} --enable-linker-build-id"
	confgcc="${confgcc} ${EXTRA_ECONF}"

	# Build in a separate build tree
	mkdir -p $(get_gcc_build_dir) || \
		die "Could not create build dir $(get_gcc_build_dir)"
	cd $(get_gcc_build_dir) || die "Build dir $(get_gcc_build_dir) not found"

	# and now to do the actual configuration
	addwrite /dev/zero
	echo "Running this:"
	echo "configure ${confgcc}"
	echo "${S}"/configure "$@"
	"${S}"/configure ${confgcc} || die "failed to run configure"
}

get_gcc_configure_options()
{
	local CTARGET=$1; shift
	local confgcc=$(get_gcc_common_options)
	case ${CTARGET} in
		arm*)	#264534
			local arm_arch="${CTARGET%%-*}"
			# Only do this if arm_arch is armv*
			if [[ ${arm_arch} == armv* ]] ; then
				# Convert armv7{a,r,m} to armv7-{a,r,m}
				[[ ${arm_arch} == armv7? ]] && arm_arch=${arm_arch/7/7-}
				# Remove endian ('l' / 'eb')
				[[ ${arm_arch} == *l ]] && arm_arch=${arm_arch%l}
				[[ ${arm_arch} == *eb ]] && arm_arch=${arm_arch%eb}
				confgcc="${confgcc} --with-arch=${arm_arch}"
				confgcc="${confgcc} --disable-esp"
			fi
			;;
		i?86*)
			# Hardened is enabled for x86, but disabled for ARM.
			confgcc="${confgcc} --enable-esp"
			confgcc="${confgcc} --with-arch=atom"
			confgcc="${confgcc} --with-tune=atom"
			# Remove this once crash2 supports larger symbols.
			# http://code.google.com/p/chromium-os/issues/detail?id=23321
			confgcc="${confgcc} --enable-frame-pointer"
			;;
	esac
	echo ${confgcc}
}

get_gcc_common_options()
{
	local confgcc
	confgcc="${confgcc} --disable-libmudflap"
	confgcc="${confgcc} --disable-libssp"
	confgcc+=" $(use_enable openmp libgomp)"
	confgcc="${confgcc} --enable-__cxa_atexit"
	confgcc="${confgcc} --enable-checking=release"
	confgcc="${confgcc} --disable-libquadmath"
	echo ${confgcc}
}

get_gcc_dir()
{
	local GCCDIR
	if use mounted_gcc ; then
		GCCDIR=${GCC_SOURCE_PATH:=/usr/local/toolchain_root/gcc}
	elif use upstream_gcc ; then
		GCCDIR=${MY_P}
	else
		GCCDIR=${GITDIR}/gcc/${MY_P}
	fi
	echo "${GCCDIR}"
}

get_gcc_build_dir()
{
	echo "$(get_gcc_dir)-build-${CTARGET}"
}

get_gcc_base_ver()
{
	cat "$(get_gcc_dir)/gcc/BASE-VER"
}

get_stdcxx_incdir()
{
	echo "${LIBDIR}/gcc/${CTARGET}/$(get_gcc_base_ver)/include/g++-v4"
}

# Grab a variable from the build system (taken from linux-info.eclass)
get_make_var() {
	local var=$1 makefile=${2:-$(get_gcc_build_dir)/Makefile}
	echo -e "e:\\n\\t@echo \$(${var})\\ninclude ${makefile}" | \
		r=${makefile%/*} emake --no-print-directory -s -f - 2>/dev/null
}
XGCC() { get_make_var GCC_FOR_TARGET ; }

gcc_move_pretty_printers() {
	local gdb_autoload_dir=/usr/share/gdb/auto-load
	for i in $(cd "${D}" && find . -name \*-gdb.py); do
		insinto "${gdb_autoload_dir}/$(dirname ${i})"
		doins "${D}${i}"
		rm "${D}${i}"
	done
}

gcc_movelibs() {
	LIBPATH=${LIBDIR}	# cros to Gentoo glue

	local multiarg removedirs=""
	for multiarg in $($(XGCC) -print-multi-lib) ; do
		multiarg=${multiarg#*;}
		multiarg=${multiarg//@/ -}

		local OS_MULTIDIR=$($(XGCC) ${multiarg} --print-multi-os-directory)
		local MULTIDIR=$($(XGCC) ${multiarg} --print-multi-directory)
		[[ ${OS_MULTIDIR} == ${MULTIDIR} ]] && continue
		local FROMDIR="${LIBPATH}/gcc/${CTARGET}/$($(XGCC) -dumpversion)"
		if [[ -d ${D}/${FROMDIR}/${OS_MULTIDIR} ]] ; then
			# if we aren't building shared libraries, then the os dir
			# won't exist.  this comes up when bootstrapping.
			mv "${D}/${FROMDIR}/${OS_MULTIDIR}"/* "${D}/${FROMDIR}/${MULTIDIR}/" || die
		fi
	done

	# We remove directories separately to avoid this case:
	#	mv SRC/lib/../lib/*.o DEST
	#	rmdir SRC/lib/../lib/
	#	mv SRC/lib/../lib32/*.o DEST  # Bork
	find "${D}" -type d -depth -delete 2>/dev/null
}
