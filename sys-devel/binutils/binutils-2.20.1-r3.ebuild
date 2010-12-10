# Copyright 1999-2010 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header:

KEYWORDS="~alpha ~amd64 ~arm ~hppa ~ia64 ~mips ~ppc ~ppc64 ~s390 ~sh ~sparc ~x86 ~sparc-fbsd ~x86-fbsd"

inherit toolchain-binutils

# No patching
PATCHVER=""
ELF2FLT_VER=""
UCLIBC_PATCHVER=""

# Override default binutils behaviour
BINUTILS_TYPE="crosstool"
BVER=${PV}

# Version names
COST_VERSION="v1"
BINUTILS_CL="44027a"
BINUTILS_VERSION="binutils-2.20.1-mobile"
BINUTILS_PKG_VERSION="${BINUTILS_VERSION}_cos_gg_${COST_VERSION}_${BINUTILS_CL}"

GOLD_CL="44729"
GOLD_VERSION="binutils-20100303"
GOLD_PKG_VERSION="${GOLD_VERSION}_cos_gg_${COST_VERSION}_${GOLD_CL}"

EXTRA_ECONF="--with-bugurl=http://code.google.com/p/chromium-os/issues/entry \
${EXTRA_ECONF}"
# Set gold configure version
GOLD_EXTRA_ECONF="--with-pkgversion=${GOLD_PKG_VERSION} ${EXTRA_ECONF}"
# Set binutils configure version and disable assertions
# (currently a false alarm is triggered, to be fixed)
EXTRA_ECONF="--disable-checking --with-pkgversion=${BINUTILS_PKG_VERSION} \
${EXTRA_ECONF}"

# Due to gold development moving faster than regular binutils, there is a
# separate binutils tarball which just has an up-to-date gold
DISTFILES="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles"
SRC_URI="${DISTFILES}/${BINUTILS_PKG_VERSION}.tar.gz \
${DISTFILES}/${GOLD_PKG_VERSION}.tar.gz"

S_BINUTILS="${WORKDIR}/${BINUTILS_VERSION}"
S_GOLD="${WORKDIR}/${GOLD_VERSION}"
MYBUILDDIR_GOLD="${MY_BUILDDIR}-gold"

IUSE="nls multitarget"

src_unpack() {
	# Unpack the source
	tc-binutils_unpack

	# Move binutils to its expected directory
	mv ${S_BINUTILS} ${S}

	# Make a directory for building gold as well
	mkdir -p "${MYBUILDDIR_GOLD}"
}

src_compile() {
	toolchain-binutils_src_compile

	# Build gold using the same config options as binutils
	cd "${MYBUILDDIR_GOLD}"

	local myconf=""
	use nls \
		&& myconf="${myconf} --without-included-gettext" \
		|| myconf="${myconf} --disable-nls"
	use multitarget && myconf="${myconf} --enable-targets=all"
	[[ -n ${CBUILD} ]] && myconf="${myconf} --build=${CBUILD}"
	is_cross && myconf="${myconf} --with-sysroot=/usr/${CTARGET}"
	# glibc-2.3.6 lacks support for this ... so rather than force glibc-2.5+
	# on everyone in alpha (for now), we'll just enable it when possible
	has_version ">=${CATEGORY}/glibc-2.5" && myconf="${myconf} --enable-secureplt"
	has_version ">=sys-libs/glibc-2.5" && myconf="${myconf} --enable-secureplt"
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
		--enable-gold \
		${myconf} ${GOLD_EXTRA_ECONF}"
	echo ./configure ${myconf}
	"${S_GOLD}"/configure ${myconf} || die "configure failed"

	emake all-gold || die "emake failed"
}

src_install() {
	toolchain-binutils_src_install

	# Call GNU ld ld.bfd and gold ld.gold
	mv "${D}/${BINPATH}/ld" "${D}/${BINPATH}/ld.bfd"

	# Install gold
	cd "${MYBUILDDIR_GOLD}"
	emake DESTDIR="${D}" tooldir="${LIBPATH}" install-gold || die

	mv "${D}/${BINPATH}/${CTARGET}-ld" "${D}/${BINPATH}/ld.gold"

	# Set default to be ld.bfd in regular installation
	ln -sf "${D}/${BINPATH}/ld.bfd" "${D}/${BINPATH}/ld"

	# Make a fake installation for gold with gold as the default linker
	# so we can turn gold on/off with binutils-config
	ln -sf "${D}/${LIBPATH}" "${D}/${LIBPATH}-gold"
	ln -sf "${D}/${DATAPATH}" "${D}/${DATAPATH}-gold"

	mkdir "${D}/${BINPATH}-gold"
	cd "${D}"/${BINPATH}
	for x in * ; do
		ln -sf "${D}/${BINPATH}/${x}" "${D}/${BINPATH}-gold/${x}"
	done
	ln -sf "${D}/${BINPATH}-gold/ld.gold" "${D}/${BINPATH}-gold/ld"

	# Install gold binutils-config configuration file
	cd ${S_GOLD}
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
