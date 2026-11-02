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

function createTrend() {
    return { state: -1, energy: -1, time: 0, points: [] };
}

function trimPoints(points, now) {
    // Keep one transition before the ten-minute window as its baseline.
    while (points.length > 2 && points[1].time < now - 600000)
        points.shift();
    return points;
}

function recordEnergy(trend, energy, now, state) {
    if ((state !== 1 && state !== 2) || !Number.isFinite(energy) || energy < 0 || !Number.isFinite(now))
        return createTrend();
    // Discard intervals spanning a power-state change, suspend, or clock reset.
    if (trend.state !== state || now < trend.time || now - trend.time > 90000)
        return { state: state, energy: energy, time: now, points: [] };
    const points = trend.points.slice();
    if (energy !== trend.energy) {
        const delta = state === 1 ? energy - trend.energy : trend.energy - energy;
        if (delta < 0)
            points.length = 0;
        else
            points.push({ energy: energy, time: now });
    }
    // Only transitions are rate baselines: the first observation may be halfway
    // through a firmware step. Flat readings never restart the measurement.
    return { state: state, energy: energy, time: now, points: trimPoints(points, now) };
}

function trendRate(trend, now) {
    const points = trend.points;
    if (points.length < 2)
        return 0;
    const first = points[0];
    const last = points[points.length - 1];
    const elapsed = last.time - first.time;
    if (elapsed < 120000 || now < last.time)
        return 0;
    const stepInterval = elapsed / (points.length - 1);
    if (now - last.time > Math.max(300000, stepInterval * 2))
        return 0;
    return rateFromEnergy(first.energy, last.energy, elapsed, trend.state === 1);
}

function trendFromHistory(history, energy, capacity, percentage, state, now) {
    const empty = createTrend();
    if (!Array.isArray(history) || !Number.isFinite(energy) || energy < 0 || !Number.isFinite(capacity) || capacity <= 0 || !Number.isFinite(percentage) || (state !== 1 && state !== 2))
        return empty;
    const entries = history.filter(entry => Array.isArray(entry) && entry.length === 3 && entry.every(Number.isFinite) && entry[0] * 1000 <= now).sort((a, b) => a[0] - b[0]);
    const latest = entries[entries.length - 1];
    if (!latest || latest[2] !== state || Math.abs(latest[1] / 100 - percentage) > 0.005)
        return empty;
    // History stores percentages. Align its last step with the physical energy
    // counter so subsequent Wh samples do not introduce a rounding discontinuity.
    const offset = energy - latest[1] / 100 * capacity;
    let points = [];
    for (const entry of entries) {
        if (entry[2] !== state || entry[1] < 0 || entry[1] > 100) {
            points = [];
            continue;
        }
        const point = { energy: entry[1] / 100 * capacity + offset, time: entry[0] * 1000 };
        const previous = points[points.length - 1];
        if (previous && (state === 1 ? point.energy < previous.energy : point.energy > previous.energy))
            points = [];
        if (!previous || point.energy !== previous.energy)
            points.push(point);
    }
    return { state: state, energy: energy, time: now, points: trimPoints(points, now) };
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
