# Copyright (c) 2017 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="f988c9293ac654a724e4dae8acd58d493b10a048"
CROS_WORKON_TREE="0821e22798215ec70bb4303bc47900db41b7c70e"
CROS_WORKON_PROJECT="chromiumos/third_party/kernel"
CROS_WORKON_LOCALNAME="kernel/v3.10"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

HOMEPAGE="https://www.chromium.org/chromium-os/chromiumos-design-docs/chromium-os-kernel"
DESCRIPTION="Chrome OS Linux Kernel 3.10"
KEYWORDS="*"
RDEPEND="!sys-kernel/kernel-freon"
