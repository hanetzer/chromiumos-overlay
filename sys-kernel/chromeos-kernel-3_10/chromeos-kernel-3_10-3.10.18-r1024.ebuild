# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="116728a6b84c42452a3c80337abd59faace99da9"
CROS_WORKON_TREE="b589a8b21f55166af5435a7decae6a37b9c8f568"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.10"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
DESCRIPTION="Chrome OS Linux Kernel 3.10"
KEYWORDS="*"
RDEPEND="!sys-kernel/kernel-freon"
