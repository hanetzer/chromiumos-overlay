# Copyright 1999-2012 Gentoo Foundation
# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

inherit flag-o-matic toolchain-funcs

export CBUILD=${CBUILD:-${CHOST}}
export CTARGET=${CTARGET:-${CHOST}}
if [[ ${CTARGET} == ${CHOST} ]] ; then
	if [[ ${CATEGORY/cross-} != ${CATEGORY} ]] ; then
		export CTARGET=${CATEGORY/cross-}
	fi
fi

DESCRIPTION="Newlib is a C library intended for use on embedded systems"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/nds32-newlib-1703004.tar.gz"

LICENSE="NEWLIB LIBGLOSS GPL-2"
[[ ${CTARGET} != ${CHOST} ]] \
	&& SLOT="${CTARGET}" \
	|| SLOT="0"
KEYWORDS="amd64 x86"
IUSE="nls threads unicode crosscompile_opts_headers-only"
RESTRICT="strip"

NEWLIBBUILD="${WORKDIR}/build"

pkg_setup() {
	# Reject newlib-on-glibc type installs
	if [[ ${CTARGET} == ${CHOST} ]] ; then
		case ${CHOST} in
			*-newlib|*-elf) ;;
			*) die "Use sys-devel/crossdev to build a newlib toolchain" ;;
		esac
	fi
}

src_configure() {
	# we should fix this ...
	unset LDFLAGS
	CHOST=${CTARGET} strip-unsupported-flags

	local myconf=""
	[[ ${CTARGET} == "spu" ]] \
		&& myconf="${myconf} --disable-newlib-multithread" \
		|| myconf="${myconf} $(use_enable threads newlib-multithread)"

	mkdir -p "${NEWLIBBUILD}"
	cd "${NEWLIBBUILD}"

	ECONF_SOURCE=${S} \
	econf \
		$(use_enable unicode newlib-mb) \
		$(use_enable nls) \
		${myconf}
}

src_compile() {
	emake -C "${NEWLIBBUILD}"
}

src_install() {
	cd "${NEWLIBBUILD}"
	emake -j1 DESTDIR="${D}" install
#	env -uRESTRICT CHOST=${CTARGET} prepallstrip
	# minor hack to keep things clean
	rm -fR "${D}"/usr/share/info
	rm -fR "${D}"/usr/info
}
