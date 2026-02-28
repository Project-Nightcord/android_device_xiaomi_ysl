#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017-2020 The LineageOS Project
#
# SPDX-License-Identifier: Apache-2.0
#

function blob_fixup() {
    case "${1}" in
        vendor/lib/libarcsoft_high_dynamic_range.so \
        | vendor/lib/libremosaic_wrapper.so \
        | vendor/lib/libremosaiclib.so \
        | vendor/lib/libmmcamera_hdr_gb_lib.so )
            "${PATCHELF_0_17_2}" --replace-needed "libstdc++.so" "libstdc++_vendor.so" "${2}"
            ;;
        vendor/lib/libmmcamera_tuning.so)
            "${PATCHELF_0_17_2}" --remove-needed "libmm-qcamera.so" "${2}"
            ;;
        vendor/lib/libgf_hal.so)
            # NOP gf_hal_test_notify_acquired_info()
            "${SIGSCAN}" -p "00 c6 8f e2 4a ca 8c e2 b0 fa bc e5" -P "00 c6 8f e2 1f 20 03 d5 b0 fa bc e5" -f "${2}"
            "${SIGSCAN}" -p "78 47 c0 46 00 c0 9f e5 0f f0 8c e0 e0 37 fc ff" -P "78 47 c0 46 1f 20 03 d5 0f f0 8c e0 e0 37 fc ff" -f "${2}"
            ;;
        vendor/lib64/hw/fingerprint.goodix.default.so)
            "${PATCHELF_0_17_2}" --replace-needed "libvendor.goodix.hardware.fingerprint@1.0.so" "vendor.goodix.hardware.fingerprint@1.0.so" "${2}"
            ;;
        vendor/lib64/libvendor.goodix.hardware.fingerprint@1.0-service.so)
            "${PATCHELF_0_17_2}" --remove-needed "libprotobuf-cpp-lite.so" "${2}"
            "${PATCHELF_0_17_2}" --replace-needed "libvendor.goodix.hardware.fingerprint@1.0.so" "vendor.goodix.hardware.fingerprint@1.0.so" "${2}"
            ;;
        vendor/lib64/hw/consumerir.msm8953.so)
            sed -i "s|/dev/spidev6.1|/dev/spidev5.1|g" "${2}"
            ;;
    esac
}

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

export DEVICE=ysl
export DEVICE_COMMON=mithorium-common
export VENDOR=xiaomi

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"
