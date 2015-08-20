# Copyright 2014 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=4
CROS_WORKON_COMMIT="85d0aac0bd3311630918168f039d76a2f53e690a"
CROS_WORKON_TREE="82cb3ec6f576b7afb3ee5f77c266129390ba70b7"
CROS_WORKON_PROJECT="chromiumos/third_party/autotest"
CROS_WORKON_LOCALNAME=../third_party/autotest
CROS_WORKON_SUBDIR=files

inherit cros-workon autotest

DESCRIPTION="Graphics autotests"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""

LICENSE="GPL-2"
SLOT="0"
KEYWORDS="*"
# Enable autotest by default.
IUSE="+autotest ozone"

RDEPEND="
	!<chromeos-base/autotest-tests-0.0.3
	chromeos-base/autotest-deps-glbench
	chromeos-base/autotest-deps-graphics
	tests_graphics_GLMark2? ( chromeos-base/autotest-deps-glmark2 )
	tests_graphics_SanAngeles? ( media-libs/waffle )
	tests_graphics_Sanity? ( x11-libs/libdrm )
"
DEPEND="${RDEPEND}"

IUSE_TESTS="
	!ozone? (
		+tests_graphics_Piglit
		+tests_graphics_PiglitBVT
	)
	ozone? (
		+tests_graphics_dEQP
	)
	+tests_graphics_GLAPICheck
	+tests_graphics_GLBench
	+tests_graphics_GLMark2
	+tests_graphics_GpuReset
	+tests_graphics_KernelMemory
	+tests_graphics_LibDRM
	+tests_graphics_PerfControl
	+tests_graphics_SanAngeles
	+tests_graphics_Sanity
	+tests_graphics_SyncControlTest
	+tests_graphics_VTSwitch
"

IUSE="${IUSE} ${IUSE_TESTS}"

AUTOTEST_FILE_MASK="*.a *.tar.bz2 *.tbz2 *.tgz *.tar.gz"
