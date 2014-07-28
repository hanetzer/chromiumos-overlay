# Copyright 1999-2011 Gentoo Foundation
# Distributed under the terms of the GNU General Public License v2
# $Header: /var/cvsroot/gentoo-x86/sys-fs/udev/udev-171-r2.ebuild,v 1.2 2011/09/18 06:42:42 zmedico Exp $

EAPI=4

KV_min=2.6.32
KV_reliable=2.6.32
PATCHSET=${P}-gentoo-patchset-v1
scriptversion=v4
scriptname=udev-gentoo-scripts-${scriptversion}

if [[ ${PV} == "9999" ]]
then
	EGIT_REPO_URI="git://git.kernel.org/pub/scm/linux/hotplug/udev.git"
	EGIT_BRANCH="master"
	vcs="git-2 autotools"
fi

inherit ${vcs} eutils flag-o-matic multilib toolchain-funcs linux-info systemd libtool

if [[ ${PV} != "9999" ]]
then
	KEYWORDS="*"
	# please update testsys-tarball whenever udev-xxx/test/sys/ is changed
	SRC_URI="mirror://kernel/linux/utils/kernel/hotplug/${P}.tar.bz2
			 test? ( mirror://gentoo/${PN}-171-testsys.tar.bz2 )"
	if [[ -n "${PATCHSET}" ]]
	then
		SRC_URI="${SRC_URI} mirror://gentoo/${PATCHSET}.tar.bz2"
	fi
fi
SRC_URI="${SRC_URI} mirror://gentoo/${scriptname}.tar.bz2"

DESCRIPTION="Linux dynamic and persistent device naming support (aka userspace devfs)"
HOMEPAGE="http://www.kernel.org/pub/linux/utils/kernel/hotplug/udev.html"

LICENSE="GPL-2"
SLOT="1"
IUSE="build selinux test debug +rule_generator hwdb acl gudev introspection
	keymap floppy edd action_modeswitch extras"

COMMON_DEPEND="selinux? ( sys-libs/libselinux )
	extras? ( sys-apps/acl
		dev-libs/glib:2
		dev-libs/gobject-introspection
		virtual/libusb:0 )
	acl? ( sys-apps/acl dev-libs/glib:2 )
	gudev? ( dev-libs/glib:2 )
	introspection? ( dev-libs/gobject-introspection )
	action_modeswitch? ( virtual/libusb:0 )
	>=sys-apps/util-linux-2.16
	>=sys-libs/glibc-2.10"

DEPEND="${COMMON_DEPEND}
	keymap? ( dev-util/gperf )
	extras? ( dev-util/gperf )
	dev-util/pkgconfig
	virtual/os-headers
	!<sys-kernel/linux-headers-2.6.34
	test? ( app-text/tree )"

RDEPEND="${COMMON_DEPEND}
	extras?
	(
		>=sys-apps/usbutils-0.82
		sys-apps/pciutils
	)
	!sys-apps/coldplug
	!<sys-fs/lvm2-2.02.45
	!sys-fs/device-mapper
	!<sys-fs/udev-171-r7:0
	>=sys-apps/baselayout-1.12.5"

PDEPEND=" hwdb?  ( >=sys-apps/hwids-20130915.1 )"

if [[ ${PV} == "9999" ]]
then
	# for documentation processing with xsltproc
	DEPEND="${DEPEND}
		app-text/docbook-xsl-stylesheets
		app-text/docbook-xml-dtd
		dev-util/gtk-doc"
fi

# required kernel options
CONFIG_CHECK="~INOTIFY_USER ~SIGNALFD ~!SYSFS_DEPRECATED ~!SYSFS_DEPRECATED_V2
	~!IDE ~BLK_DEV_BSG"

# Return values:
# 2 - reliable
# 1 - unreliable
# 0 - too old
udev_check_KV() {
	local ok=0
	if kernel_is -ge ${KV_reliable//./ }
	then
		ok=2
	elif kernel_is -ge ${KV_min//./ }
	then
		ok=1
	fi
	return $ok
}

pkg_setup() {
	linux-info_pkg_setup

	# always print kernel version requirements
	ewarn
	ewarn "${P} does not support Linux kernel before version ${KV_min}!"
	if [[ ${KV_min} != ${KV_reliable} ]]
	then
		ewarn "For a reliable udev, use at least kernel ${KV_reliable}"
	fi

	udev_check_KV
	case "$?" in
		2)	einfo "Your kernel version (${KV_FULL}) is new enough to run ${P} reliably." ;;
		1)	ewarn "Your kernel version (${KV_FULL}) is new enough to run ${P},"
			ewarn "but it may be unreliable in some cases."
			;;
		0)	eerror "Your kernel version (${KV_FULL}) is too old to run ${P}"
			;;
	esac

	KV_FULL_SRC=${KV_FULL}
	get_running_version
	udev_check_KV
	if [[ "$?" = "0" ]]
	then
		eerror
		eerror "udev cannot be restarted after emerging,"
		eerror "as your running kernel version (${KV_FULL}) is too old."
		eerror "You really need to use a newer kernel after a reboot!"
		NO_RESTART=1
	fi
}

