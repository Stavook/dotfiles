import QtQuick 2.15
import SddmComponents 2.0

Rectangle {
    id: root
    width: 1280
    height: 720
    color: "transparent"

    property int sessionIndex: session.index

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
        color: "#141414"
    }

    Image {
        id: bgImage
        anchors.fill: parent
        source: Qt.resolvedUrl("background.jpg")
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
            color: "#e8e3d8"
            font.family: "Hack Nerd Font"
            font.pixelSize: 90
            text: Qt.formatDateTime(new Date(), "HH:mm")
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#e8e3d8"
            font.family: "Hack Nerd Font"
            font.pixelSize: 22
            text: Qt.formatDateTime(new Date(), "dddd, dd MMMM yyyy")
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#e8e3d8"
            font.family: "Hack Nerd Font"
            font.pixelSize: 20
            text: userModel.lastUser
        }

        PasswordBox {
            id: pw_entry
            width: 280
            height: 44
            anchors.horizontalCenter: parent.horizontalCenter
            color: "#1a1a1a"
            borderColor: "#4a4a4a"
            focusColor: "#cc6633"
            textColor: "#e8e3d8"
            font.family: "Hack Nerd Font"
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
            textColor: "#141414"
            color: "#cc6633"
            activeColor: "#e8823d"
            pressedColor: "#a84a26"
            font.family: "Hack Nerd Font"
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
        color: "#1a1a1a"
        borderColor: "#cc6633"
        textColor: "#e8e3d8"
        menuColor: "#1a1a1a"
        font.family: "Hack Nerd Font"
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
        color: "#1a1a1a"
        borderColor: "#cc6633"
        focusColor: "#cc6633"
        textColor: "#e8e3d8"
        menuColor: "#1a1a1a"
        font.family: "Hack Nerd Font"
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
            color: "#1a1a1a"
            textColor: "#e8e3d8"
            activeColor: "#4a4a4a"
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.suspend()
        }

        Button {
            width: 100
            height: 32
            text: textConstants.reboot
            visible: sddm.canReboot
            color: "#1a1a1a"
            textColor: "#e8e3d8"
            activeColor: "#4a4a4a"
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.reboot()
        }

        Button {
            width: 100
            height: 32
            text: textConstants.shutdown
            visible: sddm.canPowerOff
            color: "#1a1a1a"
            textColor: "#da4453"
            activeColor: "#4a4a4a"
            font.family: "Hack Nerd Font"
            font.pixelSize: 12
            onClicked: sddm.powerOff()
        }
    }

    Component.onCompleted: {
        pw_entry.focus = true
    }
}
