# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="3c1b0d0b708eebd0c650fa0329c8938de1a0be20"
CROS_WORKON_TREE="202a8552701eb8d549b6918986b02512a8beaeb5"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.8"

# AFDO_PROFILE_VERSION is the build on which the profile is collected.
# This is required by kernel_afdo.
AFDO_PROFILE_VERSION="9460.50.0"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Linux Kernel 3.8"
HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
KEYWORDS="*"