src_unpack() {
	unpack ${A}
	if [[ ${PV} == "9999" ]]
	then
		git-2_src_unpack
	fi
}

src_prepare() {
	if use test && [[ -d "${WORKDIR}"/test/sys ]]
	then
		mv "${WORKDIR}"/test/sys "${S}"/test/
	fi

	# patches go here...
	epatch "${FILESDIR}"/udev-170-fusectl-opts.patch
	epatch "${FILESDIR}"/udev-171-tty12rw.patch
	# prevent probing of zram (causes swapon to fail)
	# chromium:265568
	epatch "${FILESDIR}"/udev-171-no-probe-zram.patch

	# backport some patches
	if [[ -n "${PATCHSET}" ]]
	then
		EPATCH_SOURCE="${WORKDIR}/${PATCHSET}" EPATCH_SUFFIX="patch" \
			  EPATCH_FORCE="yes" epatch
	fi

	# change rules back to group uucp instead of dialout for now
	sed -e 's/GROUP="dialout"/GROUP="uucp"/' \
		-i rules/{rules.d,arch}/*.rules \
	|| die "failed to change group dialout to uucp"

	if [[ ${PV} == 9999 ]]
	then
		gtkdocize --copy || die "gtkdocize failed"
		eautoreconf
	else
		elibtoolize
	fi
}

src_configure() {
	if ! use extras
	then
	econf \
		--prefix="${EPREFIX}/usr" \
		--sysconfdir="${EPREFIX}/etc" \
		--sbindir="${EPREFIX}/sbin" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--with-rootlibdir="${EPREFIX}/$(get_libdir)" \
		--libexecdir="${EPREFIX}/lib/udev" \
		--enable-logging \
		--enable-static \
		$(use_with selinux) \
		$(use_enable debug) \
		$(use_enable rule_generator) \
		$(use_enable hwdb) \
		--with-pci-ids-path="${EPREFIX}/usr/share/misc/pci.ids" \
		--with-usb-ids-path="${EPREFIX}/usr/share/misc/usb.ids" \
		$(use_enable acl udev_acl) \
		$(use_enable gudev) \
		$(use_enable introspection) \
		$(use_enable keymap) \
		$(use_enable floppy) \
		$(use_enable edd) \
		$(use_enable action_modeswitch) \
		$(systemd_with_unitdir)
	else
	econf \
		--prefix="${EPREFIX}/usr" \
		--sysconfdir="${EPREFIX}/etc" \
		--sbindir="${EPREFIX}/sbin" \
		--libdir="${EPREFIX}/usr/$(get_libdir)" \
		--with-rootlibdir="${EPREFIX}/$(get_libdir)" \
		--libexecdir="${EPREFIX}/lib/udev" \
		--enable-logging \
		--enable-static \
		$(use_with selinux) \
		$(use_enable debug) \
		--enable-rule_generator \
		--enable-hwdb \
		--with-pci-ids-path="${EPREFIX}/usr/share/misc/pci.ids" \
		--with-usb-ids-path="${EPREFIX}/usr/share/misc/usb.ids" \
		--enable-udev_acl \
		--enable-gudev \
		--enable-introspection \
		--enable-keymap \
		--enable-floppy \
		--enable-edd \
		--enable-action_modeswitch \
		$(systemd_with_unitdir)
	fi
}

src_compile() {
	filter-flags -fprefetch-loop-arrays

	emake
}

src_install() {
	emake DESTDIR="${T}" install
	insinto "/$(get_libdir)"
	doins "${T}/$(get_libdir)/libudev.so.0.11.5"
	doins "${T}/$(get_libdir)/libudev.so.0"
}
