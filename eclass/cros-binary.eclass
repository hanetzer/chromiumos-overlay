# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Install binary packages for Chromium OS
#

# Reject old users of cros-binary eclass that expected us to download files
# directly rather than going through SRC_URI.
cros-binary_dead_usage() {
	die "You must add files to SRC_URI now"
}
if [[ ${CROS_BINARY_STORE_DIR:+set} == "set" ||
      ${CROS_BINARY_SUM:+set} == "set" ||
      ${CROS_BINARY_FETCH_REQUIRED:+set} == "set" ]]; then
	cros-binary_dead_usage
fi

# @ECLASS-FUNCTION: cros-binary_add_uri
# @DESCRIPTION:
# Add a fetch uri to SRC_URI for the given uri.  See
# CROS_BINARY_URI for what is accepted.  Note you cannot
# intermix a non-rewritten ssh w/ (http|https|gs).
cros-binary_add_uri()
{
	if [[ $# -ne 1 ]]; then
		die "cros-binary_add_uri takes exactly one argument; $# given."
	fi
	local uri="$1"
	if [[ "${uri}" =~ ^ssh://([^@]+)@git.chromium.org[^/]*/(.*)$ ]]; then
		uri="gs://chromeos-binaries/HOME/${BASH_REMATCH[1]}/${BASH_REMATCH[2]}"
	fi
	case "${uri}" in
		http://*|https://*|gs://*)
			SRC_URI+=" ${uri}"
			CROS_BINARY_FETCH_REQUIRED=false
			CROS_BINARY_STORE_DIR="${DISTDIR}"
			;;
		*)
			die "Unknown protocol: ${uri}"
			;;
	esac
	RESTRICT+=" mirror"
}

# @ECLASS-FUNCTION: cros-binary_add_gs_uri
# @DESCRIPTION:
# Wrapper around cros-binary_add_uri.  Invoked with 3 arguments;
# the bcs user, the overlay, and the filename (or bcs://<uri> for
# backwards compatibility).
cros-binary_add_gs_uri() {
	if [[ $# -ne 3 ]]; then
		die "cros-binary_add_bcs_uri needs 3 arguments; $# given."
	fi
	# Strip leading bcs://...
	[[ "${3:0:6}" == "bcs://" ]] && set -- "${1}" "${2}" "${3#bcs://}"
	cros-binary_add_uri "gs://chromeos-binaries/HOME/$1/$2/$3"
}

# @ECLASS-FUNCTION: cros-binary_add_overlay_uri
# @DESCRIPTION:
# Wrapper around cros-binary_add_bcs_uri.  Invoked with 2 arguments;
# the basic board target (x86-alex for example), and the filename; that filename
# is automatically prefixed with "${CATEGORY}/${PN}/" .
cros-binary_add_overlay_uri() {
	if [[ $# -ne 2 ]]; then
		die "cros-binary_add_bcs_uri_simple needs 2 arguments; $# given."
	fi
	cros-binary_add_gs_uri bcs-"$1" overlay-"$1" "${CATEGORY}/${PN}/$2"
}

# @ECLASS-VARIABLE: CROS_BINARY_URI
# @DESCRIPTION:
# URI for the binary may be one of:
#   http://
#   https://
#   ssh://
#   gs://
#   file:// (file is relative to the files directory)
# Additionally, all bcs ssh:// urls are rewritten to gs:// automatically
# the appropriate GS bucket- although cros-binary_add_uri is the preferred
# way to do that.
# TODO: Deprecate this variable's support for ssh and http/https.
: ${CROS_BINARY_URI:=}
if [[ -n "${CROS_BINARY_URI}" ]]; then
	cros-binary_add_uri "${CROS_BINARY_URI}"
fi

# @ECLASS-VARIABLE: CROS_BINARY_INSTALL_FLAGS
# @DESCRIPTION:
# Optional Flags to use while installing the binary
: ${CROS_BINARY_INSTALL_FLAGS:=}

# @ECLASS-VARIABLE: CROS_BINARY_LOCAL_URI_BASE
# @DESCRIPTION:
# Optional URI to override CROS_BINARY_URI location.  If this variable
# is used the filename from CROS_BINARY_URI will be used, but the path
# to the binary will be changed.
: ${CROS_BINARY_LOCAL_URI_BASE:=}

# Check for EAPI 2+
case "${EAPI:-0}" in
2|3|4|5|6) ;;
*) die "unsupported EAPI (${EAPI}) in eclass (${ECLASS})" ;;
esac

cros-binary_check_file() {
	cros-binary_dead_usage
}

cros-binary_fetch() {
	cros-binary_dead_usage
}

cros-binary_src_unpack() {
	cros-binary_dead_usage
}

cros-binary_src_install() {
	local target="${CROS_BINARY_URI##*/}"
	if ${CROS_BINARY_FETCH_REQUIRED}; then
		target="${CROS_BINARY_STORE_DIR}/${target}"
	else
		target="${DISTDIR}/${target}"
	fi

	local extension="${CROS_BINARY_URI##*.}"
	local flags

	case "${CROS_BINARY_URI##*.}" in
		gz|tgz) flags="z";;
		bz2|tbz2) flags="j";;
		*) die "Unsupported binary file format ${CROS_BINARY_URI##*.}"
	esac

	cd "${D}" || die
	tar "${flags}xpf" "${target}" ${CROS_BINARY_INSTALL_FLAGS} || die "Failed to unpack"
}

EXPORT_FUNCTIONS src_install

