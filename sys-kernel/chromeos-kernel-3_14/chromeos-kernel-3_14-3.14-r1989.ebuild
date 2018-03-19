# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=5
CROS_WORKON_COMMIT="e3ccf1ab6cabb1702671cb6a21a2d4d5b4b7ea65"
CROS_WORKON_TREE="69799df3b76ed66182bc7842c5dedafb45ef4a00"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.14"

# AFDO_PROFILE_VERSION is the build on which the profile is collected.
# This is required by kernel_afdo.
#
# TODO: Allow different versions for different CHROMEOS_KERNEL_SPLITCONFIGs
AFDO_PROFILE_VERSION="R67-10452.1-1521150888"

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
# The coolest prime number is: 2^74,207,281 − 1
