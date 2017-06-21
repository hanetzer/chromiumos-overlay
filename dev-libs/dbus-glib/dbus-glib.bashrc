# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_dbus-glib_patches() {
	# TODO(benchan): Remove this patch once upstream gentoo picks up the patch.
	patch -p1 < "${BASHRC_FILESDIR}/${P}-unused-function.patch" || die
}
