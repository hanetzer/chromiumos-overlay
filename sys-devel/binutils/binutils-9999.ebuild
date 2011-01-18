inherit eutils libtool flag-o-matic gnuconfig multilib versionator ${extra_eclass}

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

BVER=${PV}

# Version names
COST_VERSION="v1"
BINUTILS_CL="experimental-9999"
BINUTILS_VERSION="binutils-2.20.1-mobile"
BINUTILS_PKG_VERSION="${BINUTILS_VERSION}_cos_gg_${COST_VERSION}_${BINUTILS_CL}"

GOLD_CL="experimental-9999"
GOLD_VERSION="binutils-20100303"
GOLD_PKG_VERSION="${GOLD_VERSION}_cos_gg_${COST_VERSION}_${GOLD_CL}"

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
IUSE="nls multitarget multislot test vanilla"
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

S_BINUTILS="${WORKDIR}/${BINUTILS_VERSION}"
S_GOLD="${WORKDIR}/${GOLD_VERSION}"

if [[ ${PV} == "9999" ]] ; then
	RESTRICT="fetch strip"
else
	SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${BINUTILS_PKG_VERSION}.tar.gz \
http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${GOLD_PKG_VERSION}.tar.gz"
fi

MY_BUILDDIR_BINUTILS="${WORKDIR}/build"
MYBUILDDIR_GOLD="${WORKDIR}/build-gold"

LIBPATH=/usr/$(get_libdir)/binutils/${CTARGET}/${BVER}
INCPATH=${LIBPATH}/include
DATAPATH=/usr/share/binutils-data/${CTARGET}/${BVER}
if is_cross ; then
	BINPATH=/usr/${CHOST}/${CTARGET}/binutils-bin/${BVER}
else
	BINPATH=/usr/${CTARGET}/binutils-bin/${BVER}
fi

src_unpack() {
	if [[ ${PV} == "9999" ]] ; then
		P4_BINUTILS="/usr/local/toolchain_root/binutils/${BINUTILS_VERSION}"
		P4_GOLD="/usr/local/toolchain_root/binutils/${GOLD_VERSION}"  
		if [[ ! -d ${P4_BINUTILS} ]] || [[ ! -d ${P4_GOLD} ]] ; then
			die "binutils dirs not mounted at: ${P4_BINUTILS} and ${P4_GOLD}"
		fi
		ln -s ${P4_BINUTILS} ${S_BINUTILS}
		ln -s ${P4_GOLD} ${S_GOLD}
	else
		unpack ${A}
	fi
	mkdir -p "${MY_BUILDDIR_BINUTILS}"
	mkdir -p "${MYBUILDDIR_GOLD}"
}


src_compile() {
	# keep things sane
	strip-flags

	local x
	echo
	for x in CATEGORY CBUILD CHOST CTARGET CFLAGS LDFLAGS ; do
		einfo "$(printf '%10s' ${x}:) ${!x}"
	done
	echo

	cd "${MY_BUILDDIR_BINUTILS}"
	local myconf=""
	is_cross && myconf="${myconf} --with-sysroot=/usr/${CTARGET}"
	myconf="--prefix=/usr \
		--host=${CHOST} \
		--target=${CTARGET} \
		--datadir=${DATAPATH} \
		--infodir=${DATAPATH}/info \
		--mandir=${DATAPATH}/man \
		--bindir=${BINPATH} \
		--libdir=${LIBPATH} \
		--libexecdir=${LIBPATH} \
		--includedir=${INCPATH} \
		--enable-64-bit-bfd \
		--enable-shared \
		--disable-werror \
		--enable-secureplt \
		--without-included-gettext \
		--build=${CBUILD} \
		--with-bugurl=http://code.google.com/p/chromium-os/issues/entry \
		${myconf} ${EXTRA_ECONF}"

	binutils_conf="${myconf} --disable-checking --with-pkgversion=${BINUTILS_PKG_VERSION}"

	echo ./configure ${myconf}
	"${S_BINUTILS}"/configure ${myconf} || die "configure failed"

	emake all || die "emake failed"

	# only build info pages if we user wants them, and if
	# we have makeinfo (may not exist when we bootstrap)
	if type -p makeinfo > /dev/null ; then
		emake info || die "make info failed"
	fi
	# we nuke the manpages when we're left with junk
	# (like when we bootstrap, no perl -> no manpages)
	find . -name '*.1' -a -size 0 | xargs rm -f

	# Build gold
	cd "${MYBUILDDIR_GOLD}"
	gold_conf="${myconf} --with-pkgversion=${GOLD_PKG_VERSION} --enable-gold"
	echo ./configure ${gold_conf}
	"${S_GOLD}"/configure ${gold_conf} || die "configure gold failed"

	emake all-gold || die "emake gold failed"
}

src_test() {
	cd "${MY_BUILDDIR_BINUTILS}"
	make check || die "check failed :("
	cd "${MY_BUILDDIR_GOLD}"
	make check || die "check failed :("
}

src_install() {
	local x d

	cd "${MY_BUILDDIR_BINUTILS}"
	emake DESTDIR="${D}" tooldir="${LIBPATH}" install || die
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
	doins "${S_BINUTILS}/include/libiberty.h"
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
	cd "${MYBUILDDIR_BINUTILS}"
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
	TARGET="${CTARGET}"
	VER="${BVER}"
	LIBPATH="${LIBPATH}"
	FAKE_TARGETS="${FAKE_TARGETS}"
	EOF
	newins env.d ${CTARGET}-${BVER}

	# Handle documentation
	if ! is_cross ; then
		cd "${S_BINUTILS}"
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

	# Call GNU ld ld.bfd and gold ld.gold
	mv "${D}/${BINPATH}/ld" "${D}/${BINPATH}/ld.bfd"

	# Install gold
	cd "${MYBUILDDIR_GOLD}"
	emake DESTDIR="${D}" tooldir="${LIBPATH}" install-gold || die

	mv "${D}/${BINPATH}/${CTARGET}-ld" "${D}/${BINPATH}/ld.gold"

	# Set default to be ld.bfd in regular installation
	ln -sf -T ld.bfd "${D}/${BINPATH}/ld"

	# Make a fake installation for gold with gold as the default linker
	# so we can turn gold on/off with binutils-config
	LASTDIR=${LIBPATH##/*/}
	ln -sf -T "${LASTDIR}" "${D}/${LIBPATH}-gold"
	LASTDIR=${DATAPATH##/*/}
	ln -sf -T "${LASTDIR}" "${D}/${DATAPATH}-gold"

	mkdir "${D}/${BINPATH}-gold"
	cd "${D}"/${BINPATH}
	LASTDIR=${BINPATH##/*/}
	for x in * ; do
		ln -sf -T "../${LASTDIR}/${x}" "${D}/${BINPATH}-gold/${x}"
	done
	ln -sf -T ld.gold "${D}/${BINPATH}-gold/ld"

	# Install gold binutils-config configuration file
	cd ${MYBUILDDIR_GOLD}
	insinto /etc/env.d/binutils
	cat <<-EOF > env.d
	TARGET="${CTARGET}"
	VER="${BVER}-gold"
	LIBPATH="${LIBPATH}-gold"
	FAKE_TARGETS="${FAKE_TARGETS}"
	EOF
	newins env.d ${CTARGET}-${BVER}-gold

	# Move the locale directory to where it is supposed to be
	mv "${D}/usr/share/locale" "${D}/${DATAPATH}/"
}

pkg_postinst() {
	binutils-config ${CTARGET}-${BVER}
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
