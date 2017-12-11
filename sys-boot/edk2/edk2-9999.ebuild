# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

# Change this version number when any change is made to patches/files under
# edk2 and an auto-revbump is required.
# VERSION=REVBUMP-0.0.1

EAPI=4
CROS_WORKON_PROJECT="chromiumos/third_party/edk2"
CROS_WORKON_LOCALNAME="edk2"

inherit toolchain-funcs cros-workon coreboot-sdk

DESCRIPTION="EDK II firmware development environment for the UEFI and PI specifications."
HOMEPAGE="https://github.com/tianocore/edk2"

LICENSE="BSD"
SLOT="0"
KEYWORDS="~*"
IUSE="fwserial"

RDEPEND=""
DEPEND="
	sys-boot/coreboot
"

PATCHES=(
	"${FILESDIR}/00_BaseTools_Scripts.patch"
	"${FILESDIR}/01_CorebootPayloadPkg_pcinoenum.patch"
	"${FILESDIR}/02_CorebootPayloadPkg_bds.patch"
	"${FILESDIR}/03_Library_EndofDXE.patch"
	"${FILESDIR}/04_CorebootPayloadPkg_addps2.patch"
	"${FILESDIR}/06_CorebootPayloadPkg_keep_cb_table.patch"
)

BUILDTYPE=DEBUG # DEBUG or RELEASE

create_cbfs() {
	local CROS_FIRMWARE_IMAGE_DIR="/firmware"
	local CROS_FIRMWARE_ROOT="${SYSROOT%/}${CROS_FIRMWARE_IMAGE_DIR}"
	local oprom=$(echo "${CROS_FIRMWARE_ROOT}"/pci????,????.rom)
	local cbfs=tianocore.cbfs
	local cbfs_size=$(( 2 * 1024 * 1024 ))
	local bootblock="${T}/bootblock"

	_cbfstool() { set -- cbfstool "$@"; echo "$@"; "$@" || die "'$*' failed"; }

	# Create empty CBFS
	_cbfstool ${cbfs} create -s ${cbfs_size} -m x86
	# Add tianocore binary to CBFS. FIXME needs newer cbfstool
	_cbfstool ${cbfs} add-payload \
			-f Build/CorebootPayloadPkgX64/${BUILDTYPE}_CBSDK/FV/UEFIPAYLOAD.fd \
			-n payload -c lzma
	# Add VGA option rom to CBFS
	if [ -r "${oprom}" ]; then
		_cbfstool ${cbfs} add -f "${oprom}" -n $(basename "${oprom}") -t optionrom
	fi
	# Print CBFS inventory
	_cbfstool ${cbfs} print
}

src_prepare() {
	if ! use fwserial; then
		PATCHES+=("${FILESDIR}/05_CorebootPayloadPkg_noserial.patch")
	fi

	epatch "${PATCHES[@]}"
}

src_compile() {
	. ./edksetup.sh
	cat ${FILESDIR}/tools-add.txt >> Conf/tools_def.txt
	(cd BaseTools/Source/C && ARCH=${ARCHITECTURE} emake -j1)
	export COREBOOT_SDK_PREFIX_arm COREBOOT_SDK_PREFIX_arm64 COREBOOT_SDK_PREFIX_x86_32 COREBOOT_SDK_PREFIX_x86_64
	build -t CBSDK -a IA32 -a X64 -b ${BUILDTYPE} \
			-p CorebootPayloadPkg/CorebootPayloadPkgIa32X64.dsc
	create_cbfs
}

src_install() {
	insinto /firmware
	doins tianocore.cbfs
}
