const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { test } = require("node:test");
const { runInNewContext } = require("node:vm");

const battery = {};
runInNewContext(readFileSync(join(__dirname, "../BatteryMath.js"), "utf8"), battery);

test("prefers the physical laptop battery over UPower's aggregate device", () => {
    const aggregate = { healthSupported: false };
    const mouse = { ready: true, isPresent: true, isLaptopBattery: false };
    const laptop = { ready: true, isPresent: true, isLaptopBattery: true, healthSupported: true };
    assert.equal(battery.pickBattery([mouse, laptop], aggregate), laptop);
    assert.equal(battery.pickBattery([mouse, { ...laptop, ready: false }], aggregate), aggregate);
    assert.equal(battery.pickBattery([{ ...laptop, isPresent: false }], aggregate), aggregate);
});

test("derives charging and discharging watts from settled energy readings", () => {
    assert.equal(battery.rateFromEnergy(12, 12.2, 60000, true).toFixed(1), "12.0");
    assert.equal(battery.rateFromEnergy(12, 11.8, 60000, false).toFixed(1), "12.0");
    assert.equal(battery.rateFromEnergy(12, 12, 60000, true), 0);
    assert.equal(battery.rateFromEnergy(12, 11.8, 60000, true), 0);
    assert.equal(battery.rateFromEnergy(12, 12.2, 60000, false), 0);
});

test("rejects short, unavailable, and invalid energy samples", () => {
    assert.equal(battery.rateFromEnergy(12, 12.2, 1000, true), 0);
    assert.equal(battery.rateFromEnergy(NaN, 12.2, 60000, true), 0);
    assert.equal(battery.rateFromEnergy(12, Infinity, 60000, true), 0);
    assert.equal(battery.rateFromEnergy(12, 12.2, NaN, true), 0);
    assert.equal(battery.rateFromEnergy(-1, 12.2, 60000, true), 0);
});

test("estimates time to full and time remaining in seconds", () => {
    assert.equal(battery.remainingSeconds(10, 34, 12, true), 7200);
    assert.equal(battery.remainingSeconds(18, 34, 6, false), 10800);
    assert.equal(battery.remainingSeconds(34, 34, 12, true), 0);
    assert.equal(battery.remainingSeconds(10, 34, 0, true), 0);
    assert.equal(battery.remainingSeconds(10, 0, 12, true), 0);
    assert.equal(battery.remainingSeconds(NaN, 34, 12, true), 0);
});

test("normalizes health without mistaking zero health for missing data", () => {
    assert.equal(battery.healthPercent(1), 100);
    assert.equal(battery.healthPercent(0.83), 83);
    assert.equal(battery.healthPercent(83), 83);
    assert.equal(battery.healthPercent(0), 0);
    assert.equal(battery.healthPercent(NaN), -1);
    assert.equal(battery.healthPercent(-1), -1);
});

test("measures complete firmware steps without spikes or resets during flat readings", () => {
    let trend = battery.createTrend();
    const start = 1000000;
    for (let seconds = 0; seconds <= 390; seconds += 30) {
        // The popup starts shortly before the first step. That partial interval
        // must not become the baseline for the first charge-rate estimate.
        const steps = seconds < 30 ? 0 : Math.floor((seconds - 30) / 180) + 1;
        trend = battery.recordEnergy(trend, 12 + steps * 0.35, start + seconds * 1000, 1);
        const rate = battery.trendRate(trend, start + seconds * 1000);
        if (seconds < 210)
            assert.equal(rate, 0);
        else
            assert.ok(Math.abs(rate - 7) < 0.000001);
    }
    assert.equal(trend.points.length, 3);
});

test("expires stalled rates and resets across unplugging, suspend, or clock changes", () => {
    const now = 2000000;
    const trend = { state: 1, energy: 12.7, time: now, points: [
        { energy: 12.35, time: now - 180000 },
        { energy: 12.7, time: now }
    ] };
    assert.ok(battery.trendRate(trend, now) > 0);
    assert.equal(battery.trendRate(trend, now + 360001), 0);
    assert.equal(battery.recordEnergy(trend, 12.7, now + 1000, 2).points.length, 0);
    assert.equal(battery.recordEnergy(trend, 12.7, now + 120000, 1).points.length, 0);
    assert.equal(battery.recordEnergy(trend, 12.7, now - 1000, 1).points.length, 0);
    assert.equal(battery.recordEnergy(trend, 12.7, now + 1000, 4).state, -1);
});

test("bootstraps a sustained rate from charge history and aligns subsequent Wh samples", () => {
    const now = 10000000;
    const history = [
        [(now - 60000) / 1000, 37, 1],
        [(now - 240000) / 1000, 36, 1],
        [(now - 420000) / 1000, 35, 1],
        [(now - 600000) / 1000, 34, 1]
    ];
    let trend = battery.trendFromHistory(history, 12.936, 35.112, 0.37, 1, now);
    assert.ok(Math.abs(battery.trendRate(trend, now) - 7.0224) < 0.000001);
    assert.equal(trend.points.at(-1).energy, 12.936);
    for (let seconds = 30; seconds <= 120; seconds += 30)
        trend = battery.recordEnergy(trend, seconds < 120 ? 12.936 : 13.28712, now + seconds * 1000, 1);
    assert.ok(Math.abs(battery.trendRate(trend, now + 120000) - 7.0224) < 0.000001);
    const seconds = battery.remainingSeconds(12.936, 35.112, battery.trendRate(trend, now + 120000), true);
    assert.ok(seconds > 10800 && seconds < 11500);
});

test("rejects stale or mismatched history and never averages across power-state changes", () => {
    const now = 10000000;
    const history = [
        [(now - 600000) / 1000, 40, 2],
        [(now - 420000) / 1000, 39, 2],
        [(now - 240000) / 1000, 39, 1],
        [(now - 60000) / 1000, 40, 1]
    ];
    const charging = battery.trendFromHistory(history, 14, 35, 0.40, 1, now);
    assert.equal(charging.points.length, 2);
    assert.ok(Math.abs(battery.trendRate(charging, now) - 7) < 0.000001);
    assert.equal(battery.trendFromHistory(history, 14, 35, 0.40, 2, now).points.length, 0);
    assert.equal(battery.trendFromHistory(history, 14, 35, 0.50, 1, now).points.length, 0);
    assert.equal(battery.trendRate(charging, now + 600000), 0);
    assert.equal(battery.trendFromHistory(null, 14, 35, 0.40, 1, now).points.length, 0);
});
