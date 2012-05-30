# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2
CROS_WORKON_COMMIT="9eee961768ebc90ccf377240f63497d780467310"
CROS_WORKON_TREE="aa18d07212b5cf71136e13043690f306156b6c54"

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/kernel-next"
CROS_WORKON_LOCALNAME="../third_party/kernel-next/"

# This must be inherited *after* EGIT/CROS_WORKON variables defined
inherit cros-workon cros-kernel2

DESCRIPTION="Chrome OS Kernel-next"
KEYWORDS="amd64 arm x86"

DEPEND="!sys-kernel/chromeos-kernel"
RDEPEND="!sys-kernel/chromeos-kernel"
