# Copyright 1999-2007 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: $

EAPI="4"

inherit autotools eutils flag-o-matic

DESCRIPTION="Upstart is an event-based replacement for the init daemon"
HOMEPAGE="http://upstart.ubuntu.com/"
SRC_URI="http://upstart.ubuntu.com/download/${PV}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="debug direncryption examples nls selinux udev_bridge"

RDEPEND=">=sys-apps/dbus-1.2.16
	>=sys-libs/libnih-1.0.2
	selinux? (
		sys-libs/libselinux
		sys-libs/libsepol
	)
	direncryption? (
		sys-apps/keyutils
	)"
DEPEND=">=dev-libs/expat-2.0.0
	nls? ( sys-devel/gettext )
	direncryption? (
		sys-fs/e2fsprogs
	)
	${RDEPEND}"

src_prepare() {
	# 1.3+ has scary user and chroot session support that we just
	# don't want to adopt yet, so we're sticking with 1.2 for the
	# near future. Backport some bug fixes from lp:upstart

	# -r 1326 - fix bug when /dev/console cannot be opened
	# chromium-os:18739
	epatch "${FILESDIR}"/upstart-1.2-silent-console.patch
	# -r 1280,1308,1309,1320,1329 - fix shell fd leak (and fix the fix)
	epatch "${FILESDIR}"/upstart-1.2-fix-shell-redirect.patch
	# -r 1281,1325,1327,1328 - update to use /proc/oom_score
	epatch "${FILESDIR}"/upstart-1.2-oom-score.patch
	# -r 1282 - add "kill signal" stanza (may be useful for us)
	epatch "${FILESDIR}"/upstart-1.2-kill-signal.patch

	epatch "${FILESDIR}"/upstart-1.2-default-oom_score_adj.patch

	# chromium-os:33165, make EXIT_STATUS!=* possible
	epatch "${FILESDIR}"/upstart-1.2-negate-match.patch

	# issue EXIT_* in events when exit status is zero for daemons
	epatch "${FILESDIR}"/upstart-1.2-fail-on-zero-exit.patch

	epatch "${FILESDIR}"/${P}-override.patch

	# Patch to use kmsg at higher verbosity for logging; this is
	# our own patch because we can't just add --verbose to the
	# kernel command-line when we need to.
	use debug && epatch "${FILESDIR}"/upstart-1.2-log-verbosity.patch

	# load SELinux policy
	epatch "${FILESDIR}"/upstart-1.2-selinux.patch

	# -r 1307 - "Merge of lp:~jamesodhunt/upstart/upstream-udev+socket-bridges."
	epatch "${FILESDIR}"/upstart-1.2-socket-event.patch

	# Inspired by -r 1542; just rewrote it based on 1.2 though
	epatch "${FILESDIR}"/upstart-1.2-socket-event-SOCKET_PATH.patch

	# Clean up domain sockets on startup and shutdown.
	epatch "${FILESDIR}"/upstart-1.2-socket-cleanup.patch

	# Add base fscrypto ring: to work with File systems that support
	# directory encryption.
	use direncryption && epatch "${FILESDIR}"/upstart-1.2-dircrypto.patch

	# The selinux patch changes makefile.am and configure.ac
	# so we need to run autoreconf, and if we don't the system
	# will do it for us, and incorrectly too.
	eautoreconf
}

src_configure() {
	# Rearrange PATH so that /usr/local does not override /usr.
	append-cppflags '-DPATH="\"/usr/bin:/usr/sbin:/sbin:/bin:/usr/local/sbin:/usr/local/bin\""'

	append-lfs-flags

	econf \
		--prefix=/ \
		--exec-prefix= \
		--includedir='${prefix}/usr/include' \
		--disable-rpath \
		$(use_enable selinux) \
		$(use_enable nls)
}

src_compile() {
	emake NIH_DBUS_TOOL=$(which nih-dbus-tool)
}

src_install() {
	default
	use examples || rm "${D}"/etc/init/*.conf
	insinto /etc/init
	# Always use our own upstart-socket-bridge.conf.
	doins "${FILESDIR}"/init/upstart-socket-bridge.conf
	# Restore udev bridge if requested.
	use udev_bridge && doins extra/conf/upstart-udev-bridge.conf
}
