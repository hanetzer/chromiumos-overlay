# Copyright (c) 2015 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

CROS_WORKON_REPO="https://android.googlesource.com"
CROS_WORKON_PROJECT="toolchain/binutils"
CROS_WORKON_LOCALNAME="../aosp/toolchain/binutils"
CROS_WORKON_COMMIT="082ed0f10cf59b53381cefda2f90247e2a81015b"
CROS_WORKON_TREE="0ec9cd10d3b529c84a90baf3589842f6ad519426"
CROS_WORKON_BLACKLIST="1"

NEXT_BINUTILS=cros/binutils-2_25-google

# By default, PREV_BINUTILS points to the parent of current tip of cros/master.
# If that is a bad commit, override this to point to the last known good commit.
PREV_BINUTILS="cros/master^"

inherit eutils libtool flag-o-matic gnuconfig multilib versionator cros-constants cros-workon

KEYWORDS="*"

BVER=${PV}

export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

is_cross() { [[ ${CHOST} != ${CTARGET} ]] ; }

DESCRIPTION="Tools necessary to build programs"
HOMEPAGE="http://sources.redhat.com/binutils/"
LICENSE="|| ( GPL-3 LGPL-3 )"
IUSE="hardened mounted_binutils multislot multitarget nls test vanilla
	next_binutils prev_binutils"
REQUIRED_USE="next_binutils? ( !prev_binutils )"

if use multislot ; then
	SLOT="${CTARGET}-${BVER}"
elif is_cross ; then
	SLOT="${CTARGET}"
else
	SLOT="0"
fi

RDEPEND=">=sys-devel/binutils-config-1.9"
DEPEND="${RDEPEND}
	test? ( dev-util/dejagnu )
	nls? ( sys-devel/gettext )
	sys-devel/flex"

RESTRICT="fetch"

GITDIR=${WORKDIR}/gitdir

LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${BVER}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${BVER}
MY_BUILDDIR=${WORKDIR}/build
if is_cross ; then
	BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}
else
	BINPATH=/usr/${CTARGET}/binutils-bin/${BVER}
fi

# It is not convenient that cros_workon.eclass does not accept a branch name in
# CROS_WORKON_COMMIT/TREE, because sometimes the git repository is cloned via
# '--shared', which hides all remote refs. So we manually calculate the hashes
# here.
githash_for_branch() {
	local pathbase
	local branch=$1
	pathbase="${CHROOT_SOURCE_ROOT}/src/third_party/binutils"
	# Workaround uprev deleting these settings. http://crbug.com/375546
	eval CROS_WORKON_COMMIT"='$(git --no-pager --git-dir="${pathbase}/.git" log -1 --pretty="format:%H" "${branch}")'"
	eval CROS_WORKON_TREE"='$(git --no-pager --git-dir="${pathbase}/.git" log -1 --pretty="format:%T" "${branch}")'"
}

cros_pre_src_prepare_use_gcc() {
	cros_use_gcc
}

src_unpack() {
	if use mounted_binutils ; then
		local dir="/usr/local/toolchain_root/binutils"
		if [[ ! -d ${dir} ]] ; then
			die "binutils dirs not mounted at: ${dir}"
		fi
		export VCSID=$(get_rev "${dir}")
		ln -s "${dir}" "${S}"
	else
		if use next_binutils ; then
			githash_for_branch ${NEXT_BINUTILS}
			einfo "Using next binutils: \"${NEXT_BINUTILS}\""
			einfo "  GITHASH= \"${CROS_WORKON_COMMIT}\""
			einfo "  TREEHASH= \"${CROS_WORKON_TREE}\""
		fi
		if use prev_binutils ; then
			githash_for_branch ${PREV_BINUTILS}
			einfo "Using prev binutils: \"${PREV_BINUTILS}\""
			einfo "  GITHASH= \"${CROS_WORKON_COMMIT}\""
			einfo "  TREEHASH= \"${CROS_WORKON_TREE}\""
		fi
		cros-workon_src_unpack
		# cros_workon_src_unpack set vcsid (the version hash) to
		# cros/master, this is not correct when we override
		# GITHASH. Correct VCSID here.
		if use next_binutils || use prev_binutils ; then
			export VCSID=${CROS_WORKON_COMMIT}
		fi
		# The repo at https://android.git.corp.google.com/toolchain/binutils
		# has sources inside a subdirectory named binutils-${PV}. The repo at
		# https://chromium.googlesource.com/chromiumos/third_party/binutils
		# has sources at top level. This ebuild needs to handle both cases.
		local subdir
		if [[ ${PV} == 9999 ]]; then
			subdir="binutils-2.25"
		else
			subdir="${PN}-$(get_version_component_range 1-2)"
		fi
		if [[ -d "${S}/${subdir}" ]] ; then
			S="${S}/${subdir}"
		fi
	fi

	mkdir -p "${MY_BUILDDIR}"
}

