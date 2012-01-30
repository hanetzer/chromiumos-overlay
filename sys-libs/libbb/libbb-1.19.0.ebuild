# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"
inherit toolchain-funcs flag-o-matic

MY_P=busybox-${PV/_/-}
DESCRIPTION="library for busybox - libbb.a"
HOMEPAGE="http://www.busybox.net/"
SRC_URI="http://www.busybox.net/downloads/${MY_P}.tar.bz2"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE=""

S=${WORKDIR}/${MY_P}

busybox_config_option() {
	case $1 in
		y) sed -i -e "s:.*\<CONFIG_$2\>.*set:CONFIG_$2=y:g" .config;;
		n) sed -i -e "s:CONFIG_$2=y:# CONFIG_$2 is not set:g" .config;;
		*) use $1 \
				&& busybox_config_option y $2 \
				|| busybox_config_option n $2
				return 0
				;;
	esac
	einfo $(grep "CONFIG_$2[= ]" .config || echo Could not find CONFIG_$2 ...)
}

src_configure() {
	emake allnoconfig > /dev/null
	busybox_config_option y DD
	busybox_config_option y RM
	busybox_config_option y DD_IBS_OBS
}

src_compile() {
	tc-export CC AR STRIP RANLIB
	emake CC="$(tc-getCC)" AR="$(tc-getAR)" STRIP="$(tc-getSTRIP)" \
		busybox || die
	# Add the list of utils we need. Unused symbols will be stripped
	cp libbb/lib.a libbb/libbb.a || die
	$AR rc libbb/libbb.a coreutils/{dd,rm}.o || die
}

src_install() {
	dolib.a libbb/libbb.a
	insinto /usr/include
	doins include/libbb.h
}
