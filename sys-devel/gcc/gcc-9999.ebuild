# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-devel/gcc/gcc-4.4.3-r3.ebuild,v 1.1 2010/06/19 01:53:09 zorry Exp $

EAPI=1
CROS_WORKON_LOCALNAME=gcc
CROS_WORKON_PROJECT=chromiumos/third_party/gcc

inherit eutils cros-workon binutils-funcs

# (Crosstool-based) ChromeOS toolchain related variables.
COST_PKG_VERSION="${P}_cos_gg"

GCC_FILESDIR="${PORTDIR}/sys-devel/gcc/files"

DESCRIPTION="The GNU Compiler Collection.  Includes C/C++, java compilers, pie+ssp extensions, Haj Ten Brugge runtime bounds checking. This Compiler is based off of Crosstoolv14."

LICENSE="GPL-3 LGPL-3 || ( GPL-3 libgcc libstdc++ gcc-runtime-library-exception-3.1 ) FDL-1.2"
KEYWORDS="~amd64 ~arm ~x86"

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

IUSE="gcj git_gcc graphite gtk hardened hardfp mounted_gcc multilib multislot
      nls cxx openmp tests +thumb upstream_gcc vanilla"

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

src_unpack() {
	if use mounted_gcc ; then
		if [[ ! -d "$(get_gcc_dir)" ]] ; then
			die "gcc dir not mounted/present at: $(get_gcc_dir)"
		fi
	elif use upstream_gcc ; then
		GCC_MIRROR=ftp://mirrors.kernel.org/gnu/gcc
		GCC_TARBALL=${GCC_MIRROR}/${P}/${P}.tar.bz2
		wget $GCC_TARBALL
		tar xf ${GCC_TARBALL##*/}
	elif use git_gcc ; then
		git clone "${CROS_WORKON_REPO}/${CROS_WORKON_PROJECT}.git" "${S}"
		if [[ -z ${GCC_GITHASH} ]] ; then
			einfo "Checking out: ${GCC_GITHASH}"
			pushd "$(get_gcc_dir)" >/dev/null
			git checkout ${GCC_GITHASH} || \
				die "Couldn't checkout ${GCC_GITHASH}"
			popd >/dev/null
		fi
		COST_PKG_VERSION+="_$(cd ${S}; git describe --always)"
	else
		cros-workon_src_unpack
	fi

	use vanilla && return 0
}

src_compile()
{
	src_configure
	cd $(get_gcc_build_dir) || "Build dir $(get_gcc_build_dir) not found"
	GCC_CFLAGS="$(portageq envvar CFLAGS)"
	TARGET_FLAGS=""

	if use hardened
	then
		TARGET_FLAGS="${TARGET_FLAGS} -fstack-protector-strong -D_FORTIFY_SOURCE=2"
	fi

	# Do not link libgcc with gold. That is known to fail on internal linker
	# errors. See crosbug.com/16719
	local LD_NON_GOLD="$(get_binutils_path_ld ${CTARGET})/ld"

	emake CFLAGS="${GCC_CFLAGS}" \
		LDFLAGS="-Wl,-O1" \
		STAGE1_CFLAGS="-O2 -pipe" \
		BOOT_CFLAGS="-O2" \
		CFLAGS_FOR_TARGET="$(get_make_var CFLAGS_FOR_TARGET) ${TARGET_FLAGS}" \
		CXXFLAGS_FOR_TARGET="$(get_make_var CXXFLAGS_FOR_TARGET) ${TARGET_FLAGS}" \
		LD_FOR_TARGET="${LD_NON_GOLD}" \
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

	local LDPATH=$(get_lib_dir)
	for SUBDIR in 32 64 ; do
		if [[ -d ${D}/${LDPATH}/${SUBDIR} ]]
		then
			LDPATH="${LDPATH}:${LDPATH}/${SUBDIR}"
		fi
	done

	cat <<-EOF > env.d
LDPATH="${LDPATH}"
MANPATH="$(get_data_dir)/man"
INFOPATH="$(get_data_dir)/info"
STDCXX_INCDIR="$(get_stdcxx_incdir)"
CTARGET=${CTARGET}
GCC_PATH="$(get_bin_dir)"
GCC_VER="$(get_gcc_base_ver)"
EOF
	newins env.d $(get_gcc_config_file)
	cd -

	if is_crosscompile ; then
		if use hardened
		then
			SYSROOT_WRAPPER_FILE=sysroot_wrapper.hardened
		else
			SYSROOT_WRAPPER_FILE=sysroot_wrapper
		fi

		cd ${D}$(get_bin_dir)
		exeinto "$(get_bin_dir)"
		doexe "${FILESDIR}/${SYSROOT_WRAPPER_FILE}" || die
		for x in c++ cpp g++ gcc; do
			if [[ -f "${CTARGET}-${x}" ]]; then
				mv "${CTARGET}-${x}" "${CTARGET}-${x}.real"
				dosym "${SYSROOT_WRAPPER_FILE}" "$(get_bin_dir)/${CTARGET}-${x}" || die
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

pkg_preinst()
{
	# We handle ccache ourselves in the sysroot wrapper.
	rm -f /usr/lib/ccache/bin/*-*

	# When we install a new toolchain, the existing cached objects become
	# stale.  Clear out the old ones just to avoid them sitting around
	# sucking up space indefinitely.
	local ccache_dir="/var/cache/distfiles/ccache"
	rm -rf "${ccache_dir}"
	mkdir -p -m 2775 "${ccache_dir}"
	# Disable file count/size limits since the objects should mostly stay
	# fresh until the next compiler upgrade.  We might want to revisit
	# this at some point, but better to have a few extra stale entries
	# than to have valid cached objects constantly cycled out.
	CCACHE_UMASK=002 CCACHE_DIR=${ccache_dir} ccache -F0 -M0
	# Make sure the dirs have perms for emerge builders.
	chgrp -R portage "${ccache_dir}"
}

pkg_postinst()
{
	gcc-config $(get_gcc_config_file)
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
}

src_configure()
{
	if use mounted_gcc && [[ -f $(get_gcc_build_dir)/Makefile ]] ; then
		return
	fi

	# Set configuration based on path variables
	local confgcc="$(use_enable multilib)
		--prefix=${PREFIX} \
		--bindir=$(get_bin_dir) \
		--datadir=$(get_data_dir) \
		--mandir=$(get_data_dir)/man \
		--infodir=$(get_data_dir)/info \
		--includedir=$(get_lib_dir)/include \
		--with-gxx-include-dir=$(get_stdcxx_incdir)"
	confgcc="${confgcc} --host=${CHOST}"
	confgcc="${confgcc} --target=${CTARGET}"
	confgcc="${confgcc} --build=${CBUILD}"

	# Language options for stage1/stage2.
	if ! use cxx
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
	echo "$(get_gcc_dir)"/configure "$@"
	"$(get_gcc_dir)"/configure ${confgcc} || die "failed to run configure"
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
		GCCDIR=${P}
	else
		GCCDIR=${S}
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
	echo "$(get_lib_dir)/include/g++-v4"
}

get_lib_dir()
{
	echo "${PREFIX}/lib/gcc/${CTARGET}/$(get_gcc_base_ver)"
}

get_bin_dir()
{
	if is_crosscompile ; then
		echo ${PREFIX}/${CHOST}/${CTARGET}/gcc-bin/$(get_gcc_base_ver)
	else
		echo ${PREFIX}/${CTARGET}/gcc-bin/$(get_gcc_base_ver)
	fi
}

get_data_dir()
{
	echo "${PREFIX}/share/gcc-data/${CTARGET}/$(get_gcc_base_ver)"
}

get_gcc_config_file()
{
	echo ${CTARGET}-${PV}
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

# make sure the libtool archives have libdir set to where they actually
# -are-, and not where they -used- to be.  also, any dependencies we have
# on our own .la files need to be updated.
fix_libtool_libdir_paths() {
	pushd "${D}" >/dev/null

	pushd "./${1}" >/dev/null
	local dir="${PWD#${D%/}}"
	local allarchives=$(echo *.la)
	allarchives="\(${allarchives// /\\|}\)"
	popd >/dev/null

	sed -i \
		-e "/^libdir=/s:=.*:='${dir}':" \
		./${dir}/*.la
	sed -i \
		-e "/^dependency_libs=/s:/[^ ]*/${allarchives}:${LIBPATH}/\1:g" \
		$(find ./${PREFIX}/lib* -maxdepth 3 -name '*.la') \
		./${dir}/*.la

	popd >/dev/null
}

gcc_movelibs() {
	LIBPATH=$(get_lib_dir)	# cros to Gentoo glue

	local multiarg removedirs=""
	for multiarg in $($(XGCC) -print-multi-lib) ; do
		multiarg=${multiarg#*;}
		multiarg=${multiarg//@/ -}

		local OS_MULTIDIR=$($(XGCC) ${multiarg} --print-multi-os-directory)
		local MULTIDIR=$($(XGCC) ${multiarg} --print-multi-directory)
		local TODIR=${D}${LIBPATH}/${MULTIDIR}
		local FROMDIR=

		[[ -d ${TODIR} ]] || mkdir -p ${TODIR}

		for FROMDIR in \
			${LIBPATH}/${OS_MULTIDIR} \
			${LIBPATH}/../${MULTIDIR} \
			${PREFIX}/lib/${OS_MULTIDIR} \
			${PREFIX}/${CTARGET}/lib/${OS_MULTIDIR}
		do
			removedirs="${removedirs} ${FROMDIR}"
			FROMDIR=${D}${FROMDIR}
			if [[ ${FROMDIR} != "${TODIR}" && -d ${FROMDIR} ]] ; then
				local files=$(find "${FROMDIR}" -maxdepth 1 ! -type d 2>/dev/null)
				if [[ -n ${files} ]] ; then
					mv ${files} "${TODIR}"
				fi
			fi
		done
		fix_libtool_libdir_paths "${LIBPATH}/${MULTIDIR}"
	done

	# We remove directories separately to avoid this case:
	#	mv SRC/lib/../lib/*.o DEST
	#	rmdir SRC/lib/../lib/
	#	mv SRC/lib/../lib32/*.o DEST  # Bork
	for FROMDIR in ${removedirs} ; do
		rmdir "${D}"${FROMDIR} >& /dev/null
	done
	find "${D}" -type d | xargs rmdir >& /dev/null
}
