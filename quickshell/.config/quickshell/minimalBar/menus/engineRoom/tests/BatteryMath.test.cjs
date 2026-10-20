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
