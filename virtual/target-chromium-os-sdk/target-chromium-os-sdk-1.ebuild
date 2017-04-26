# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed inside the Chromium OS SDK"
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
# Note: Do not utilize USE=internal here.  Update virtual/target-chrome-os-sdk.
IUSE=""

# Block the old package to force people to clean up.
RDEPEND="!chromeos-base/hard-host-depends"

# Pull in any site-specific or private-overlay-specific packages needed on the
# host.
RDEPEND="${RDEPEND}
	virtual/hard-host-depends-bsp
	"

# Basic utilities
RDEPEND="${RDEPEND}
	app-arch/bzip2
	app-arch/cpio
	app-arch/gzip
	app-arch/tar
	app-shells/bash
	net-misc/iputils
	net-misc/rsync
	sys-apps/baselayout
	sys-apps/coreutils
	sys-apps/diffutils
	sys-apps/dtc
	sys-apps/file
	sys-apps/findutils
	sys-apps/gawk
	sys-apps/grep
	sys-apps/sed
	sys-apps/shadow
	sys-apps/texinfo
	sys-apps/util-linux
	sys-apps/which
	sys-devel/autoconf
	sys-devel/automake:1.10
	sys-devel/automake:1.11
	sys-devel/binutils
	sys-devel/bison
	sys-devel/flex
	sys-devel/gcc
	sys-devel/gnuconfig
	sys-devel/grit-i18n
	sys-devel/libtool
	sys-devel/m4
	sys-devel/make
	sys-devel/patch
	sys-fs/e2fsprogs
	sys-libs/ncurses
	sys-libs/readline
	sys-libs/zlib
	sys-process/procps
	sys-process/psmisc
	virtual/editor
	virtual/libc
	virtual/man
	virtual/os-headers
	virtual/package-manager
	virtual/pager
	"

# Needed to run setup crossdev, run build scripts, and make a bootable image.
RDEPEND="${RDEPEND}
	app-arch/lz4
	app-arch/lzop
	app-arch/pigz
	app-admin/sudo
	dev-embedded/cbootimage
	dev-embedded/tegrarcm
	dev-embedded/u-boot-tools
	dev-util/ccache
	dev-util/crosutils
	media-gfx/pngcrush
	>=sys-apps/dtc-1.3.0-r5
	sys-boot/bootstub
	sys-boot/grub
	sys-boot/syslinux
	sys-devel/crossdev
	sys-fs/dosfstools
	sys-fs/squashfs-tools
	sys-fs/mtd-utils
	"

# Needed to build Android/ARC userland code.
RDEPEND="${RDEPEND}
	sys-devel/arc-gcc
	sys-devel/arc-libs
	sys-devel/arc-llvm
	sys-devel/arc-llvm-mesa
	sys-devel/arc-toolchain-n
	"

# Needed to run 'repo selfupdate'
RDEPEND="${RDEPEND}
	app-crypt/gnupg
	"

