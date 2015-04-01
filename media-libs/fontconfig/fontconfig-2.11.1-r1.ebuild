# Copyright 1999-2014 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/media-libs/fontconfig/fontconfig-2.11.1-r1.ebuild,v 1.2 2014/06/10 00:44:36 vapier Exp $

EAPI=5
AUTOTOOLS_AUTORECONF=yes

inherit eutils readme.gentoo autotools-multilib

DESCRIPTION="A library for configuring and customizing font access"
HOMEPAGE="http://fontconfig.org/"
SRC_URI="http://fontconfig.org/release/${P}.tar.bz2"

LICENSE="MIT"
SLOT="1.0"
KEYWORDS="*"
IUSE="cros_host doc static-libs -highdpi +subpixel_rendering"

# Purposefully dropped the xml USE flag and libxml2 support.  Expat is the
# default and used by every distro.  See bug #283191.

RDEPEND=">=dev-libs/expat-1.95.3[${MULTILIB_USEDEP}]
	>=media-libs/freetype-2.2.1[${MULTILIB_USEDEP}]
	abi_x86_32? ( !app-emulation/emul-linux-x86-xlibs[-abi_x86_32(-)] )"
DEPEND="${RDEPEND}
	virtual/pkgconfig
	doc? (
		=app-text/docbook-sgml-dtd-3.1*
		app-text/docbook-sgml-utils[jadetex]
	)"
PDEPEND="!x86-winnt? ( app-admin/eselect-fontconfig )
	virtual/ttf-fonts"

PATCHES=(
	"${FILESDIR}"/${PN}-2.10.2-docbook.patch	# 310157
	"${FILESDIR}"/${P}-fonts-config.patch
	"${FILESDIR}"/${P}-conf-d.patch
	"${FILESDIR}"/${P}-fclang.patch
	"${FILESDIR}"/${P}-symbolcmap.patch
)

MULTILIB_CHOST_TOOLS=(
	/usr/bin/fc-cache
)

# Checks that a passed-in fontconfig default symlink (e.g. "10-autohint.conf")
# is present and dies if it isn't.
check_fontconfig_default() {
	local path="${D}"/etc/fonts/conf.d/"$1"
	if [[ ! -L ${path} ]]; then
		die "Didn't find $1 among default fontconfig settings (at ${path})."
	fi
}

pkg_setup() {
	DOC_CONTENTS="Please make fontconfig configuration changes using
	\`eselect fontconfig\`. Any changes made to /etc/fonts/fonts.conf will be
	overwritten. If you need to reset your configuration to upstream defaults,
	delete the directory ${EROOT}etc/fonts/conf.d/ and re-emerge fontconfig."
}

src_configure() {
	local addfonts
	# harvest some font locations, such that users can benefit from the
	# host OS's installed fonts
	case ${CHOST} in
		*-darwin*)
			addfonts=",/Library/Fonts,/System/Library/Fonts"
		;;
		*-solaris*)
			[[ -d /usr/X/lib/X11/fonts/TrueType ]] && \
				addfonts=",/usr/X/lib/X11/fonts/TrueType"
			[[ -d /usr/X/lib/X11/fonts/Type1 ]] && \
				addfonts="${addfonts},/usr/X/lib/X11/fonts/Type1"
		;;
		*-linux-gnu)
			use prefix && [[ -d /usr/share/fonts ]] && \
				addfonts=",/usr/share/fonts"
		;;
	esac

	local myeconfargs=(
		$(use_enable doc docbook)
		# always enable docs to install manpages
		--enable-docs
		# Font cache should be in /usr/share/cache instead of /var/cache
		# because the latter is not in the read-only partition.
		--localstatedir="${EPREFIX}"/usr/share
		--with-default-fonts="${EPREFIX}"/usr/share/fonts
		--with-add-fonts="${EPREFIX}/usr/local/share/fonts${addfonts}" \
		--with-templatedir="${EPREFIX}"/etc/fonts/conf.avail
	)

	autotools-multilib_src_configure
}

multilib_src_install() {
	default

	# XXX: avoid calling this multiple times, bug #459210
	if multilib_is_native_abi; then
		insinto /etc/fonts
		doins fonts.conf
	fi
}

multilib_src_install_all() {
	einstalldocs
	prune_libtool_files --all

	doins "${FILESDIR}"/local.conf
	# Test that fontconfig's defaults for basic rendering settings
	# match what we want to use.
	check_fontconfig_default 10-autohint.conf
	check_fontconfig_default 10-hinting.conf
	check_fontconfig_default 10-hinting-slight.conf
	check_fontconfig_default 10-sub-pixel-rgb.conf

	# Enable antialiasing by default.
	dosym ../conf.avail/10-antialias.conf /etc/fonts/conf.d/
	check_fontconfig_default 10-antialias.conf

	# There's a lot of variability across different displays with subpixel
	# rendering. Until we have a better solution, turn it off and use grayscale
	# instead on boards that don't have internal displays. Additionally, disable it
        # when installing to the host sysroot so the images in the initramfs package
        # won't use subpixel rendering (http://crosbug.com/27872).
	if ! use subpixel_rendering || use cros_host; then
		rm "${D}"/etc/fonts/conf.d/10-sub-pixel-rgb.conf
		dosym ../conf.avail/10-no-sub-pixel.conf /etc/fonts/conf.d/
		check_fontconfig_default 10-no-sub-pixel.conf
	fi

	# Changes should be made to /etc/fonts/local.conf, and as we had
	# too much problems with broken fonts.conf we force update it ...
	echo 'CONFIG_PROTECT_MASK="/etc/fonts/fonts.conf"' > "${T}"/37fontconfig
	doenvd "${T}"/37fontconfig

	# As of fontconfig 2.7, everything sticks their noses in here.
	# Replace /var/cache with /usr/share/cache for CrOS.
	dodir /etc/sandbox.d
	echo 'SANDBOX_PREDICT="/usr/share/cache/fontconfig"' > "${ED}"/etc/sandbox.d/37fontconfig

	readme.gentoo_create_doc
}

pkg_postinst() {
	einfo "Cleaning broken symlinks in "${EROOT}"etc/fonts/conf.d/"
	find -L "${EROOT}"etc/fonts/conf.d/ -type l -delete

	readme.gentoo_print_elog

	if [[ ${ROOT} = / ]]; then
		multilib_pkg_postinst() {
			ebegin "Creating global font cache for ${ABI}"
			"${EPREFIX}"/usr/bin/${CHOST}-fc-cache -srf
			eend $?
		}

		multilib_parallel_foreach_abi multilib_pkg_postinst
	fi
}
