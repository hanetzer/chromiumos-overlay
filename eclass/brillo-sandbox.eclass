# Copyright 2015 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# @ECLASS: brillo-sandbox.eclass
# @MAINTAINER:
# Christopher Wiley <wiley@chromium.org>
# @BLURB: sandbox metadata installation in ebuilds
# @DESCRIPTION:
# Allows installation of an appc pod manifest in a format understood by the
# psyche framework. Accomplishes this primarily by shelling out to scripts
# installed in chromite/.

inherit cros-constants

# @FUNCTION: dobrsandbox
# @USAGE: <path to appc pod manifest>
# @DESCRIPTION:
# Validates and installs an appc pod manifest to a system image.
dobrsandbox() {
	[[ $# -ne 1 ]] && die "usage: dobrsandbox <appc_pod_manifest_path>"
	local manifest_path=$1

	local spec_folder="/usr/share/somad"
	dodir "${spec_folder}"

	local spec_basename=$(basename "${manifest_path}" .json).spec
	"${CHROMITE_BIN_DIR}/generate_container_spec" \
		--sysroot "${SYSROOT}" \
		"${manifest_path}" \
		"${D}/${spec_folder}/${spec_basename}" \
		|| die "Failed to generate sandbox metadata from pod manifest ${manifest_path}"
}