toolchain-binutils_bugurl() {
	printf "http://code.google.com/p/chromium-os/issues/entry"
}
toolchain-binutils_pkgversion() {
	printf "binutils-${VCSID}_cos_gg"
}

toolchain_mips_use_sysv_gnuhash() {
	if [[ ${CTARGET} == mips* ]] ; then
		# For mips targets, GNU hash cannot work due to ABI constraints.
		sed -i \
			-e 's:--hash-style=gnu:--hash-style=sysv:' \
			"${D}/${BINPATH}/$1" || die
	fi
}

src_configure() {
	# make sure we filter $LINGUAS so that only ones that
	# actually work make it through #42033
	strip-linguas -u */po

	# keep things sane
	strip-flags

	local x
	echo
	for x in CATEGORY CBUILD CHOST CTARGET CFLAGS LDFLAGS ; do
		einfo "$(printf '%10s' ${x}:) ${!x}"
	done
	echo

	cd "${MY_BUILDDIR}"
	local myconf=( --enable-plugins )

	# enable gold if available (installed as ld.gold)
	if [[ ${CTARGET} == mips* ]] ; then
		myconf+=( --disable-gold )
	else
		myconf+=( --enable-gold )
	fi

	use nls \
		&& myconf+=( --without-included-gettext ) \
		|| myconf+=( --disable-nls )

	myconf+=( --enable-64-bit-bfd )

	[[ -n ${CBUILD} ]] && myconf+=( --build=${CBUILD} )
	is_cross && myconf+=(
		--with-sysroot="${EPREFIX}"/usr/${CTARGET}
		--enable-poison-system-directories
	)

	# glibc-2.3.6 lacks support for this ... so rather than force glibc-2.5+
	# on everyone in alpha (for now), we'll just enable it when possible
	has_version ">=${CATEGORY}/glibc-2.5" && myconf+=( --enable-secureplt )
	has_version ">=sys-libs/glibc-2.5" && myconf+=( --enable-secureplt )

	myconf+=(
		--prefix="${EPREFIX}"/usr
		--host=${CHOST}
		--target=${CTARGET}
		--datadir="${EPREFIX}"${DATAPATH}
		--infodir="${EPREFIX}"${DATAPATH}/info
		--mandir="${EPREFIX}"${DATAPATH}/man
		--bindir="${EPREFIX}"${BINPATH}
		--libdir="${EPREFIX}"${LIBPATH}
		--libexecdir="${EPREFIX}"${LIBPATH}
		--includedir="${EPREFIX}"${INCPATH}
		--enable-threads
		--enable-shared
		# Newer versions (>=2.24) make this an explicit option. #497268
		--enable-install-libiberty
		--disable-werror
		--with-bugurl="$(toolchain-binutils_bugurl)"
		--with-pkgversion="$(toolchain-binutils_pkgversion)"
		${EXTRA_ECONF}
		# Disable modules that are in a combined binutils/gdb tree. #490566
		--disable-{gdb,libdecnumber,readline,sim}
		# Strip out broken static link flags.
		# https://gcc.gnu.org/PR56750
		--without-stage1-ldflags
	)

	echo ./configure "${myconf[@]}"
	"${S}"/configure "${myconf[@]}" || die
}

src_compile() {
	cd "${MY_BUILDDIR}"
	emake all

	# only build info pages if we user wants them, and if
	# we have makeinfo (may not exist when we bootstrap)
	if type -p makeinfo > /dev/null ; then
		emake info
	fi
	# we nuke the manpages when we're left with junk
	# (like when we bootstrap, no perl -> no manpages)
	find . -name '*.1' -a -size 0 -delete
}

