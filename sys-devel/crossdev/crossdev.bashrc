# Copyright (c) 2013 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_crossdev_patches() {
	patch -p1 < "${BASHRC_FILESDIR}"/${PN}-nds32.patch || die
}
