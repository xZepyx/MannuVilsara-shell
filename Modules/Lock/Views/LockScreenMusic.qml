// DESIGN CONCEPT: "Asymmetric Horizon"
// LAYOUT: A bold split-screen composition.
// - Background: Cinematic blur with film-grain texture for depth.
// - Left: A massive, floating album art card with 'glass' reflections.
// - Right: A typographic stack with a vertical clock and media controls.
// BEHAVIOR: Elements breathe and shift based on playback state.

import "../Cards"
import "../Components"
import Qt5Compat.GraphicalEffects
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Quickshell
import qs.Core
import qs.Services

Item {
    id: root

    required property var colors
    required property var pam
    property alias inputField: musicPwd.inputField

    // --- State Helpers ---
    property bool hasMedia: MprisService.title !== ""
    property bool isPlaying: MprisService.isPlaying

    // --- Background Layer ---
    Item {
        id: backgroundLayer
        anchors.fill: parent

        property string currentArt: MprisService.artUrl

        onCurrentArtChanged: {
            if (currentArt === "") return;
            if (bgImg1.opacity > 0) {
                bgImg2.source = currentArt;
                crossfadeTo2.start();
            } else {
                bgImg1.source = currentArt;
                crossfadeTo1.start();
            }
        }

        Rectangle {
            anchors.fill: parent
            color: "#050505" // Deep base
        }

        // Fallback Wallpaper
        Image {
            anchors.fill: parent
            source: Config.lockScreenCustomBackground ? ("file://" + WallpaperService.getWallpaper(Quickshell.screens[0].name)) : ""
            fillMode: Image.PreserveAspectCrop
            visible: MprisService.artUrl === ""
            opacity: 0.6
        }

        // Crossfading Art Backgrounds
        Image { id: bgImg1; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; visible: opacity > 0; asynchronous: true }
        Image { id: bgImg2; anchors.fill: parent; fillMode: Image.PreserveAspectCrop; visible: opacity > 0; opacity: 0; asynchronous: true }

        ParallelAnimation {
            id: crossfadeTo2
            NumberAnimation { target: bgImg2; property: "opacity"; to: 1; duration: 1200; easing.type: Easing.InOutQuad }
            NumberAnimation { target: bgImg1; property: "opacity"; to: 0; duration: 1200; easing.type: Easing.InOutQuad }
        }

        ParallelAnimation {
            id: crossfadeTo1
            NumberAnimation { target: bgImg1; property: "opacity"; to: 1; duration: 1200; easing.type: Easing.InOutQuad }
            NumberAnimation { target: bgImg2; property: "opacity"; to: 0; duration: 1200; easing.type: Easing.InOutQuad }
        }

        // Cinematic Blur
        layer.enabled: true
        layer.effect: FastBlur {
            radius: 100
            transparentBorder: false
        }

        // Texture Overlay (Simulated Noise/Grain for texture)
        Rectangle {
            anchors.fill: parent
            color: "transparent"
            // A subtle gradient overlay to act as a vignette
            gradient: Gradient {
                GradientStop { position: 0.0; color: "#20000000" }
                GradientStop { position: 1.0; color: "#A0000000" }
            }
        }
    }

    // --- Main Content Area ---
    Item {
        id: contentArea
        anchors.fill: parent
        anchors.bottomMargin: 130 // Space for password card
        anchors.margins: 60
        z: 10

        RowLayout {
            anchors.centerIn: parent
            spacing: 80 // Wide gap between Art and Info

            // --- LEFT COLUMN: Visuals ---
            Item {
                id: artContainer
                Layout.preferredWidth: 450
                Layout.preferredHeight: 450
                Layout.alignment: Qt.AlignVCenter
                
                // Entrance Animation
                visible: root.hasMedia
                opacity: visible ? 1 : 0
                Behavior on opacity { NumberAnimation { duration: 600 } }

                // Breathing Animation when playing
                scale: root.isPlaying ? 1.0 : 0.95
                Behavior on scale { NumberAnimation { duration: 800; easing.type: Easing.InOutSine } }

                // The Album Card
                Rectangle {
                    id: cardSurface
                    anchors.fill: parent
                    radius: 24
                    color: "#151515"
                    
                    // Deep shadow for "floating" effect
                    layer.enabled: true
                    layer.effect: DropShadow {
                        transparentBorder: true
                        radius: 64
                        samples: 32
                        color: "#90000000"
                        verticalOffset: 30
                    }

                    // Art
                    Image {
                        anchors.fill: parent
                        source: MprisService.artUrl
                        fillMode: Image.PreserveAspectCrop
                        asynchronous: true
                        layer.enabled: true
                        layer.effect: OpacityMask {
                            maskSource: Rectangle { width: 450; height: 450; radius: 24 }
                        }
                    }

                    // Glass Reflection Overlay
                    Rectangle {
                        anchors.fill: parent
                        radius: 24
                        gradient: Gradient {
                            orientation: Gradient.Vertical
                            GradientStop { position: 0.0; color: "#15FFFFFF" }
                            GradientStop { position: 0.5; color: "transparent" }
                            GradientStop { position: 1.0; color: "#05000000" }
                        }
                        border.color: "#20FFFFFF"
                        border.width: 1
                        color: "transparent"
                    }
                }
            }

            // --- RIGHT COLUMN: Info & Controls ---
            ColumnLayout {
                Layout.alignment: Qt.AlignVCenter
                Layout.preferredWidth: 400
                spacing: 24

                // 1. Date Eyebrow
                Text {
                    text: Qt.formatDate(new Date(), "dddd, MMMM d").toUpperCase()
                    font.family: "JetBrainsMono Nerd Font"
                    font.pixelSize: 13
                    font.letterSpacing: 3
                    font.weight: Font.Bold
                    color: root.colors.accent
                    opacity: 0.8
                    Layout.alignment: Qt.AlignLeft
                }

                // 2. The Monolith Clock (Stacked)
                Column {
                    Layout.alignment: Qt.AlignLeft
                    spacing: -45 // Tight stacking

                    Text {
                        text: {
                            let h = new Date().getHours() % 12 || 12;
                            return h.toString().padStart(2, '0');
                        }
                        font.family: "StretchPro"
                        font.pixelSize: 150
                        font.weight: Font.Black
                        color: "#FFFFFF"
                        
                        layer.enabled: true
                        layer.effect: DropShadow { radius: 16; color: "#40000000"; verticalOffset: 4 }
                    }

                    Text {
                        text: Qt.formatTime(new Date(), "mm")
                        font.family: "StretchPro"
                        font.pixelSize: 150
                        font.weight: Font.Black
                        color: "transparent" 
                        style: Text.Outline
                        styleColor: "#80FFFFFF" // Ghostly outline style for minutes
                    }
                }

                // Spacer
                Item { Layout.preferredHeight: 10 }

                // 3. Track Details
                ColumnLayout {
                    visible: root.hasMedia
                    opacity: visible ? 1 : 0
                    Behavior on opacity { NumberAnimation { duration: 400 } }
                    Layout.fillWidth: true
                    spacing: 8

                    Text {
                        text: MprisService.title || "No Media"
                        font.family: Config.fontFamily
                        font.pixelSize: 32
                        font.weight: Font.ExtraBold
                        color: "#FFFFFF"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                    }

                    Text {
                        text: MprisService.artist || "Unknown Artist"
                        font.family: Config.fontFamily
                        font.pixelSize: 20
                        font.weight: Font.Medium
                        color: "#CCCCCC"
                        elide: Text.ElideRight
                        Layout.fillWidth: true
                        Layout.maximumWidth: 400
                    }

                    // Minimalist Progress Line
                    Item {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 4
                        Layout.topMargin: 12
                        visible: MprisService.length > 0
                        
                        Rectangle {
                            anchors.fill: parent
                            color: "#FFFFFF"
                            opacity: 0.15
                            radius: 2
                        }
                        Rectangle {
                            height: parent.height
                            width: (MprisService.position / Math.max(1, MprisService.length)) * parent.width
                            color: root.colors.accent
                            radius: 2
                            
                            // Neon glow on progress
                            layer.enabled: true
                            layer.effect: Glow { radius: 8; samples: 8; color: root.colors.accent; transparentBorder: true }
                        }
                    }
                }

                // 4. Floating Controls
                RowLayout {
                    visible: root.hasMedia
                    Layout.topMargin: 16
                    spacing: 32

                    // Prev Button
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: "transparent"
                        border.color: prevMouse.containsMouse ? "#FFFFFF" : "#40FFFFFF"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰒮"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            color: "#FFFFFF"
                        }
                        MouseArea {
                            id: prevMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisService.previous()
                        }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }

                    // Play/Pause Hero Button
                    Rectangle {
                        width: 70; height: 70; radius: 24 // Squircle shape
                        color: root.colors.accent
                        
                        Text {
                            anchors.centerIn: parent
                            text: root.isPlaying ? "󰏤" : "󰐊"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 30
                            color: root.colors.bg
                            anchors.horizontalCenterOffset: root.isPlaying ? 0 : 2
                        }

                        MouseArea {
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisService.playPause()
                            onPressed: parent.scale = 0.92
                            onReleased: parent.scale = 1.0
                        }
                        
                        Behavior on scale { NumberAnimation { duration: 100; easing.type: Easing.OutQuad } }
                        
                        // Hero Shadow
                        layer.enabled: true
                        layer.effect: DropShadow { radius: 16; color: "#60000000"; verticalOffset: 8 }
                    }

                    // Next Button
                    Rectangle {
                        width: 50; height: 50; radius: 25
                        color: "transparent"
                        border.color: nextMouse.containsMouse ? "#FFFFFF" : "#40FFFFFF"
                        border.width: 1

                        Text {
                            anchors.centerIn: parent
                            text: "󰒭"
                            font.family: "Symbols Nerd Font"
                            font.pixelSize: 22
                            color: "#FFFFFF"
                        }
                        MouseArea {
                            id: nextMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: MprisService.next()
                        }
                        Behavior on border.color { ColorAnimation { duration: 200 } }
                    }
                }
            }
        }
    }

    // --- Footer: Password ---
    Item {
        id: footer
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        height: 120
        z: 20

        PasswordCard {
            id: musicPwd
            anchors.centerIn: parent
            width: 380
            height: 110
            colors: root.colors
            pam: root.pam
            visible: true
            opacity: 1
            
            // Modern, flat styling to match the new aesthetic
            cardColor: Qt.rgba(0, 0, 0, 0.75) 
            borderColor: Qt.rgba(1, 1, 1, 0.1)
        }
    }
}