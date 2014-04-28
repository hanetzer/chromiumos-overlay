#!/bin/bash
# Copyright (c) 2012 The Chromium OS Authors. All rights reserved.
# Use of this source code is governed by a BSD-style license that can be
# found in the LICENSE file.

# Quick hack to monitor thermals on Exynos based platforms. Since we only have
# passive cooling, the only thing we can do is limit CPU temp.
#
# TODO: validate readings from hwmon sensors by comparing to each other.
#       We should ignore readings with more than 10C differences from peers.

PROG=$(basename "$0")
PLATFORM=$(mosys platform name)

debug=0
if [[ "$1x" == '-dx' ]]; then
  debug=1
fi

# if PLATFORM is empty, try again
for i in $(seq 5); do
  if [[ -n "${PLATFORM}" ]]; then
    break
  fi
  sleep 1
  logger -t "${PROG}" "Unable to get platform name, retry ${i} of 5"
  PLATFORM=$(mosys platform name)
done
# Log the platform
logger -t "${PROG}" "Platform ${PLATFORM}"

# Use the same thermal settings for Skate and Spring
if [[ "${PLATFORM}" == "Skate" ]]; then
  PLATFORM="Spring"
fi

# cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_available_frequencies
# 1700000 1600000 1500000 ...
if [[ "${PLATFORM}" == "Pit" ]]; then
  PIT_MAX_FREQ=$(cat /sys/devices/system/cpu/cpu0/cpufreq/cpuinfo_max_freq)
  if [[ ${PIT_MAX_FREQ} -gt 1800000 ]]; then
    EXYNOS5_CPU_FREQ=(1900000 1600000 1400000 1200000 1100000 900000 800000
      650000 300000)
  else
    EXYNOS5_CPU_FREQ=(1800000 1600000 1400000 1200000 1100000 900000 800000
      650000 300000)
  fi

  # Ares has 5 tmu sensors for cpu and gpu
  cpu_tpath="/sys/class/thermal/thermal_zone[0-4]"

elif [[ "${PLATFORM}" == "Pi" ]]; then
  EXYNOS5_CPU_FREQ=(2000000 1800000 1400000 1200000 1100000 900000 800000
      650000 300000)
  # Ares2 has also 5 tmu sensors for cpu and gpu
  cpu_tpath="/sys/class/thermal/thermal_zone[0-4]"

else
  EXYNOS5_CPU_FREQ=(1700000 1600000 1500000 1400000 1300000 1200000 1100000
      1000000 900000 800000 700000 600000 500000 400000 300000 200000)

  cpu_tpath="/sys/class/thermal/thermal_zone0"
fi

# CPU temperature threshold we start limiting CPU Freq
# TODO(crosbug.com/p/17658) HACK: remove once characterized
if [[ "${PLATFORM}" == "Spring" ]]; then
  : $(( t0 = $(cat "${cpu_tpath}"/trip_point_0_temp) / 1000 - 1 ))
  : $(( t1 = $(cat "${cpu_tpath}"/trip_point_1_temp) / 1000 - 1 ))

  CPU_TEMP_MAP=(${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0}
      ${t1})
  HWMON_TEMP_MAP=(${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t0} ${t1})
elif [[ "${PLATFORM}" == "Pit" ]]; then
  # Just relying on thermistors under 80 dgree C
  CPU_TEMP_MAP=(80 81 82 83 84 85 86 90 100)
  # 50 -> 1.6Ghz(A15), 52 -> 1.2 Ghz(A15)
  HWMON_TEMP_MAP=(49 50 51 52 53 54 70 80 90)
elif [[ "${PLATFORM}" == "Pi" ]]; then
  # Just relying on thermistors under 80 dgree C
  CPU_TEMP_MAP=(80 81 82 83 84 85 86 90 100)
  # 50 -> 1.8Ghz(A15), 52 -> 1.2 Ghz(A15)
  HWMON_TEMP_MAP=(49 50 51 52 53 54 70 80 90)
else
  # 63 -> 1.4Ghz, 69 -> 1.1 Ghz, 75 -> 800Mhz
  CPU_TEMP_MAP=(60 61 62 63 65 67 68 69 71 73 75)
  # 52 -> 1.4Ghz, 60->1.1Ghz, 65->800Mhz
  HWMON_TEMP_MAP=(49 50 51 52 55 58 60 62 64 65)
fi

# We don't quote cpu_tpath because it might have wildcards that
# we want to expand into the array.
DAISY_CPU_TEMP=(${cpu_tpath}/temp)


#######################################
# Find all hwmon thermal sensors.
#
# It's OK if there are none.
#
# Globals:
#   HWMON_TEMP_SENSOR
# Arguments:
#   None
# Returns:
#   None
#######################################
find_hwmon_sensors() {
  local hwmon_dir
  local sensor

  HWMON_TEMP_SENSOR=()
  for hwmon_dir in /sys/class/hwmon/hwmon*/device; do
    for sensor in "${hwmon_dir}"/temp*_input; do
      if [[ -r "${sensor}" ]]; then
        HWMON_TEMP_SENSOR+=( "${sensor}" )
      fi
    done
  done
}

read_temp() {
  local sensor="$1"
  local t

  if [[ -r "${sensor}" ]]; then
    # treat $1 as numeric and convert to C
    local raw
    raw=$(cat "${sensor}" 2> /dev/null)
    if [[ -z "${raw}" ]]; then
      return 1
    fi
    : $(( t = raw / 1000 ))

    # valid CPU range is 25 to 125C. Give hwmon sensors more range.
    if  [[ ${t} -lt 15 || ${t} -gt 140 ]]; then
      # do nothing - ignore the reading
      logger -t "${PROG}" "ERROR: temp ${t} out of range"
      return 1
    fi

    # WARNING: if valid temps are ever outside [0, 255] this return will not
    # work like you think...
    return ${t}
  fi

  logger -t "${PROG}" "ERROR: could not read temp from ${sensor}"
  # sleep so script isn't respawned so quickly and spew
  sleep 10
  exit 1
}

