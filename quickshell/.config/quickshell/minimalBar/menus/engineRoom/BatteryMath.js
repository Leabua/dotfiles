function pickBattery(devices, fallback) {
    for (const device of devices) {
        if (device.ready && device.isPresent && device.isLaptopBattery)
            return device;
    }
    return fallback;
}

// Energy is in Wh. Give stepped firmware readings at least 30 seconds to settle.
function rateFromEnergy(start, end, elapsedMs, charging) {
    if (!Number.isFinite(start) || !Number.isFinite(end) || !Number.isFinite(elapsedMs) || start < 0 || end < 0 || elapsedMs < 30000)
        return 0;
    const delta = charging ? end - start : start - end;
    return delta > 0 ? delta * 3600000 / elapsedMs : 0;
}

function remainingSeconds(energy, capacity, rate, charging) {
    if (!Number.isFinite(energy) || !Number.isFinite(capacity) || !Number.isFinite(rate) || energy < 0 || capacity <= 0 || rate <= 0)
        return 0;
    return Math.max(0, charging ? capacity - energy : energy) / rate * 3600;
}

function healthPercent(value) {
    if (!Number.isFinite(value) || value < 0)
        return -1;
    return Math.round(value <= 1 ? value * 100 : value);
}
