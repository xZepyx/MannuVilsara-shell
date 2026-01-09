import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Core

PanelWindow {
    id: screenCorners

    property var context

    visible: !context.activeWindow.isFullscreen
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore
    WlrLayershell.namespace: "quickshell:screenCorners"
    WlrLayershell.layer: WlrLayer.Overlay

    anchors {
        top: true
        left: true
        right: true
        bottom: true
    }

    property int barHeight: {
        switch (context.config.barSize) {
            case "compact": return 35;
            case "expanded": return 50;
            default: return 40;
        }
    }

    Behavior on barHeight {
        NumberAnimation {
            duration: 300
            easing.type: Easing.OutQuad
        }
    }

    property int cornerSize: 25
    property bool topActive: !context.config.floatingBar && context.config.barPosition === "top"
    property bool bottomActive: !context.config.floatingBar && context.config.barPosition === "bottom"

    RoundCorner {
        id: topLeft

        size: cornerSize
        anchors.left: parent.left
        state: topActive ? "active" : ""
        anchors.top: parent.top
        anchors.topMargin: 0
        // Behavior on anchors.topMargin { NumberAnimation { duration: 10; easing.type: Easing.OutQuad } }
        corner: RoundCorner.CornerEnum.TopLeft
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: topLeft; anchors.leftMargin: 0; anchors.topMargin: barHeight }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: topLeft; property: "anchors.topMargin"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: topLeft; property: "anchors.topMargin"; value: barHeight }
                    PropertyAction { target: topLeft; property: "anchors.leftMargin"; value: -cornerSize }
                    NumberAnimation { target: topLeft; property: "anchors.leftMargin"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.leftMargin: 0
    }

    RoundCorner {
        id: topRight

        size: cornerSize
        anchors.right: parent.right
        state: topActive ? "active" : ""
        anchors.top: parent.top
        anchors.topMargin: 0
        // Behavior on anchors.topMargin { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        corner: RoundCorner.CornerEnum.TopRight
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: topRight; anchors.rightMargin: 0; anchors.topMargin: barHeight }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: topRight; property: "anchors.topMargin"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: topRight; property: "anchors.topMargin"; value: barHeight }
                    PropertyAction { target: topRight; property: "anchors.rightMargin"; value: -cornerSize }
                    NumberAnimation { target: topRight; property: "anchors.rightMargin"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.rightMargin: 0
    }

    RoundCorner {
        id: bottomLeft

        size: cornerSize
        anchors.left: parent.left
        state: bottomActive ? "active" : ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        // Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        corner: RoundCorner.CornerEnum.BottomLeft
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: bottomLeft; anchors.leftMargin: 0; anchors.bottomMargin: barHeight }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: bottomLeft; property: "anchors.bottomMargin"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: bottomLeft; property: "anchors.bottomMargin"; value: barHeight }
                    PropertyAction { target: bottomLeft; property: "anchors.leftMargin"; value: -cornerSize }
                    NumberAnimation { target: bottomLeft; property: "anchors.leftMargin"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.leftMargin: 0
    }

    RoundCorner {
        id: bottomRight

        size: cornerSize
        anchors.right: parent.right
        state: bottomActive ? "active" : ""
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 0
        // Behavior on anchors.bottomMargin { NumberAnimation { duration: 300; easing.type: Easing.OutQuad } }
        corner: RoundCorner.CornerEnum.BottomRight
        color: context.colors.bg

        states: State {
            name: "active"
            PropertyChanges { target: bottomRight; anchors.rightMargin: 0; anchors.bottomMargin: barHeight }
        }
        transitions: [
            Transition {
                from: ""; to: "active"
                SequentialAnimation {
                    PropertyAction { target: bottomRight; property: "anchors.bottomMargin"; value: 0 }
                    PauseAnimation { duration: 300 }
                    PropertyAction { target: bottomRight; property: "anchors.bottomMargin"; value: barHeight }
                    PropertyAction { target: bottomRight; property: "anchors.rightMargin"; value: -cornerSize }
                    NumberAnimation { target: bottomRight; property: "anchors.rightMargin"; to: 0; duration: 300; easing.type: Easing.OutQuad }
                }
            }
        ]
        anchors.rightMargin: 0
    }

    mask: Region {
        item: null
    }

}
