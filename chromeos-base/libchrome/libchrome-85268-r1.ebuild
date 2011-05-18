# Copyright (c) 2011 The Chromium OS Authors. All rights reserved.
# Distributed under the terms of the GNU General Public License v2

EAPI=2

inherit cros-debug eutils toolchain-funcs

DESCRIPTION="Chrome base/ library extracted for use on Chrome OS"
HOMEPAGE="http://www.chromium.org/"
SRC_URI="http://commondatastorage.googleapis.com/chromeos-localmirror/distfiles/${PN}-svn-${PV}.tar.gz"
LICENSE="BSD"
SLOT="0"
KEYWORDS="amd64 arm x86"

RDEPEND="dev-libs/glib
	dev-libs/libevent
	dev-libs/nss
	x11-libs/gtk+"
DEPEND="${RDEPEND}
	dev-cpp/gtest"

src_prepare() {
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
	doins "${S}/files/base/third_party/icu/icu_utf.h"

	insinto "/usr/include/base/third_party/nspr"
	doins "${S}/files/base/third_party/nspr/prtime.h"

	insinto "/usr/include/base/third_party/valgrind"
	doins "${S}/files/base/third_party/valgrind/valgrind.h"

	insinto "/usr/include/base/third_party/dynamic_annotations"
	doins "${S}/files/base/third_party/dynamic_annotations/dynamic_annotations.h"

	insinto "/usr/include/base/"
	doins "${S}/files/base/at_exit.h"
	doins "${S}/files/base/base_api.h"
	doins "${S}/files/base/atomic_ref_count.h"
	doins "${S}/files/base/atomic_sequence_num.h"
	doins "${S}/files/base/atomicops.h"
	doins "${S}/files/base/atomicops_internals_arm_gcc.h"
	doins "${S}/files/base/atomicops_internals_x86_gcc.h"
	doins "${S}/files/base/base_switches.h"
	doins "${S}/files/base/basictypes.h"
	doins "${S}/files/base/bind.h"
	doins "${S}/files/base/bind_helpers.h"
	doins "${S}/files/base/bind_internal.h"
	doins "${S}/files/base/callback.h"
	doins "${S}/files/base/callback_internal.h"
	doins "${S}/files/base/callback_old.h"
	doins "${S}/files/base/command_line.h"
	doins "${S}/files/base/compiler_specific.h"
	doins "${S}/files/base/eintr_wrapper.h"
	doins "${S}/files/base/environment.h"
	doins "${S}/files/base/file_descriptor_posix.h"
	doins "${S}/files/base/file_path.h"
	doins "${S}/files/base/file_util.h"
	doins "${S}/files/base/file_util_deprecated.h"
	doins "${S}/files/base/float_util.h"
	doins "${S}/files/base/gtest_prod_util.h"
	doins "${S}/files/base/hash_tables.h"
	doins "${S}/files/base/lazy_instance.h"
	doins "${S}/files/base/logging.h"
	doins "${S}/files/base/message_loop.h"
	doins "${S}/files/base/message_loop_proxy.h"
	doins "${S}/files/base/message_pump.h"
	doins "${S}/files/base/message_pump_libevent.h"
	doins "${S}/files/base/message_pump_glib.h"
	doins "${S}/files/base/native_library.h"
	doins "${S}/files/base/observer_list.h"
	doins "${S}/files/base/pickle.h"
	doins "${S}/files/base/platform_file.h"
	doins "${S}/files/base/port.h"
	doins "${S}/files/base/rand_util.h"
	doins "${S}/files/base/safe_strerror_posix.h"
	doins "${S}/files/base/scoped_ptr.h"
	doins "${S}/files/base/stl_util-inl.h"
	doins "${S}/files/base/string16.h"
	doins "${S}/files/base/stringprintf.h"
	doins "${S}/files/base/string_piece.h"
	doins "${S}/files/base/string_tokenizer.h"
	doins "${S}/files/base/string_number_conversions.h"
	doins "${S}/files/base/string_split.h"
	doins "${S}/files/base/string_util.h"
	doins "${S}/files/base/string_util_posix.h"
	doins "${S}/files/base/task.h"
	doins "${S}/files/base/template_util.h"
	doins "${S}/files/base/time.h"
	doins "${S}/files/base/tracked.h"
	doins "${S}/files/base/tuple.h"
	doins "${S}/files/base/utf_string_conversion_utils.h"
	doins "${S}/files/base/utf_string_conversions.h"
	doins "${S}/files/base/values.h"

	insinto "/usr/include/base/debug"
	doins "${S}/files/base/debug/debugger.h"
	doins "${S}/files/base/debug/stack_trace.h"
	doins "${S}/files/base/debug/trace_event.h"

	insinto "/usr/include/base/json"
	doins "${S}/files/base/json/json_reader.h"
	doins "${S}/files/base/json/json_writer.h"
	doins "${S}/files/base/json/string_escape.h"

	insinto "/usr/include/base/memory"
	doins "${S}/files/base/memory/raw_scoped_refptr_mismatch_checker.h"
	doins "${S}/files/base/memory/ref_counted.h"
	doins "${S}/files/base/memory/scoped_temp_dir.h"
	doins "${S}/files/base/memory/scoped_ptr.h"
	doins "${S}/files/base/memory/scoped_vector.h"
	doins "${S}/files/base/memory/singleton.h"
	doins "${S}/files/base/memory/weak_ptr.h"

	insinto "/usr/include/base/synchronization"
	doins "${S}/files/base/synchronization/condition_variable.h"
	doins "${S}/files/base/synchronization/lock.h"
	doins "${S}/files/base/synchronization/lock_impl.h"
	doins "${S}/files/base/synchronization/waitable_event.h"

	insinto "/usr/include/base/threading"
	doins "${S}/files/base/threading/non_thread_safe.h"
	doins "${S}/files/base/threading/non_thread_safe_impl.h"
	doins "${S}/files/base/threading/platform_thread.h"
	doins "${S}/files/base/threading/thread.h"
	doins "${S}/files/base/threading/thread_checker.h"
	doins "${S}/files/base/threading/thread_checker_impl.h"
	doins "${S}/files/base/threading/thread_local.h"
	doins "${S}/files/base/threading/thread_local_storage.h"
	doins "${S}/files/base/threading/thread_restrictions.h"
	doins "${S}/files/base/threading/thread_collision_warner.h"

	insinto "/usr/include/build"
	doins "${S}/files/build/build_config.h"

}
