function number(text) {
    if (text === undefined || text.trim() === "")
        return -1;
    const value = Number(text);
    return Number.isFinite(value) && value >= 0 ? value : -1;
}

function parseSample(text) {
    const lines = text.trim().split("\n");
    if (lines.length !== 6 || !/^\/sys\/class\/drm\/card\d+$/.test(lines[0]))
        return null;
    return {
        device: lines[0],
        rc6: number(lines[1]),
        clock: number(lines[2]),
        maximum: number(lines[3]),
        rc6Enabled: number(lines[4]) > 0,
        wall: number(lines[5])
    };
}

// RC6 measures sleep residency, not engine workload. Do not label this as usage.
function awakeFraction(previous, current) {
    if (!previous || !current || previous.device !== current.device || !previous.rc6Enabled || !current.rc6Enabled || previous.rc6 < 0 || current.rc6 < 0 || previous.wall < 0 || current.wall < 0)
        return -1;
    const elapsed = (current.wall - previous.wall) * 1000;
    const idle = current.rc6 - previous.rc6;
    if (elapsed <= 0 || idle < 0 || idle > elapsed + 50)
        return -1;
    return Math.max(0, Math.min(1, 1 - idle / elapsed));
}
