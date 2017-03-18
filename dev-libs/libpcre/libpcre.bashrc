# Copyright 2017 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

cros_pre_src_prepare_libpcre_patches() {
	# TODO(benchan): Remove this patch once upstream gentoo picks up the patch.
	patch -p2 < "${BASHRC_FILESDIR}"/${PN}-8.38-fix-missing-else-in-JIT-compiler.patch || die
}
