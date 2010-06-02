# Copyright (c) 2010 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

#
# Original Author: The Chromium OS Authors <chromium-os-dev@chromium.org>
# Purpose: Install binary packages for Chromium OS
#

# @ECLASS-VARIABLE: CROS_BINARY_STORE_DIR
# @DESCRIPTION:
# Storage directory for Chrome OS Binaries
: ${CROS_BINARY_STORE_DIR:=${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/cros-binary}

# @ECLASS-VARIABLE: CROS_BINARY_URI
# @DESCRIPTION:
# URI for the binary may be one of:
#   http://
#   https://
#   ssh://
#   file:// (file is relative to the files directory)
# TODO: Add "->" support if we get file collisions
: ${CROS_BINARY_URI:=}

# @ECLASS-VARIABLE: CROS_BINARY_SUM
# @DESCRIPTION:
# Optional SHA-1 sum of the file to be fetched
: ${CROS_BINARY_SUM:=}

DEPEND="net-misc/openssh
	net-misc/wget"

# Check for EAPI 2 or 3
case "${EAPI:-0}" in
	3|2) ;;
	1|0|:) DEPEND="EAPI-UNSUPPORTED" ;;
esac

cros-binary_check_file() {
	local target="${CROS_BINARY_STORE_DIR}/${CROS_BINARY_URI##*/}"
	if [[ -z "${CROS_BINARY_SUM}" ]]; then
		[[ -r "${target}" ]]
		return
	else
		echo "${CROS_BINARY_SUM}  ${target}" |
			sha1sum -c --quiet >/dev/null 2>&1
		return
	fi
}

cros-binary_fetch() {
	local scheme="${CROS_BINARY_URI%%://*}"
	local non_scheme=${CROS_BINARY_URI##*//}
	local netloc=${non_scheme%%/*}
	local path=${non_scheme#*/}

	local target="${CROS_BINARY_STORE_DIR}/${CROS_BINARY_URI##*/}"

	addwrite "${CROS_BINARY_STORE_DIR}"
	if [[ ! -d "${CROS_BINARY_STORE_DIR}" ]]; then
		mkdir -p "${CROS_BINARY_STORE_DIR}" ||
			die "Failed to mkdir ${CROS_BINARY_STORE_DIR}"
	fi

	if ! cros-binary_check_file; then
		rm -f "${target}"
		case "${scheme}" in
			http|https)
				wget "${CROS_BINARY_URI}" -O "${target}" -nv -nc ||
					rm -f "${target}"
				;;

			ssh)
				scp -qo BatchMode=yes "${netloc}:${path}" "${target}" ||
					rm -f "${target}"
				;;

			file)
				if [[ "${non_scheme:0:1}" == "/" ]]; then
					cp "${non_scheme}" "${target}" || rm -f "${target}"
				else
					cp "${FILESDIR}/${non_scheme}" "${target}" ||
						rm -f "${target}"
				fi
				;;

			*)
				die "Protocol for '${CROS_BINARY_URI}' is unsupported."
				;;
		esac
	fi

	cros-binary_check_file || die "Failed to fetch ${CROS_BINARY_URI}."
}

cros-binary_src_unpack() {
	cros-binary_fetch
}

cros-binary_src_install() {
	local target="${CROS_BINARY_STORE_DIR}/${CROS_BINARY_URI##*/}"

	local extension="${CROS_BINARY_URI##*.}"
	local flags

	case "${CROS_BINARY_URI##*.}" in
		gz|tgz) flags="z";;
		bz2|tbz2) flags="j";;
		*) die "Unsupported binary file format ${CROS_BINARY_URI##*.}"
	esac

	cd "${D}" || die
	tar "${flags}xpf" "${target}" || die "Failed to unpack"
}

EXPORT_FUNCTIONS src_unpack src_install

