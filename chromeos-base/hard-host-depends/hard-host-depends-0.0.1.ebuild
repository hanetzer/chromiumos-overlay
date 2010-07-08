# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="List of packages that are needed on the buildhost (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE=""

# Needed to run setup crossdev, run build scripts, and make a bootable image.
RDEPEND="${RDEPEND}
	app-admin/sudo
	dev-embedded/u-boot-tools
	sys-boot/bootstub
	sys-boot/grub
	sys-boot/syslinux
	sys-devel/crossdev
	sys-devel/crossdev-wrappers
	sys-fs/dosfstools
	"

# Host dependencies for building cross-compiled packages.
RDEPEND="${RDEPEND}
	app-admin/eselect-opengl
	app-arch/cabextract
	app-arch/rpm2targz
	app-arch/sharutils
	app-arch/unzip
	>=app-emulation/qemu-user-0.12.2
	app-i18n/ibus
	app-text/texi2html
	dev-lang/python
	dev-db/m17n-contrib
	dev-db/m17n-db
	dev-lang/swig
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	dev-libs/glib
	dev-libs/eggdbus
	dev-libs/libgcrypt
	dev-libs/libxslt
	dev-libs/m17n-lib
	dev-libs/nss[utils]
	dev-libs/protobuf
	dev-python/dbus-python
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyopenssl
	dev-python/webpy
	=dev-util/boost-build-1.42.0
	dev-util/cmake
	dev-util/git[cvs,subversion,webdav,curl]
	dev-util/gob
	dev-util/gperf
	dev-util/gtk-doc
	dev-util/quilt
	dev-util/subversion[-dso]
	>=dev-util/gtk-doc-am-1.10
	>=dev-util/intltool-0.30
	dev-util/scons
	gnome-base/gconf
	gnome-base/gnome-common
	=gnome-base/orbit-2.14.17
	>=media-libs/freetype-2.2.1
	media-libs/mesa
	sys-apps/module-init-tools
	x11-apps/mkfontdir
	x11-apps/xcursorgen
	x11-apps/xkbcomp
	>=x11-misc/util-macros-1.2
	x11-libs/gtk+
	sys-apps/nih-dbus-tool
	sys-fs/sshfs-fuse
	"

# Host dependencies that create usernames/groups we need to pull over to target.
RDEPEND="${RDEPEND}
	sys-apps/dbus
	"

# Host dependencies that are needed by mod_image_for_test.
RDEPEND="${RDEPEND}
	sys-process/lsof
	"

# Useful utilities for developers.
RDEPEND="${RDEPEND}
	app-portage/gentoolkit
	app-portage/portage-utils
	app-editors/qemacs
	app-editors/vim
	sys-apps/ack
	"

# Host dependencies that are needed for unit tests
RDEPEND="${RDEPEND}
	x11-misc/xkeyboard-config
	"

# Host dependencies that are needed to build Icedtea
RDEPEND="${RDEPEND}
	app-arch/zip
	dev-java/ant-core
	dev-java/xalan
	dev-java/xerces
	sys-apps/lsb-release
	x11-libs/libXtst
	"

# Host dependencies that are needed to sign images
RDEPEND="${RDEPEND}
	chromeos-base/vboot_reference
	chromeos-base/verity
	"

# Host dependency needed to dump symbols from binaries.
# See http://crosbug.com/3437.
RDEPEND="${RDEPEND}
	chromeos-base/dump-syms
	"

DEPEND=""
