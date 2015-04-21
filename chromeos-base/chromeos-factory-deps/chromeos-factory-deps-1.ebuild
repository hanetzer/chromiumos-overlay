# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI="4"

DESCRIPTION="List of packages that are needed for Chrome OS factory software."
HOMEPAGE="http://dev.chromium.org/"

LICENSE="BSD-Google"
SLOT="0"
KEYWORDS="*"
IUSE="+shill X"

################################################################################

# Packages for factory framework ("Goofy"):
FACTORY_FRAMEWORK_RDEPEND="
	shill? ( chromeos-base/shill-test-scripts )
	dev-lang/python
	dev-python/dbus-python
	dev-python/dpkt
	dev-python/imaging
	dev-python/jsonrpclib
	dev-python/netifaces
	dev-python/pygobject
	dev-python/pyyaml
	dev-python/setproctitle
	dev-python/ws4py
"
# Note: factory repo also has a 'third_party/jsonrpclib' and factory software
# used to run that instead of dev-python/jsonrpclib.
# dbus-python may be temporarily broken on embedded platform.

# Packages used only if X is available.
FACTORY_X_RDEPEND="
	dev-python/python-xlib
	x11-apps/xinput
	x11-apps/xrandr
	x11-misc/xdotool
"

# Packages shared by several pytests inside factory.
# TODO(itspeter): Might remove cryptohome once a conclusion
#                 comes in http://crosbug.com/p/31800.
FACTORY_TEST_RDEPEND="
	app-arch/xz-utils
	chromeos-base/cryptohome
	dev-python/numpy
	dev-python/pyserial
	dev-python/python-evdev
	dev-python/pyudev
	dev-util/stressapptest
	net-ftp/pybootd
	sys-apps/iproute2
	sys-apps/lshw
"

# Packages used by audio related tests
FACTORY_TEST_RDEPEND+="
	chromeos-base/audiotest
	media-sound/sox
"

# Packages used by camera related tests
FACTORY_TEST_RDEPEND+="
	media-gfx/zbar
	media-libs/opencv
"

# Packages used by removable storage test.
FACTORY_TEST_RDEPEND+="
	sys-block/parted
"

# Packages used by network related tests.
FACTORY_TEST_RDEPEND+="
	dev-python/pexpect
	net-misc/iperf:3
"

# Packages used by registration code tests.
FACTORY_TEST_RDEPEND+="
	dev-libs/protobuf-python
"

# Packages to support running autotest tests inside factory framework.
FACTORY_TEST_RDEPEND+="
	chromeos-base/autotest-client
"

# Packages to support in-place factory wiping inside factory software.
FACTORY_TEST_RDEPEND+="
	sys-apps/busybox
"

# Packages needed to unpack firmware updater (chromeos-firmware).
# The related packages will be included if chromeos-firmware package
# is enabled for a board. However, some new boards might be added
# to an early created factory branch without package chromeos-firmware.
# This will make unpacking firmware updater fail on the test image
# generated from the factor branch due to lack of those packages.
# Add them into test image to fix the failure.
# The contents of FACTORY_TEST_RDEPEND below must also be present in the
# chromeos-base/chromeos-factoryinstall ebuild in PROVIDED_DEPEND.
# If you make any change to the list below, you may need to make a
# matching change in the factory install ebuild.
FACTORY_TEST_RDEPEND+="
	app-arch/gzip
	app-arch/sharutils
	app-arch/tar
	chromeos-base/vboot_reference
"
################################################################################
# Assemble the final RDEPEND variable for portage
################################################################################
RDEPEND="${FACTORY_FRAMEWORK_RDEPEND}
	 ${FACTORY_TEST_RDEPEND}
	 X? ( ${FACTORY_X_RDEPEND} )
"
