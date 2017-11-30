# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="c599af055a4958689c14e214488e5465e7c2a5e3"
CROS_WORKON_TREE="00ddac65cfa1503adc5b1a9098416977108eca6b"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.14"

# AFDO_PROFILE_VERSION is the build on which the profile is collected.
# This is required by kernel_afdo.
#
# TODO: Allow different versions for different CHROMEOS_KERNEL_SPLITCONFIGs
AFDO_PROFILE_VERSION="R64-10134.0-1511783861"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
DESCRIPTION="Chrome OS Linux Kernel 3.14"
KEYWORDS="*"

# Change the following (commented out) number to the next prime number
# when you change "cros-kernel2.eclass" to work around http://crbug.com/220902
#
# NOTE: There's nothing magic keeping this number prime but you just need to
# make _any_ change to this file.  ...so why not keep it prime?
#
# Don't forget to update the comment in _all_ chromeos-kernel-x_x-9999.ebuild
# files (!!!)
#
# The coolest prime number is: 31