lookup_freq_idx() {
  local t=$1
  shift
  local temp_map=("$@")
  local i=0
  local n=${#temp_map[@]}

  while [[ ${i} -lt ${n} ]]; do
    if [[ ${t} -le ${temp_map[i]} ]]; then
      return ${i}
    fi
    : $(( i += 1 ))
  done

  # we ran off the end of the map. Use slowest speed in that map.
  logger -t "${PROG}" "ERROR: temp ${t} not in temp_map"
  : $(( i = n - 1 ))
  return ${i}
}

# Thermal loop steps
set_max_cpu_freq() {
  local max_freq=$1
  local cpu

  for cpu in /sys/devices/system/cpu/cpu?/cpufreq; do
    echo "${max_freq}" > "${cpu}/scaling_max_freq"
  done
}

# Only update cpu Freq if we need to change.
last_cpu_freq=0

find_hwmon_sensors

# Get frequency throttling set by the firmware to limit power draw
power_cap=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_max_freq)
logger -t "${PROG}" "CPU max freq set to $((${power_cap} / 1000)) Mhz at boot"

# Print power info on first pass, then every other 4 passes.
power_info_pass=4
while true; do
  max_cpu_freq=${EXYNOS5_CPU_FREQ[0]}

  # read the list of temp sensors
  cpu_temps=()
  for sensor in "${DAISY_CPU_TEMP[@]}"; do
    read_temp "${sensor}"
    cpu_temp=$?

    lookup_freq_idx ${cpu_temp} "${CPU_TEMP_MAP[@]}"
    f=$?
    cpu_freq=${EXYNOS5_CPU_FREQ[f]}

    if [[ ${cpu_freq} -gt 0 && ${cpu_freq} -lt ${max_cpu_freq} ]]; then
      max_cpu_freq=${cpu_freq}
    fi

    # record temps for (DEBUG and) validation later
    cpu_temps+=(${cpu_temp})
  done

  temps=()
  if [[ ${#HWMON_TEMP_SENSOR[@]} -gt 0 ]]; then
    for sensor in "${HWMON_TEMP_SENSOR[@]}"; do
      read_temp "${sensor}"
      temp=$?

      # record temps for (DEBUG and) validation later
      temps+=(${temp})
    done

    # TODO validate hwmon sensor readings.
    # we should reject anything that is more than 5C off from all others.
    max_temp=${temps[0]}
    for k in "${temps[@]}"; do
      if [[ ${max_temp} -lt ${k} ]]; then
        max_temp=${k}
      fi
    done

    lookup_freq_idx ${max_temp} "${HWMON_TEMP_MAP[@]}"
    f=$?
    therm_cpu_freq=${EXYNOS5_CPU_FREQ[f]}

    # we have a valid reading and it's lower than others
    if [[ ${therm_cpu_freq} -gt 0 &&
          ${therm_cpu_freq} -lt ${max_cpu_freq} ]]; then
      max_cpu_freq=${therm_cpu_freq}
    fi
  fi

  # Handle the power cap if the battery is too low.
  if [[ "${PLATFORM}" == "Spring" && ${power_cap} -lt ${EXYNOS5_CPU_FREQ[0]} ]]
  then
    power_supply="/sys/class/power_supply/sbs-*-000b"
    energy_now=$(cat ${power_supply}/energy_now)
    energy_full=$(cat ${power_supply}/energy_full)
    battery_percent=$(( energy_now * 100 / energy_full ))

    # if we have charged, restore the full CPU frequency range
    if [[ ${battery_percent} -gt 5 ]]; then
      power_cap=${EXYNOS5_CPU_FREQ[0]}
      logger -t "${PROG}" "Freq cap reset to $((${power_cap} / 1000)) Mhz"
    fi
    # force to stay below the cap set to limit total power draw
    if [[ ${max_cpu_freq} -gt ${power_cap} ]]; then
      max_cpu_freq=${power_cap}
    fi
  fi

  if [[ debug -gt 0 ]]; then
    echo $(date +"%H:%M:%S") , \
        $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq), \
        ${max_cpu_freq}, ${cpu_temp}, ${temps[@]}
  fi

  if [[ ${last_cpu_freq} -ne ${max_cpu_freq} ]]; then
    last_cpu_freq=${max_cpu_freq}
    logger -t "${PROG}" "Max CPU Freq set to ${max_cpu_freq} \
(Celsius: ${cpu_temps[*]} / ${temps[*]})"
    set_max_cpu_freq ${max_cpu_freq}
  fi

  if [[ "${PLATFORM}" == "Spring" ]]; then
    # Report charger type.
    if [[ "${power_info_pass}" == "4" ]]; then
      power_info_pass=0
      # Charger type is 4-byte hex, but metric_client accepts only
      # decimal.  Sparse histograms use 32-bit bucket indices, but
      # the 64-bit values produced by awk are truncated correctly.
      charger_type=$(($(ectool powerinfo | awk \
        '/USB Device Type:/ { print $4; }')))
      if [[ -n "${charger_type}" ]]; then
        metrics_client -s Platform.SpringChargerType ${charger_type}
      fi
    fi
    : $(( power_info_pass += 1 ))
  fi
  sleep 15
done
