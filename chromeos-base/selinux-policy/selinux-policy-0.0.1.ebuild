# Copyright 2018 The Chromium Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2.

EAPI=5

DESCRIPTION="Chrome OS SELinux Policy Package"
SLOT="0"
KEYWORDS="*"
LICENSE="BSD-Google"
IUSE="cheets_local_img"
DEPEND="chromeos-base/android-container-pi:0="

SELINUX_VERSION="30"
SEPOLICY_FILENAME="policy.${SELINUX_VERSION}"

S="${WORKDIR}"

src_compile() {
	# Files under $SEPATH are built by android-container-* in DEPEND.
	local SEPATH="${SYSROOT}/etc/selinux/intermediates/"
	if use cheets_local_img; then
		# Currently, developers are responsible to put the final policy
		# into files directory of android-container-pi when
		# cheets_local_img use flag is set.
		# Simply copying it here.
		cp "${SEPATH}/sepolicy" "${SEPOLICY_FILENAME}"
	else
		# -M Build MLS policy.
		# -G expand and remove auto-generated attributes.
		# -N ignore neverallow rules (checked during Android build)
		# -m allow multiple declaration (combination of rules of multiple source)
		secilc "${SEPATH}/plat_sepolicy.cil" -M true -G -N -m -c "${SELINUX_VERSION}" \
			"${SEPATH}/mapping.cil" -o "${SEPOLICY_FILENAME}" \
			"${SEPATH}/plat_pub_versioned.cil" \
			"${SEPATH}/vendor_sepolicy.cil" \
			-f /dev/null || die "fail to build sepolicy"
	fi
}

src_install() {
	# TODO(fqj): remove the if.
	if [[ ! -f "${SYSROOT}/etc/selinux/arc/policy/${SEPOLICY_FILENAME}" ]]; then
		insinto /etc/selinux/arc/policy
		doins "${SEPOLICY_FILENAME}"
	else
		ewarn "${SEPOLICY_FILENAME} already existed in ${SYSROOT}."
	fi
}


