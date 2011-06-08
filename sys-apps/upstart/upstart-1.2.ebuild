# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

inherit autotools eutils

DESCRIPTION="Upstart is an event-based replacement for the init daemon"
HOMEPAGE="http://upstart.ubuntu.com/"
SRC_URI="http://upstart.at/download/1.x/${P}.tar.gz"
LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86 arm"
IUSE="examples nls upstartdebug"

DEPEND=">=dev-libs/expat-2.0.0
	>=sys-apps/dbus-1.2.16
	nls? ( sys-devel/gettext )
	>=sys-libs/libnih-1.0.2"

RDEPEND=">=sys-apps/dbus-1.2.16
	>=sys-libs/libnih-1.0.2"


src_unpack() {
	unpack ${A}
	cd "${S}"

	# 1.2 is the current release, backport some bug fixes from
	# lp:upstart that will be in the 1.3 release (but don't just
	# grab everything, because there are large changes in there
	# we don't want just yet)

	# -r 1280,1308,1309 - fix shell fd leak (and fix the fix)
	epatch "${FILESDIR}"/upstart-1.2-fix-shell-redirect.patch
	# -r 1281 - update to use /proc/oom_score
	epatch "${FILESDIR}"/upstart-1.2-oom-score.patch
	# -r 1282 - add "kill signal" stanza (may be useful for us)
	epatch "${FILESDIR}"/upstart-1.2-kill-signal.patch

	# Patch to use kmsg at higher verbosity for logging; this is
	# our own patch because we can't just add --verbose to the
	# kernel command-line when we need to.
	if use upstartdebug; then
		epatch "${FILESDIR}"/upstart-1.2-log-verbosity.patch
	fi
}

src_compile() {
	econf --prefix=/ --includedir='${prefix}/usr/include' \
		$(use_enable nls) || die "econf failed"

	emake NIH_DBUS_TOOL=$(which nih-dbus-tool) \
		|| die "emake failed"
}

src_install() {
	emake DESTDIR="${D}" install || die "make install failed"

	if ! use examples ; then
		elog "Removing example .conf files."
		rm "${D}"/etc/init/*.conf
	fi
}
