# Copyright (c) 2009 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

DESCRIPTION="List of packages that are needed on the buildhost (meta package)"
HOMEPAGE="http://src.chromium.org"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 x86"
IUSE="-asan"

# Needed to run setup crossdev, run build scripts, and make a bootable image.
RDEPEND="${RDEPEND}
	app-arch/pigz
	app-admin/sudo
	dev-embedded/cbootimage
	dev-embedded/u-boot-tools
	dev-util/crosutils
	>=sys-apps/dtc-1.3.0-r4
	sys-boot/bootstub
	sys-boot/grub
	sys-boot/syslinux
	sys-devel/crossdev
	sys-fs/dosfstools
	"

# Host dependencies for building cross-compiled packages.
RDEPEND="${RDEPEND}
	app-admin/eselect-opengl
	app-admin/eselect-mesa
	app-arch/cabextract
	>=app-arch/pbzip2-1.1.1-r1
	app-arch/rpm2targz
	app-arch/sharutils
	app-arch/unzip
	app-crypt/nss
	>=app-emulation/qemu-user-0.12.2
	app-i18n/ibus
	app-text/texi2html
	chromeos-base/google-breakpad
	chromeos-base/chromeos-installer
	chromeos-base/cros-devutils[cros_host]
	chromeos-base/cros-factoryutils
	chromeos-base/cros-testutils
	dev-lang/python
	dev-db/m17n-contrib
	dev-db/m17n-db
	dev-lang/nasm
	dev-lang/swig
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	>=dev-libs/glib-2.26.1
	dev-libs/eggdbus
	dev-libs/libgcrypt
	dev-libs/libxslt
	dev-libs/libyaml
	dev-libs/m17n-lib
	dev-libs/protobuf
	dev-python/cherrypy
	dev-python/dbus-python
	dev-python/imaging
	dev-python/m2crypto
	dev-python/pygobject
	dev-python/pygtk
	dev-python/pyopenssl
	dev-python/pyusb
	=dev-util/boost-build-1.42.0
	dev-util/cmake
	>=dev-util/git-1.7.2
	dev-util/gob
	dev-util/gperf
	dev-util/hdctools
	dev-util/subversion[-dso]
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.30
	dev-util/scons
	>=media-libs/freetype-2.2.1
	media-libs/mesa
	sys-apps/gsutil
	sys-apps/module-init-tools
	!sys-apps/nih-dbus-tool
	asan? ( sys-devel/asan-clang )
	sys-fs/sshfs-fuse
	sys-libs/libnih
	sys-power/iasl
	x11-apps/mkfontdir
	x11-apps/xcursorgen
	x11-apps/xkbcomp
	x11-libs/gtk+
	>=x11-misc/util-macros-1.2
	"

# Host dependencies for building chromium.
# Intermediate executables built for the host, then run to generate data baked
# into chromium, need these packages to be present in the host environment in
# order to successfully build.
# See: http://codereview.chromium.org/7550002/
RDEPEND="${RDEPEND}
	dev-libs/atk
	dev-libs/glib
	media-libs/fontconfig
	media-libs/freetype
	x11-libs/cairo
	x11-libs/libX11
	x11-libs/libXi
	x11-libs/libXtst
	x11-libs/pango
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
	app-arch/zip
	app-portage/gentoolkit
	app-portage/portage-utils
	app-editors/qemacs
	app-editors/vim
	dev-util/perf
	sys-apps/pv
	"

# Host dependencies that are needed for unit tests
RDEPEND="${RDEPEND}
	x11-misc/xkeyboard-config
	"

# Host dependencies that are needed for autotests.
RDEPEND="${RDEPEND}
	dev-util/dejagnu
	"

# Host dependencies that are needed to create and sign images
RDEPEND="${RDEPEND}
	>=chromeos-base/vboot_reference-1.0-r174
	chromeos-base/verity
	media-gfx/imagemagick[gs,truetype]
	sys-apps/mosys
	"

# Host dependency used by the chromeos-base/root-certificates ebuild
RDEPEND="${RDEPEND}
	>=app-misc/ca-certificates-20090709-r6
	"

# Host dependencies that are needed for delta_generator.
RDEPEND="${RDEPEND}
	chromeos-base/update_engine
	"

# Host dependencies to run unit tests within the chroot
RDEPEND="${RDEPEND}
	dev-cpp/gflags
	dev-python/pymox
	"

# Host dependencies for running pylint within the chroot
RDEPEND="${RDEPEND}
	dev-python/pylint
	"

# Host dependencies to scp binaries from the binary component server
RDEPEND="${RDEPEND}
	chromeos-base/ssh-known-hosts
	chromeos-base/ssh-root-dot-dir
	"

# Host dependencies that are needed for chromite/bin/upload_package_status
RDEPEND="${RDEPEND}
	dev-python/gdata
	"

# Uninstall these packages.
RDEPEND="${RDEPEND}
	!net-misc/dhcpcd
	"
