/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
*/
import QtQuick 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import QtQuick.Controls 2.15 as QQC2

QQC2.ToolButton {
    id: button
    objectName: "KickoffButton"

    property string iconSource
    property string labelText
    property Item tab
    property Item tabGroup
    property Item tabBar

    checkable: true
    text: ""
    checked: tabBar && tabBar.currentTab === button

    onClicked: {
        if (tabGroup && tab) {
            tabGroup.currentTab = tab;
        }
        if (tabBar) {
            tabBar.currentTab = button;
        }
    }

    implicitHeight: Kirigami.Units.gridUnit * 4.6
    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    background: Rectangle {
        color: button.hovered
            ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            : "transparent"

        Rectangle {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            height: 2
            visible: button.checked
            color: Kirigami.Theme.highlightColor
        }
    }

    contentItem: Item {
        anchors.fill: parent

        Column {
            anchors.centerIn: parent
            width: parent.width - (Kirigami.Units.smallSpacing * 2)
            spacing: Kirigami.Units.smallSpacing / 2

            Kirigami.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                width: Kirigami.Units.iconSizes.Medium
                height: width
                source: button.iconSource
            }

            QQC2.Label {
                width: parent.width
                text: button.labelText
                horizontalAlignment: Text.AlignHCenter
                elide: Text.ElideRight
                color: Kirigami.Theme.textColor
            }
        }
    }
} // button
