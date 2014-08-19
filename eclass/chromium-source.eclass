# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2


# @ECLASS: chromium-source.eclass
# @MAINTAINER:
# ChromiumOS Build Team
# @BUGREPORTS:
# Please report bugs via http://crbug.com/new (with label Build)
# @VCSURL: https://chromium.googlesource.com/chromiumos/overlays/chromiumos-overlay/+/master/eclass/@ECLASS@
# @BLURB: helper eclass for building packages using the Chromium source code.
# @DESCRIPTION:
# To use this eclass, call chromium-source_src_unpack() from
# src_unpack() in your ebuild. This will set CHROMIUM_SOURCE_DIR to
# where the Chromium source is stored and will also setup the right
# credentials needed by the Chromium build scripts.
#
# Additionally, the CHROMIUM_SOURCE_ORIGIN variable will be set to
# LOCAL_SOURCE if CHROMIUM_SOURCE_DIR points to a local checkout and
# SERVER_SOURCE is it points to a checkout from external VCS
# servers. By default, this is set to LOCAL_SOURCE for ebuilds that
# are being cros_workon'ed and SERVER_SOURCE otherwise. Users can
# override which behavior to use by setting the variable in the
# environment.
#
# This eclass also adds a dependency on chromeos-base/chromium-source
# which is the ebuild used for downloading the source code.

IUSE="cros_internal"

# If we're cros_workon'ing the ebuild, default to LOCAL_SOURCE,
# otherwise use SERVER_SOURCE.
chromium_source_compute_origin() {
	if [[ -n "${CHROME_ORIGIN}" && -z "${CHROMIUM_SOURCE_ORIGIN}" ]]; then
		ewarn "Using CHROME_ORIGIN instead of CHROMIUM_SOURCE_ORIGIN."
		ewarn "Please update your workflow to use CHROMIUM_SOURCE_ORIGIN."
		CHROMIUM_SOURCE_ORIGIN=${CHROME_ORIGIN}
	fi

	local chrome_workon="=${CATEGORY}/${PN}-9999"
	local cros_workon_file="${ROOT}etc/portage/package.keywords/cros-workon"
	if [[ -e "${cros_workon_file}" ]] && grep -q "${chrome_workon}" "${cros_workon_file}"; then
		# LOCAL_SOURCE is the default for cros_workon
		# Warn the user if CHROMIUM_SOURCE_ORIGIN is already set
		if [[ -n "${CHROMIUM_SOURCE_ORIGIN}" && "${CHROMIUM_SOURCE_ORIGIN}" != LOCAL_SOURCE ]]; then
			ewarn "CHROMIUM_SOURCE_ORIGIN is already set to ${CHROMIUM_SOURCE_ORIGIN}."
			ewarn "This will prevent you from building from your local checkout."
			ewarn "Please run 'unset CHROMIUM_SOURCE_ORIGIN' to reset the build"
			ewarn "to the default source location."
		fi
		: ${CHROMIUM_SOURCE_ORIGIN:=LOCAL_SOURCE}
	else
		# By default, pull from server
		: ${CHROMIUM_SOURCE_ORIGIN:=SERVER_SOURCE}
	fi

	case "${CHROMIUM_SOURCE_ORIGIN}" in
	LOCAL_SOURCE|SERVER_SOURCE)
		elog "CHROMIUM_SOURCE_ORIGIN is ${CHROMIUM_SOURCE_ORIGIN}"
		;;
	*)
		die "CHROMIUM_SOURCE_ORIGIN is not one of LOCAL_SOURCE, SERVER_SOURCE"
		;;
	esac
}

# Calculate the actual source directory, depending on whether we're
# using LOCAL_SOURCE or SERVER_SOURCE.
chromium_source_compute_source_dir() {
	case "${CHROMIUM_SOURCE_ORIGIN}" in
	LOCAL_SOURCE)
		local WHOAMI=$(whoami)
		CHROMIUM_SOURCE_DIR=/home/${WHOAMI}/chrome_root
		if [[ ! -d "${CHROMIUM_SOURCE_DIR}/src" ]]; then
			die "${CHROMIUM_SOURCE_DIR} does not contain a valid chromium checkout!"
		fi
		;;
	*)
		local CHROME_SRC="chrome-src"
		if use chrome_internal; then
			CHROME_SRC="${CHROME_SRC}-internal"
		fi
		CHROMIUM_SOURCE_DIR="${PORTAGE_ACTUAL_DISTDIR:-${DISTDIR}}/${CHROME_SRC}"
		;;
	esac
}

# Copy in credentials to fake home directory so that build process can
# access svn and ssh if needed.
chromium_source_copy_credentials() {
	mkdir -p "${HOME}"
	local WHOAMI=$(whoami)
	SUBVERSION_CONFIG_DIR="/home/${WHOAMI}/.subversion"
	if [[ -d "${SUBVERSION_CONFIG_DIR}" ]]; then
		cp -rfp "${SUBVERSION_CONFIG_DIR}" "${HOME}" || die
	fi
	SSH_CONFIG_DIR="/home/${WHOAMI}/.ssh"
	if [[ -d "${SSH_CONFIG_DIR}" ]]; then
		cp -rfp "${SSH_CONFIG_DIR}" "${HOME}" || die
	fi
	NET_CONFIG="/home/${WHOAMI}/.netrc"
	if [[ -f "${NET_CONFIG}" ]]; then
		cp -fp "${NET_CONFIG}" "${HOME}" || die
	fi
}

chromium-source_src_unpack() {
	chromium_source_compute_origin
	chromium_source_compute_source_dir
	chromium_source_copy_credentials
}

if [[ ${PN} != "chromium-source" ]]; then
	DEPEND="~chromeos-base/chromium-source-${PV}"
fi