# Host dependencies for building cross-compiled packages.
RDEPEND="${RDEPEND}
	app-admin/eselect-opengl
	app-admin/eselect-mesa
	app-admin/python-updater
	app-arch/cabextract
	app-arch/makeself
	>=app-arch/pbzip2-1.1.1-r1
	app-arch/rpm2targz
	app-arch/sharutils
	app-arch/unzip
	app-crypt/nss
	app-doc/xmltoman
	app-emulation/qemu
	app-emulation/qemu-binfmt-wrapper
	!app-emulation/qemu-kvm
	!app-emulation/qemu-user
	app-text/asciidoc
	app-text/docbook-xml-dtd:4.2
	app-text/docbook-xml-dtd:4.5
	app-text/docbook-xsl-stylesheets
	app-text/libpaper
	app-text/texi2html
	chromeos-base/google-breakpad
	chromeos-base/chromeos-base
	chromeos-base/chromeos-installer
	chromeos-base/cros-devutils[cros_host]
	chromeos-base/cros-testutils
	chromeos-base/ec-devutils
	dev-db/m17n-contrib
	dev-db/m17n-db
	dev-go/protobuf
	dev-lang/closure-compiler-bin
	dev-lang/nasm
	dev-lang/python:2.7
	dev-lang/python:3.3
	dev-lang/swig
	dev-lang/yasm
	dev-libs/dbus-c++
	dev-libs/dbus-glib
	>=dev-libs/glib-2.26.1
	dev-libs/libgcrypt
	dev-libs/libxslt
	dev-libs/libyaml
	dev-libs/m17n-lib
	dev-libs/protobuf
	dev-libs/protobuf-c
	dev-python/cffi
	dev-python/cherrypy
	dev-python/ctypesgen
	dev-python/dbus-python
	dev-python/dpkt
	dev-python/imaging
	dev-python/intelhex
	dev-python/m2crypto
	dev-python/mako
	dev-python/netifaces
	dev-python/pexpect
	dev-python/psutil
	dev-python/py
	dev-python/pycairo
	dev-python/pycparser
	dev-python/pygobject
	dev-python/pyinotify
	dev-python/pyopenssl
	dev-python/pytest
	dev-python/python-daemon
	dev-python/python-evdev
	dev-python/python-uinput
	dev-python/pyudev
	dev-python/pyusb
	dev-python/setproctitle
	dev-python/tempita
	dev-python/ws4py
	dev-util/cmake
	dev-util/gob
	dev-util/gdbus-codegen
	dev-util/gperf
	dev-util/gtk-doc
	dev-util/hdctools
	>=dev-util/gtk-doc-am-1.13
	>=dev-util/intltool-0.30
	dev-util/scons
	>=dev-vcs/git-1.7.2
	dev-vcs/subversion[-dso]
	>=media-libs/freetype-2.2.1
	>=media-libs/lcms-2.6:2
	net-misc/gsutil
	sys-apps/usbutils
	!sys-apps/nih-dbus-tool
	sys-devel/autofdo
	sys-devel/bc
	sys-devel/clang
	sys-fs/sshfs-fuse
	virtual/udev
	sys-libs/libnih
	sys-power/iasl
	virtual/modutils
	x11-apps/mkfontdir
	x11-apps/xcursorgen
	x11-apps/xkbcomp
	>=x11-misc/util-macros-1.2
	"

# Various fonts are needed in order to generate messages for the
# chromeos-initramfs package.
RDEPEND="${RDEPEND}
	chromeos-base/chromeos-fonts
	"

# Host dependencies for bitmap block (chromeos-bmpblk) to to render messages.
RDEPEND="${RDEPEND}
	gnome-base/librsvg
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
	x11-libs/libXrandr
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
	app-editors/nano
	app-editors/qemacs
	app-editors/vim
	app-portage/eclass-manpages
	app-portage/gentoolkit
	app-portage/portage-utils
	app-shells/bash-completion
	dev-go/go-tools
	dev-go/golint
	dev-lang/go
	dev-python/ipython
	dev-util/patchutils
	dev-util/perf
	sys-apps/less
	sys-apps/man-pages
	sys-apps/pv
	sys-devel/smatch
	"

# Host dependencies used by chromite on build servers
RDEPEND="${RDEPEND}
	dev-python/mysql-python
	dev-python/sqlalchemy
	dev-python/pyparsing
	dev-python/python-statsd
	dev-python/virtualenv
	"

# Host dependencies that are needed for unit tests
RDEPEND="${RDEPEND}
	x11-misc/xkeyboard-config
	"

# Host dependencies that are needed to build the autotest server components.
RDEPEND="${RDEPEND}
	dev-util/google-web-toolkit
	"

# Host dependencies that are needed for autotests.
RDEPEND="${RDEPEND}
	dev-python/btsocket
	dev-python/selenium
	dev-util/dejagnu
	sys-apps/iproute2
	sys-apps/net-tools
	"

# Host dependencies that are needed for media applications (ex, mplayer) used in
# factory.
RDEPEND="${RDEPEND}
	media-video/ffmpeg
	"

