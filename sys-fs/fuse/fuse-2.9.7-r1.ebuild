# Copyright 1999-2017 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2

EAPI=5
inherit eutils libtool linux-info udev toolchain-funcs fcaps

DESCRIPTION="An interface for filesystems implemented in userspace"
HOMEPAGE="https://github.com/libfuse/libfuse"
SRC_URI="https://github.com/libfuse/libfuse/releases/download/${P}/${P}.tar.gz"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
IUSE="examples kernel_linux kernel_FreeBSD static-libs"

PDEPEND="kernel_FreeBSD? ( sys-fs/fuse4bsd )"
DEPEND="virtual/pkgconfig"

pkg_setup() {
	if use kernel_linux ; then
		if kernel_is lt 2 6 9 ; then
			die "Your kernel is too old."
		fi
		CONFIG_CHECK="~FUSE_FS"
		FUSE_FS_WARNING="You need to have FUSE module built to use user-mode utils"
		linux-info_pkg_setup
	fi
}

src_prepare() {
	# sandbox violation with mtab writability wrt #438250
	# don't sed configure.in without eautoreconf because of maintainer mode
	sed -i 's:umount --fake:true --fake:' configure || die
	elibtoolize

	epatch "${FILESDIR}"/fuse-2.8.5-fix-lazy-binding.patch
	epatch "${FILESDIR}"/fuse-2.8.5-gold.patch
	# This patch changes fusermount to avoid calling getpwuid(3)
	# if '-o user=<username>' is provided in the command line.
	# This prevents glibc's implementation of getpwuid from invoking
	# socket/connect syscalls, which allows Chromium OS daemons to
	# put more restrictive seccomp filters on fusermount.
	epatch "${FILESDIR}"/fuse-2.8.6-user-option.patch
	epatch "${FILESDIR}"/fuse-2.8.6-remove-setuid.patch
	epatch "${FILESDIR}"/fuse-2.9.3-kernel-types.patch
}

src_configure() {
	econf \
		INIT_D_PATH="${EPREFIX}/etc/init.d" \
		MOUNT_FUSE_PATH="${EPREFIX}/sbin" \
		UDEV_RULES_PATH="${EPREFIX}/$(get_udevdir)/rules.d" \
		$(use_enable static-libs static) \
		--disable-example
}

src_install() {
	local DOCS=( AUTHORS ChangeLog README.md README.NFS NEWS doc/how-fuse-works doc/kernel.txt )
	default

	if use examples ; then
		docinto examples
		dodoc example/*
	fi

	if use kernel_linux ; then
		newinitd "${FILESDIR}"/fuse.init fuse
	elif use kernel_FreeBSD ; then
		insinto /usr/include/fuse
		doins include/fuse_kernel.h
		newinitd "${FILESDIR}"/fuse-fbsd.init fuse
	else
		die "We don't know what init code install for your kernel, please file a bug."
	fi

	prune_libtool_files
	rm -rf "${D}"/dev

	# user_allow_other is enabled to allow Chromium OS to run FUSE-based
	# file system daemons as a non-root and non-chronos user, while
	# allowing chronos to access the mount file systems.
	dodir /etc
	cat > "${ED}"/etc/fuse.conf <<-EOF
		# Set the maximum number of FUSE mounts allowed to non-root users.
		# The default is 1000.
		#
		#mount_max = 1000

		# Allow non-root users to specify the 'allow_other' or 'allow_root'
		# mount options.
		#
		user_allow_other
	EOF
}

pkg_postinst() {
	fcaps cap_sys_admin usr/bin/fusermount
}
