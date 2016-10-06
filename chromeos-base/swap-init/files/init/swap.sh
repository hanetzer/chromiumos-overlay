#!/bin/sh
# Copyright 2016 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Set margin for low-memory notifier (for tab discarder)
# Configure and start swap if SWAP_ENABLE_FILE exists.
# SWAP_ENABLE_FILE may optionally contain the uncompressed swap size (in Mb).
# Otherwise it is set to 1.5 times total RAM.
#
# To start swap, create file /home/chronos/.swap_enabled and run
# "[systemctl] start swap" or reboot.  To stop swap, remove the file and reboot.

SWAP_ENABLE_FILE=/home/chronos/.swap_enabled
HIST_MIN=100
HIST_MAX=10000
HIST_BUCKETS=50
HIST_ARGS="${HIST_MIN} ${HIST_MAX} ${HIST_BUCKETS}"
JOB="swap"

valid_size() {
  local size="$1"

  case "${size}" in
  500|1000|2000|3000|4000|4500|6000)
    return 0
    ;;
  *)
    # Reject all other values.
    return 1
    ;;
  esac
}

start() {
  local mem_total
  # Extract second field of MemTotal entry in /proc/meminfo.
  # NOTE: this could be done with "read", "case", and a function
  # that sets ram=$2, for a savings of about 3ms on an Alex.
  mem_total=$(awk '/MemTotal/ { print $2; }' /proc/meminfo)
  if [ -z "${mem_total}" ]; then
    logger -t "${JOB}" "could not get MemTotal"
    exit 1
  fi

  local margin
  # compute fraction of total RAM used for low-mem margin.  The fraction is
  # given in bips.  A "bip" or "basis point" is 1/100 of 1%.
  MARGIN_BIPS=520
  margin=$(( mem_total / 1000 * MARGIN_BIPS / 10000 ))  # MB
  if [ -n "${MIN_LOW_MEMORY_MARGIN}" ] && \
     [ "${margin}" -lt "${MIN_LOW_MEMORY_MARGIN}" ]; then
    margin=${MIN_LOW_MEMORY_MARGIN}
  fi
  # set the margin
  echo "${margin}" > /sys/kernel/mm/chromeos-low_mem/margin
  logger -t "${JOB}" "setting low-mem margin to ${margin} MB"

  # Allocate zram (compressed ram disk) for swap.
  # SWAP_ENABLE_FILE contains the zram size in MB.
  # Empty or missing SWAP_ENABLE_FILE means use default size.
  # 0 size means do not enable zram.
  # Calculations are in Kb to avoid 32 bit overflow.

  local requested_size_mb size_kb
  # For security, only read first few bytes of SWAP_ENABLE_FILE.
  requested_size_mb="$(head -c 4 "${SWAP_ENABLE_FILE}")" || :
  if [ -z "${requested_size_mb}" ]; then
    # Default multiplier for zram size. (Shell math is integer only.)
    local multiplier="3 / 2"
    # On ARM32 / ARM64 CPUs graphics memory is not reclaimable, so use a smaller
    # size.
    if arch | grep -qiE "arm|aarch64"; then
      multiplier="1"
    fi
    # The multiplier may be an expression, so it MUST use the $ expansion.
    size_kb=$(( mem_total * ${multiplier} ))
  elif [ "${requested_size_mb}" = "0" ]; then
    metrics_client Platform.CompressedSwapSize 0 ${HIST_ARGS}
    exit 0
  elif ! valid_size "${requested_size_mb}"; then
    logger -t "${JOB}" "invalid value ${requested_size_mb} for swap"
    metrics_client Platform.CompressedSwapSize 0 ${HIST_ARGS}
    exit 1
  else
    size_kb=$(( requested_size_mb * 1024 ))
  fi

  # Load zram module.  Ignore failure (it could be compiled in the kernel).
  modprobe zram || logger -t "${JOB}" "modprobe zram failed (compiled?)"

  logger -t "${JOB}" "setting zram size to ${size_kb} Kb"
  # Approximate the kilobyte to byte conversion to avoid issues
  # with 32-bit signed integer overflow.
  echo "${size_kb}000" >/sys/block/zram0/disksize ||
      logger -t "${JOB}" "failed to set zram size"
  mkswap /dev/zram0 || logger -t "${JOB}" "mkswap /dev/zram0 failed"
  # Swapon may fail because of races with other programs that inspect all
  # block devices, so try several times.
  local tries=0
  while [ ${tries} -le 10 ]; do
    swapon /dev/zram0 && break
    : $(( tries += 1 ))
    logger -t "${JOB}" "swapon /dev/zram0 failed, try ${tries}"
    sleep 0.1
  done

  local swaptotalkb
  swaptotalkb=$(awk '/SwapTotal/ { print $2 }' /proc/meminfo)
  metrics_client Platform.CompressedSwapSize \
                $(( swaptotalkb / 1024 )) ${HIST_ARGS}
}

stop() {
  logger -t "${JOB}" "turning off swap"

  # This is safe to call even if no swap is turned on.
  swapoff -av

  # When we start up, we try to configure zram0, but it doesn't like to
  # be reconfigured on the fly.  Reset it so we can changes its params.
  echo 1 > /sys/block/zram0/reset || :
}

status() {
  # Show general swap info first.
  cat /proc/swaps

  # Then spam various zram settings.
  local dir="/sys/block/zram0"
  printf '\n%s:\n' "${dir}"
  cd "${dir}"
  grep -s '^' * || :
}

enable() {
  local size="$1"

  # Size of 0 is special for enable.  We interpret this to be automatic.
  # Don't confuse this with setting 0 in the file in the disable code path.
  if [ "${size}" = "0" ]; then
    size=""

    logger -t "${JOB}" "enabling swap via config with automatic size"
  else
    if ! valid_size "${size}"; then
      echo "${JOB}: error: invalid size: ${size}" >&2
      exit 1
    fi

    logger -t "${JOB}" "enabling swap via config with size ${size}"
  fi

  # Delete it first in case the permissions have gotten ... weird.
  rm -f "${SWAP_ENABLE_FILE}"
  echo "${size}" > "${SWAP_ENABLE_FILE}"
}

disable() {
  logger -t "${JOB}" "disabling swap via config"
  # Delete it first in case the permissions have gotten ... weird.
  rm -f "${SWAP_ENABLE_FILE}"
  echo "0" > "${SWAP_ENABLE_FILE}"
}

usage() {
  cat <<EOF
Usage: $0 <start|stop|status|enable <size>|disable>

Start or stop the use of the compressed swap file.

The start phase is normally invoked by init during boot, but we never run the
stop phase when shutting down (since there's no point).  The stop phase is used
by developers via debugd to restart things on the fly.

Disabling things changes the config, but doesn't actually turn on/off swap.
EOF
  exit $1
}

main() {
  set -e

  if [ $# -lt 1 ]; then
    usage 1
  fi

  # Make sure the subcommand is one we know.
  local cmd="$1"
  shift
  case "${cmd}" in
  start|stop|status|disable)
    if [ $# -ne 0 ]; then
      usage 1
    fi
    ;;
  enable)
    if [ $# -ne 1 ]; then
      usage 1
    fi
    ;;
  *)
    usage 1
    ;;
  esac

  # Just call the func requested directly.
  ${cmd} "$@"
}
main "$@"
