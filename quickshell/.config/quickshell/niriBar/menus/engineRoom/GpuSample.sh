#!/bin/sh

# Select one i915 device so every field refers to the same GPU. Keep missing
# fields in place; an absent sensor must never shift the following values.
for card in /sys/class/drm/card[0-9]*; do
    [ -f "$card/gt_act_freq_mhz" ] || continue
    printf '%s\n' "$card"
    for field in power/rc6_residency_ms gt_act_freq_mhz gt_max_freq_mhz power/rc6_enable; do
        value=$(cat "$card/$field" 2>/dev/null)
        printf '%s\n' "${value:--1}"
    done
    cut -d ' ' -f 1 /proc/uptime
    exit
done