# Host dependencies that are needed to create and sign images
RDEPEND="${RDEPEND}
	>=chromeos-base/vboot_reference-1.0-r174
	chromeos-base/verity
	dev-python/ahocorasick
	sys-apps/mosys
	sys-fs/libfat
	"

# Host dependency used by the chromeos-base/root-certificates ebuild
RDEPEND="${RDEPEND}
	>=app-misc/ca-certificates-20090709-r6
	"

# Host dependencies that are needed for cros_generate_update_payload.
RDEPEND="${RDEPEND}
	chromeos-base/update_engine
	sys-fs/e2tools
	"

# Host dependencies to run unit tests within the chroot
RDEPEND="${RDEPEND}
	dev-cpp/gflags
	dev-go/mock
	dev-python/mock
	dev-python/mox
	dev-python/unittest2
	"
# Host dependencies to run autotest's unit tests within the chroot.
RDEPEND="${RDEPEND}
	dev-python/dnspython
	dev-python/httplib2
	dev-python/pyshark
	dev-python/python-dateutil
	dev-python/six
	"

# Host dependencies for running pylint within the chroot
RDEPEND="${RDEPEND}
	dev-python/pylint
	"

# Host dependencies to scp binaries from the binary component server
RDEPEND="${RDEPEND}
	net-misc/openssh
	net-misc/socat
	net-misc/wget
	"

# Host dependencies that are needed for chromite/bin/upload_package_status
RDEPEND="${RDEPEND}
	dev-python/gdata
	"

# Host dependencies for taking to dev boards
RDEPEND="${RDEPEND}
	dev-embedded/smdk-dltool
	"

# Host dependencies for HWID processing
RDEPEND="${RDEPEND}
	dev-python/pyyaml
	"

# Tools for working with compiler generated profile information
# (such as coverage analysis in common.mk)
RDEPEND="${RDEPEND}
	dev-util/lcov
	"

# Host dependencies for touchpad firmware tools
RDEPEND="${RDEPEND}
	chromeos-base/cypress-tools
	"

# Host dependencies for building Platform2
RDEPEND="${RDEPEND}
	chromeos-base/chromeos-dbus-bindings
	dev-util/gyp
	dev-util/ninja
	"

# Host dependencies for converting sparse into raw images (simg2img).
RDEPEND="${RDEPEND}
	brillo-base/libsparse
	"

# Host dependencies for building Chromium code (libmojo)
RDEPEND="${RDEPEND}
	dev-python/ply
	dev-util/gn
	"

# Uninstall these packages.
RDEPEND="${RDEPEND}
	!net-misc/dhcpcd
	"

# Host dependencies for building/testing factory software
RDEPEND="${RDEPEND}
	chromeos-base/regions
	dev-libs/closure-library
	dev-libs/closure_linter
	dev-python/autopep8
	dev-python/django
	dev-python/enum34
	dev-python/flup
	dev-python/jsonrpclib
	dev-python/jsonschema
	dev-python/paramiko
	dev-python/pycrypto
	dev-python/python-gnupg
	dev-python/sphinx
	!dev-python/twisted
	dev-python/twisted-core
	dev-python/twisted-web
	www-servers/nginx
	"

# Host dependencies for building harfbuzz
RDEPEND="${RDEPEND}
	dev-util/ragel
	"

# Host dependencies for building chromeos-bootimage
RDEPEND="${RDEPEND}
	sys-apps/coreboot-utils
	"

# Host dependencies for virtualbox-guest-additions
RDEPEND="${RDEPEND}
	dev-util/kbuild
	"

# Host dependencies for audio topology generation
RDEPEND="${RDEPEND}
	media-sound/alsa-utils"

# Host dependency for dev-libs/boost package
RDEPEND="${RDEPEND}
	dev-util/boost-build"

# Host dependency for managing SELinux labels
RDEPEND="${RDEPEND}
	sys-apps/restorecon"

# Host dependencies that are needed for chromite/bin/cros_generate_android_breakpad_symbols
RDEPEND="${RDEPEND}
	chromeos-base/android-relocation-packer"
