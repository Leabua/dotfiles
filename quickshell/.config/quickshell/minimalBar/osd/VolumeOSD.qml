import QtQuick
import qs.osd

OsdMeter {
    visible: OsdState.active === "volume"
    percent: OsdState.volPercent
    dimmed: OsdState.volMuted
    icon: {
        if (OsdState.volMuted || OsdState.volPercent === 0)
            return "speakerMuted";
        if (OsdState.volPercent < 34)
            return "speakerLow";
        if (OsdState.volPercent < 67)
            return "speakerMedium";
        return "speaker";
    }
}
