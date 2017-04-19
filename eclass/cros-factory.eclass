# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# @ECLASS: cros-factory.eclass
# @MAINTAINER:
# The Chromium OS Authors <chromium-os-dev@chromium.org>
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: Eclass to help creating per-board factory resources.

# Check for EAPI 3+
case "${EAPI:-0}" in
	0|1|2)
		die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

# @ECLASS-VARIABLE: CROS_FACTORY_BOARD_RESOURCES_DIR
# @DESCRIPTION: Folder of factory resources to current board.
: ${CROS_FACTORY_BOARD_RESOURCES_DIR:=/var/lib/factory/resources}

# @FUNCTION: factory_create_resource
# @USAGE: <name> <local_dir> <resource_dir> <objects...>
# @DESCRIPTION:
# Adds a resource for ChromeOS Factory (chromeos-base/chromeos-factory) to merge
# into build outputs.
#
# <name> is the name of resource archive without file name extension, which
# should be in format $TARGET-$IDENTIFIER. TARGET is the build targets in
# src/platform/factory/Makefile. Currently you can use following targets:
#  toolkit - only included when building toolkit (not in par).
#  par - only included when building par (not in toolkits).
#  resource - included in all targets (toolkit & par).
#  factory - same as resource.
# Defaults to "factory-board" if param is empty.
#
# <local_dir> is the path to where prepared files lives, for example ${WORKDIR}.
# Defaults to "${WORKDIR}" if param is empty.
#
# <resource_dir> is the path to where the files should be located in resource
# file, under /usr/local/factory. For example "py". Defaults to "." if param is
# empty.
#
# <objects> are files or directories to be copied into resource archive.
#
# @EXAMPLE:
# To copy files from ${WORKDIR}/dist/webgl_aquarium_static as
#  /usr/local/factory/py/test/pytests/webgl_aquarium_static/* in resource file
#  ${D}/var/lib/factory/resources/factory-board.tar:
#
# @CODE
#  factory_create_resource factory-board "${WORKDIR}/dist" \
#    py/test/pytests webgl_aquarium_static
# @CODE
factory_create_resource() {
	local params="<name> <local_dir> <resource_dir> <objects>..."
	[[ $# -gt 3 ]] || die "Usage: ${FUNCNAME} ${params}"

	local name="$1"
	local local_dir="$2"
	local resource_dir="$3"
	shift
	shift
	shift

	local archive_dir="${ED}${CROS_FACTORY_BOARD_RESOURCES_DIR}"
	mkdir -p "${archive_dir}"

	# Normalize resource_dir.
	[ -n "${name}" ] || name="factory-board"
	[ -n "${local_dir}" ] || local_dir="${WORKDIR}"
	[ -n "${resource_dir}" ] || resource_dir="."

	# transform regular file paths, but not targets of symbolic links and hard
	# links.
	tar -cf "${archive_dir}/${name}.tar" \
		-C "${local_dir}" --transform "s'^'${resource_dir}/'SH" \
		"$@"
}

# @FUNCTION: factory_unpack_resource
# @USAGE: <name> [output_dir]
# @DESCRIPTION:
# Unpacks a resource file prepared for ChromeOS Factory
# (chromeos-base/chromeos-factory). See factory_create_resource for more
# details.
#
# <name> is the name of resource archive without file name extension.
#
# [output_dir] is the path to unpack resource contents, for example ${WORKDIR}.
# Defaults to "${WORKDIR}" if param is empty.
#
# @EXAMPLE:
# To extract files from ${EROOT}var/lib/factory/resources/factory-board.tar
# to ${WORKDIR}/py/test/pytests:
#
# @CODE
#  factory_unpack_resource factory-board "${WORKDIR}/py/test/pytests"
# @CODE
factory_unpack_resource() {
	local name="$1"
	local output_dir="${2:-${WORKDIR}}"
	[[ $# -gt 2 ]] && die "Usage: ${FUNCNAME} <name> [output dir]"

	mkdir -p "${output_dir}"
	tar -xvf "${EROOT}${CROS_FACTORY_BOARD_RESOURCES_DIR}/${name}.tar" \
		-C "${output_dir}"
}