src_test() {
	cd "${MY_BUILDDIR}"
	emake -k check
}

src_install() {
	local x d

	cd "${MY_BUILDDIR}"
	emake DESTDIR="${D}" tooldir="${LIBPATH}" install
	rm -rf "${D}"/${LIBPATH}/bin

	# Newer versions of binutils get fancy with ${LIBPATH} #171905
	cd "${D}"/${LIBPATH}
	for d in ../* ; do
		[[ ${d} == ../${BVER} ]] && continue
		mv ${d}/* . || die
		rmdir ${d} || die
	done

	# Now we collect everything intp the proper SLOT-ed dirs
	# When something is built to cross-compile, it installs into
	# /usr/$CHOST/ by default ... we have to 'fix' that :)
	if is_cross ; then
		cd "${D}"/${BINPATH}
		for x in * ; do
			mv ${x} ${x/${CTARGET}-}
		done

		if [[ -d ${D}/usr/${CHOST}/${CTARGET} ]] ; then
			mv "${D}"/usr/${CHOST}/${CTARGET}/include "${D}"/${INCPATH}
			mv "${D}"/usr/${CHOST}/${CTARGET}/lib/* "${D}"/${LIBPATH}/
			rm -r "${D}"/usr/${CHOST}/{include,lib}
		fi
	fi
	insinto ${INCPATH}
	doins "${S}/include/libiberty.h"
	if [[ -d ${D}/${LIBPATH}/lib ]] ; then
		mv "${D}"/${LIBPATH}/lib/* "${D}"/${LIBPATH}/
		rm -r "${D}"/${LIBPATH}/lib
	fi

	# Now, some binutils are tricky and actually provide
	# for multiple TARGETS.  Really, we're talking just
	# 32bit/64bit support (like mips/ppc/sparc).  Here
	# we want to tell binutils-config that it's cool if
	# it generates multiple sets of binutil symlinks.
	# e.g. sparc gets {sparc,sparc64}-unknown-linux-gnu
	local targ=${CTARGET/-*} src="" dst=""
	local FAKE_TARGETS=${CTARGET}
	case ${targ} in
		mips*)    src="mips"    dst="mips64";;
		powerpc*) src="powerpc" dst="powerpc64";;
		s390*)    src="s390"    dst="s390x";;
		sparc*)   src="sparc"   dst="sparc64";;
	esac
	case ${targ} in
		mips64*|powerpc64*|s390x*|sparc64*) targ=${src} src=${dst} dst=${targ};;
	esac
	[[ -n ${src}${dst} ]] && FAKE_TARGETS="${FAKE_TARGETS} ${CTARGET/${src}/${dst}}"

	# Generate an env.d entry for this binutils
	insinto /etc/env.d/binutils
	cat <<-EOF > "${T}"/env.d
	TARGET="${CTARGET}"
	VER="${BVER}"
	LIBPATH="${LIBPATH}"
	FAKE_TARGETS="${FAKE_TARGETS}"
	EOF
	newins "${T}"/env.d ${CTARGET}-${BVER}

	# Handle documentation
	if ! is_cross ; then
		cd "${S}"
		dodoc README
		docinto bfd
		dodoc bfd/ChangeLog* bfd/README bfd/PORTING bfd/TODO
		docinto binutils
		dodoc binutils/ChangeLog binutils/NEWS binutils/README
		docinto gas
		dodoc gas/ChangeLog* gas/CONTRIBUTORS gas/NEWS gas/README*
		docinto gprof
		dodoc gprof/ChangeLog* gprof/TEST gprof/TODO gprof/bbconv.pl
		docinto ld
		dodoc ld/ChangeLog* ld/README ld/NEWS ld/TODO
		docinto libiberty
		dodoc libiberty/ChangeLog* libiberty/README
		docinto opcodes
		dodoc opcodes/ChangeLog*
	fi
	# Remove shared info pages
	rm -f "${D}"/${DATAPATH}/info/{dir,configure.info,standards.info}
	# Trim all empty dirs
	find "${D}" -type d | xargs rmdir >& /dev/null

	if use hardened ; then
		LDWRAPPER=ldwrapper.hardened
	else
		LDWRAPPER=ldwrapper
	fi

	mv "${D}/${BINPATH}/ld.bfd" "${D}/${BINPATH}/ld.bfd.real" || die
	exeinto "${BINPATH}"
	newexe "${FILESDIR}/${LDWRAPPER}" "ld.bfd" || die
	toolchain_mips_use_sysv_gnuhash "ld.bfd"

	# Set default to be ld.bfd in regular installation
	dosym ld.bfd "${BINPATH}/ld"

	# Require gold for targets we know support gold, but auto-detect others.
	local gold=false
	case ${CTARGET} in
	arm*|i?86-*|powerpc*|sparc*|x86_64-*)
		gold=true
		;;
	*)
		[[ -e ${D}/${BINPATH}/ld.gold ]] && gold=true
		;;
	esac

	if ${gold} ; then
		mv "${D}/${BINPATH}/ld.gold" "${D}/${BINPATH}/ld.gold.real" || die
		exeinto "${BINPATH}"
		newexe "${FILESDIR}/${LDWRAPPER}" "ld.gold" || die
		toolchain_mips_use_sysv_gnuhash "ld.gold"

		# Make a fake installation for gold with gold as the default linker
		# so we can turn gold on/off with binutils-config
		LASTDIR=${LIBPATH##/*/}
		dosym "${LASTDIR}" "${LIBPATH}-gold"
		LASTDIR=${DATAPATH##/*/}
		dosym "${LASTDIR}" "${DATAPATH}-gold"

		mkdir "${D}/${BINPATH}-gold"
		cd "${D}"/${BINPATH}
		LASTDIR=${BINPATH##/*/}
		for x in * ; do
			dosym "../${LASTDIR}/${x}" "${BINPATH}-gold/${x}"
		done
		dosym ld.gold "${BINPATH}-gold/ld"

		# Install gold binutils-config configuration file
		insinto /etc/env.d/binutils
		cat <<-EOF > "${T}"/env.d
		TARGET="${CTARGET}"
		VER="${BVER}-gold"
		LIBPATH="${LIBPATH}-gold"
		FAKE_TARGETS="${FAKE_TARGETS}"
		EOF
		newins "${T}"/env.d ${CTARGET}-${BVER}-gold
	fi

	# Move the locale directory to where it is supposed to be
	mv "${D}/usr/share/locale" "${D}/${DATAPATH}/"
}

pkg_postinst() {
	# Manual binutils installation (usually via "cros_workon --host
	# xxx/binutls && sudo emerge xxx/binutils"), unlike setup_board and
	# build_packages which invoke cros_setup_toolchains to properly config
	# bfd/gold selection, does not config gold/bfd. When a developer
	# cherry-picks a binutils CL, rebuilds it via 'emerge', he/she sometimes
	# ends up using gold (or bfd) while he/she actually assumes bfd (or
	# gold). This behavior is extremely confusing. Fix this by always
	# PROPERLY configuring gold/bfd selection in postinst.
	local config_gold=false
	if is_cross; then
		case ${CTARGET} in
			armv7a-*|i?86-*|x86_64-*) config_gold=true;;
			*) ;;
		esac
	fi
	if ${config_gold} ; then
		binutils-config ${CTARGET}-${BVER}-gold
	else
		binutils-config ${CTARGET}-${BVER}
	fi
}

pkg_postrm() {
	local current_profile=$(binutils-config -c ${CTARGET})

	# If no other versions exist, then uninstall for this
	# target ... otherwise, switch to the newest version
	# Note: only do this if this version is unmerged.  We
	#       rerun binutils-config if this is a remerge, as
	#       we want the mtimes on the symlinks updated (if
	#       it is the same as the current selected profile)
	if [[ ! -e ${BINPATH}/ld ]] && [[ ${current_profile} == ${CTARGET}-${BVER} ]] ; then
		local choice=$(binutils-config -l | grep ${CTARGET} | awk '{print $2}')
		choice=${choice//$'\n'/ }
		choice=${choice/* }
		if [[ -z ${choice} ]] ; then
			env -i binutils-config -u ${CTARGET}
		else
			binutils-config ${choice}
		fi
	elif [[ $(CHOST=${CTARGET} binutils-config -c) == ${CTARGET}-${BVER} ]] ; then
		binutils-config ${CTARGET}-${BVER}
	fi
}
