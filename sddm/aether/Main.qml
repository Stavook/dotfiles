import QtQuick 2.15
import QtQuick.Effects
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "transparent"

    property int sessionIndex: session.index

    // Colors come from theme.conf (defaults) overridden by theme.conf.user,
    // which Aether generates (aether/custom/sddm).
    property color cBg: config.bg
    property color cFg: config.fg
    property color cAccent: config.accent
    property color cAlert: config.alert
    property color cError: config.error
    property color cDimmed: config.dimmed
    property color cSurface: config.surface
    property color cOnAccent: config.onAccent

    TextConstants { id: textConstants }

    Connections {
        target: sddm
        function onLoginFailed() {
            pw_entry.text = ""
            pw_entry.focus = true
        }
    }

    Rectangle {
        id: bg
        anchors.fill: parent
        color: root.cBg
    }

    Image {
        id: bgImage
        anchors.fill: parent
        source: config.background ? Qt.resolvedUrl(config.background) : ""
        fillMode: Image.PreserveAspectCrop
        asynchronous: true
    }

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: timeText.text = Qt.formatDateTime(new Date(), "HH:mm")
    }

    // Centered: clock, hostname, preselected user, password, login button
    Column {
        anchors.centerIn: parent
        spacing: 16

        Text {
            id: timeText
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 90
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.8
                shadowBlur: 0.6
            }
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 22
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.8
                shadowBlur: 0.6
            }
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 20
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: "black"
                shadowOpacity: 0.8
                shadowBlur: 0.6
            }
            text: userModel.lastUser
        }

        PasswordBox {
            id: pw_entry
            width: 280
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            color: root.cSurface
            borderColor: root.cDimmed
            focusColor: root.cAccent
            textColor: root.cFg
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            radius: 6
            focus: true
            KeyNavigation.tab: login_button

            Keys.onPressed: function (event) {
                if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                    sddm.login(userModel.lastUser, pw_entry.text, sessionIndex)
                    event.accepted = true
                }
            }
        }

        Button {
            id: login_button
            width: 280
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            text: textConstants.login
            textColor: root.cOnAccent
            color: root.cAccent
            activeColor: root.cAlert
            pressedColor: Qt.darker(root.cAccent, 1.4)
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 16
            onClicked: sddm.login(userModel.lastUser, pw_entry.text, sessionIndex)
            KeyNavigation.backtab: pw_entry
            KeyNavigation.tab: session
        }
    }

    // Top left: session picker
    ComboBox {
        id: session
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 20
        width: 160
        height: 32
        model: sessionModel
        index: sessionModel.lastIndex
        color: root.cSurface
        borderColor: root.cAccent
        textColor: root.cFg
        menuColor: root.cSurface
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        KeyNavigation.backtab: login_button
        KeyNavigation.tab: layoutBox
    }

    // Bottom left: keyboard layout
    LayoutBox {
        id: layoutBox
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.margins: 20
        width: 90
        height: 32
        color: root.cSurface
        borderColor: root.cAccent
        focusColor: root.cAccent
        textColor: root.cFg
        menuColor: root.cSurface
        font.family: "JetBrainsMono Nerd Font"
        font.pixelSize: 12
        visible: keyboard.enabled && keyboard.layouts.length > 0
        KeyNavigation.backtab: session
        KeyNavigation.tab: pw_entry
    }

    // Bottom right: power actions
    Row {
        anchors.bottom: parent.bottom
        anchors.right: parent.right
        anchors.margins: 20
        spacing: 12

        Button {
            width: 100
            height: 32
            text: textConstants.suspend
            visible: sddm.canSuspend
            color: root.cSurface
            textColor: root.cFg
            activeColor: root.cDimmed
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.suspend()
        }

        Button {
            width: 100
            height: 32
            text: textConstants.reboot
            visible: sddm.canReboot
            color: root.cSurface
            textColor: root.cFg
            activeColor: root.cDimmed
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.reboot()
        }

        Button {
            width: 100
            height: 32
            text: textConstants.shutdown
            visible: sddm.canPowerOff
            color: root.cSurface
            textColor: root.cError
            activeColor: root.cDimmed
            font.family: "JetBrainsMono Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: {
        pw_entry.focus = true
    }
}
