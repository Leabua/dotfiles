import QtQuick
import qs.osd

OsdMeter {
    visible: OsdState.active === "brightness"
    percent: OsdState.brightPercent
    icon: OsdState.brightPercent < 50 ? "sunDim" : "sun"
}
