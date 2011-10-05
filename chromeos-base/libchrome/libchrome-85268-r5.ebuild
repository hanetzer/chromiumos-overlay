# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2
CROS_WORKON_COMMIT="a41a2e70fea956b97e4e2327b424be0708c49420"
CROS_WORKON_PROJECT="chromium/src/base"

KEYWORDS="amd64 arm x86"

inherit cros-workon cros-debug toolchain-funcs

DESCRIPTION="Chrome base/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI=""
LICENSE="BSD"
SLOT="0"
IUSE="cros_host"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
	x11-libs/gtk+"
DEPEND="${RDEPEND}
	dev-cpp/gtest
	cros_host? ( dev-util/scons )"

src_prepare() {
	ln -s "${S}" "${WORKDIR}/base" &> /dev/null

	mkdir -p "${WORKDIR}/build"
	cp -p "${FILESDIR}/build_config.h" "${WORKDIR}/build/." || die

	cp -p "${FILESDIR}/SConstruct" "${S}" || die
	epatch "${FILESDIR}/gtest_include_path_fixup.patch" || die "libchrome prepare failed."
}

src_compile() {
	tc-export CC CXX AR RANLIB LD NM PKG_CONFIG
	cros-debug-add-NDEBUG
	export CCFLAGS="$CFLAGS"

	scons || die "third_party/chrome compile failed."
}


src_install() {
	dodir "/usr/lib"
	dodir "/usr/include/base"
	dodir "/usr/include/base/debug"
	dodir "/usr/include/base/json"
	dodir "/usr/include/base/memory"
	dodir "/usr/include/base/synchronization"
	dodir "/usr/include/base/threading"
	dodir "/usr/include/base/third_party/dynamic_annotations"
	dodir "/usr/include/base/third_party/icu"
	dodir "/usr/include/base/third_party/nspr"
	dodir "/usr/include/base/third_party/valgrind"
	dodir "/usr/include/build"

	insopts -m0644
	insinto "/usr/lib"
	doins "${S}/libbase.a"

	insinto "/usr/include/base/third_party/icu"
	doins "${S}/third_party/icu/icu_utf.h"

	insinto "/usr/include/base/third_party/nspr"
	doins "${S}/third_party/nspr/prtime.h"

	insinto "/usr/include/base/third_party/valgrind"
	doins "${S}/third_party/valgrind/valgrind.h"

	insinto "/usr/include/base/third_party/dynamic_annotations"
	doins "${S}/third_party/dynamic_annotations/dynamic_annotations.h"

	insinto "/usr/include/base/"
	doins "${S}/at_exit.h"
	doins "${S}/base_api.h"
	doins "${S}/atomic_ref_count.h"
	doins "${S}/atomic_sequence_num.h"
	doins "${S}/atomicops.h"
	doins "${S}/atomicops_internals_arm_gcc.h"
	doins "${S}/atomicops_internals_x86_gcc.h"
	doins "${S}/base_switches.h"
	doins "${S}/basictypes.h"
	doins "${S}/bind.h"
	doins "${S}/bind_helpers.h"
	doins "${S}/bind_internal.h"
	doins "${S}/callback.h"
	doins "${S}/callback_internal.h"
	doins "${S}/callback_old.h"
	doins "${S}/command_line.h"
	doins "${S}/compiler_specific.h"
	doins "${S}/eintr_wrapper.h"
	doins "${S}/environment.h"
	doins "${S}/file_descriptor_posix.h"
	doins "${S}/file_path.h"
	doins "${S}/file_util.h"
	doins "${S}/file_util_deprecated.h"
	doins "${S}/float_util.h"
	doins "${S}/gtest_prod_util.h"
	doins "${S}/hash_tables.h"
	doins "${S}/lazy_instance.h"
	doins "${S}/logging.h"
	doins "${S}/message_loop.h"
	doins "${S}/message_loop_proxy.h"
	doins "${S}/message_pump.h"
	doins "${S}/message_pump_libevent.h"
	doins "${S}/message_pump_glib.h"
	doins "${S}/native_library.h"
	doins "${S}/observer_list.h"
	doins "${S}/pickle.h"
	doins "${S}/platform_file.h"
	doins "${S}/port.h"
	doins "${S}/rand_util.h"
	doins "${S}/safe_strerror_posix.h"
	doins "${S}/scoped_ptr.h"
	doins "${S}/stl_util-inl.h"
	doins "${S}/string16.h"
	doins "${S}/stringprintf.h"
	doins "${S}/string_piece.h"
	doins "${S}/string_tokenizer.h"
	doins "${S}/string_number_conversions.h"
	doins "${S}/string_split.h"
	doins "${S}/string_util.h"
	doins "${S}/string_util_posix.h"
	doins "${S}/task.h"
	doins "${S}/template_util.h"
	doins "${S}/time.h"
	doins "${S}/tracked.h"
	doins "${S}/tuple.h"
	doins "${S}/utf_string_conversion_utils.h"
	doins "${S}/utf_string_conversions.h"
	doins "${S}/values.h"

	insinto "/usr/include/base/debug"
	doins "${S}/debug/debugger.h"
	doins "${S}/debug/stack_trace.h"
	doins "${S}/debug/trace_event.h"

	insinto "/usr/include/base/json"
	doins "${S}/json/json_reader.h"
	doins "${S}/json/json_writer.h"
	doins "${S}/json/string_escape.h"

	insinto "/usr/include/base/memory"
	doins "${S}/memory/raw_scoped_refptr_mismatch_checker.h"
	doins "${S}/memory/ref_counted.h"
	doins "${S}/memory/scoped_temp_dir.h"
	doins "${S}/memory/scoped_ptr.h"
	doins "${S}/memory/scoped_vector.h"
	doins "${S}/memory/singleton.h"
	doins "${S}/memory/weak_ptr.h"

	insinto "/usr/include/base/synchronization"
	doins "${S}/synchronization/condition_variable.h"
	doins "${S}/synchronization/lock.h"
	doins "${S}/synchronization/lock_impl.h"
	doins "${S}/synchronization/waitable_event.h"

	insinto "/usr/include/base/threading"
	doins "${S}/threading/non_thread_safe.h"
	doins "${S}/threading/non_thread_safe_impl.h"
	doins "${S}/threading/platform_thread.h"
	doins "${S}/threading/thread.h"
	doins "${S}/threading/thread_checker.h"
	doins "${S}/threading/thread_checker_impl.h"
	doins "${S}/threading/thread_local.h"
	doins "${S}/threading/thread_local_storage.h"
	doins "${S}/threading/thread_restrictions.h"
	doins "${S}/threading/thread_collision_warner.h"

	insinto "/usr/include/build"
	doins "${WORKDIR}/build/build_config.h"

}
