# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="83129358af548d9abe7464abec145f03475a2116"
CROS_WORKON_TREE="bf65979316895cf0218f3643cbc7b9ad0b60fb26"

EAPI="4"
CROS_WORKON_PROJECT="chromiumos/platform/crostestutils"

inherit cros-workon

DESCRIPTION="Host test utilities for ChromiumOS"
HOMEPAGE="http://www.chromium.org/"

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="amd64 arm x86"

CROS_WORKON_LOCALNAME="crostestutils"


RDEPEND="app-emulation/qemu-kvm
	app-portage/gentoolkit
	app-shells/bash
	chromeos-base/cros-devutils
	dev-util/crosutils
	"

# These are all either bash / python scripts.  No actual builds DEPS.
DEPEND=""

# Use default src_compile and src_install which use Makefile.
