# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="9fa06b7e4e6771b1abe76137c455530f7984c64b"
CROS_WORKON_TREE="e1c1173e8f1c0a8fba8cfab6ad3d7dd6deeda15c"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.10"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
DESCRIPTION="Chrome OS Linux Kernel 3.10"
KEYWORDS="*"
RDEPEND="!sys-kernel/kernel-freon"
