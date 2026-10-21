const assert = require("node:assert/strict");
const { readFileSync } = require("node:fs");
const { join } = require("node:path");
const { test } = require("node:test");
const { runInNewContext } = require("node:vm");

const gpu = {};
runInNewContext(readFileSync(join(__dirname, "../GpuMath.js"), "utf8"), gpu);
const sample = (rc6, time, clock = "300") => gpu.parseSample(`/sys/class/drm/card1\n${rc6}\n${clock}\n1100\n1\n${time}`);

test("calculates awake time independently of the actual clock", () => {
    const first = sample(1000, 10);
    assert.equal(gpu.awakeFraction(first, sample(1750, 11.5, "1067")), 0.5);
    assert.equal(gpu.awakeFraction(first, sample(1750, 11.5, "300")), 0.5);
    assert.equal(gpu.awakeFraction(first, sample(2500, 11.5)), 0);
    assert.equal(gpu.awakeFraction(first, sample(1000, 11.5)), 1);
});

test("missing clocks stay unavailable without shifting maximum or residency fields", () => {
    const current = sample(1000, 10, "-1");
    assert.equal(current.clock, -1);
    assert.equal(current.maximum, 1100);
    assert.equal(current.rc6, 1000);
    assert.equal(sample(1000, 10, "").clock, -1);
    assert.equal(sample(1000, 10, "garbage").clock, -1);
    assert.equal(sample(1000, 10, "0").clock, 0);
    assert.equal(gpu.parseSample(""), null);
    assert.equal(gpu.parseSample("/sys/class/drm/card1\n1000\n300\n1100\n10"), null);
});

test("first samples, resets, device changes, and disabled RC6 never fabricate usage", () => {
    const first = sample(1000, 10);
    const next = sample(1750, 11.5);
    assert.equal(gpu.awakeFraction(null, next), -1);
    assert.equal(gpu.awakeFraction(first, null), -1);
    assert.equal(gpu.awakeFraction(first, sample(500, 11.5)), -1);
    assert.equal(gpu.awakeFraction(first, sample(1750, 10)), -1);
    assert.equal(gpu.awakeFraction(first, sample(5000, 11.5)), -1);
    assert.equal(gpu.awakeFraction(first, { ...next, device: "/sys/class/drm/card2" }), -1);
    assert.equal(gpu.awakeFraction(first, { ...next, rc6Enabled: false }), -1);
    assert.equal(gpu.awakeFraction(first, { ...next, rc6: -1 }), -1);
});
