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
	sys-devel/crossdev
	sys-devel/crossdev-wrappers
	sys-boot/syslinux
        sys-block/gpt
	"

# Host dependencies for building cross-compiled packages.
RDEPEND="${RDEPEND}
	app-admin/eselect-opengl
	app-arch/cabextract
        app-arch/dpkg
	app-arch/rpm2targz
	app-arch/unzip
	dev-lang/python
	dev-lang/swig
	dev-libs/glib
        dev-libs/eggdbus
	dev-libs/libxslt
	dev-libs/dbus-glib[tools]
	dev-libs/nss[utils]
	dev-libs/protobuf
	dev-python/pygobject
	dev-python/webpy
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
	sys-apps/module-init-tools
	x11-apps/mkfontdir
	x11-apps/xcursorgen
	x11-apps/xkbcomp
	>=x11-misc/util-macros-1.2
	x11-libs/gtk+
	sys-apps/nih-dbus-tool
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
	"

DEPEND=""
