# Copyright 1999-2012 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# Based on gentoo's modemmanager ebuild

EAPI="4"
CROS_WORKON_COMMIT="377cfd9396a061b139f9e8cf7737ada46e28c411"
CROS_WORKON_TREE="2bf14ab9bc09fa498643b661855d5e58ff038b63"
CROS_WORKON_PROJECT="chromiumos/third_party/modemmanager-next"

inherit eutils autotools cros-workon flag-o-matic

# ModemManager likes itself with capital letters
MY_P=${P/modemmanager/ModemManager}

DESCRIPTION="Modem and mobile broadband management libraries"
HOMEPAGE="http://mail.gnome.org/archives/networkmanager-list/2008-July/msg00274.html"
#SRC_URI not defined because we get our source locally

LICENSE="LGPL-2.1"
SLOT="0"
KEYWORDS="alpha amd64 arm hppa ia64 m68k mips ppc ppc64 s390 sh sparc x86"
IUSE="-asan -clang doc gobi mbim qmi"
REQUIRED_USE="asan? ( clang )"

RDEPEND=">=dev-libs/glib-2.32
	>=sys-apps/dbus-1.2
	dev-libs/dbus-glib
	net-dialup/ppp
	mbim? ( net-libs/libmbim )
	qmi? ( net-libs/libqmi )
	!net-misc/modemmanager"

DEPEND="${RDEPEND}
	>=sys-fs/udev-147[gudev]
	dev-util/pkgconfig
	dev-util/intltool
	>=dev-util/gtk-doc-1.13
	!net-misc/modemmanager-next-interfaces
	!net-misc/modemmanager"

DOCS="AUTHORS ChangeLog NEWS README"

src_prepare() {
	gtkdocize
	eautopoint
	eautoreconf
	intltoolize --force
}

src_configure() {
	clang-setup-env
	append-flags -Xclang-only=-Wno-unneeded-internal-declaration
	cros-workon_src_configure \
		--with-html-dir="\${datadir}/doc/${PF}/html" \
		$(use_enable {,gtk-}doc) \
		$(use_with mbim) \
		$(use_with qmi)
}

src_test() {
	# TODO(benchan): Run unit tests for arm via qemu-arm.
	if [[ "${ARCH}" != "arm" ]]; then
		emake GCONV_PATH="${SYSROOT}"/usr/$(get_libdir)/gconv check
	fi
}

src_install() {
	default
	# Remove useless .la files
	find "${D}" -name '*.la' -delete

	# Only install plugins for supported modems to conserve space on the
	# root filesystem.
	find "${D}" -name 'libmm-plugin-*.so' ! \( \
		-name 'libmm-plugin-altair-lte.so' -o \
		-name 'libmm-plugin-generic.so' -o \
		-name 'libmm-plugin-gobi.so' -o \
		-name 'libmm-plugin-huawei.so' -o \
		-name 'libmm-plugin-longcheer.so' -o \
		-name 'libmm-plugin-novatel-lte.so' -o \
		-name 'libmm-plugin-samsung.so' -o \
		-name 'libmm-plugin-zte.so' \
		\) -delete

	insinto /etc/init
	doins "${FILESDIR}/modemmanager.conf"

	# ModemManager by default installs udev rules to /lib/udev/rules.d.
	insinto /lib/udev/rules.d
	# Install Chrome OS specific rules.
	doins "${FILESDIR}/77-mm-huawei-configuration.rules"

	# When built with USE=gobi, override 80-mm-candidate.rules provided by
	# ModemManager with files/80-mm-candidate.rules to work around a race
	# condition between cromo and ModemManager. See
	# files/80-mm_candidate.rules for details.
	#
	# TODO(benchan): Revert it when cromo is deprecated (crbug.com/316744).
	use gobi && doins "${FILESDIR}/80-mm-candidate.rules"
}
