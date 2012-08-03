# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="8e9318ea2a9c90d6571d4a45f8c3e0ef2103e945"
CROS_WORKON_TREE="0de8ee686dd56217853cb3ae4a00bbc243f2e0ca"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/platform/mtpd"
CROS_WORKON_LOCALNAME="mtpd"

inherit toolchain-funcs cros-debug cros-workon

DESCRIPTION="MTP daemon for Chromium OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"
IUSE="splitdebug test"

LIBCHROME_VERS="125070"

RDEPEND="
	chromeos-base/libchromeos
	dev-cpp/gflags
	dev-libs/dbus-c++
	>=dev-libs/glib-2.30
	media-libs/libmtp
	sys-fs/udev
"

DEPEND="${RDEPEND}
	chromeos-base/libchrome:${LIBCHROME_VERS}[cros-debug=]
	chromeos-base/system_api"

src_compile() {
	tc-export CXX CC PKG_CONFIG
	cros-debug-add-NDEBUG
	export BASE_VER=${LIBCHROME_VERS}
	emake OUT=build-opt
}

src_install() {
	exeinto /opt/google/mtpd
	doexe build-opt/mtpd

#   TODO(jorgelo) Add security policy. http://crosbug.com/33228
#	# Install seccomp policy file.
#	if [ -f "mtpd-seccomp-${ARCH}.policy" ]; then
#		newins "mtpd-seccomp-${ARCH}.policy" mtpd-seccomp.policy
#	fi

#   TODO(thestig) Add config files when ready.
#	# Install upstart config file.
#	insinto /etc/init
#	doins mtpd.conf

#	# Install D-Bus config file.
#	insinto /etc/dbus-1/system.d
#	doins org.chromium.Mtpd.conf
}
