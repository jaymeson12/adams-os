/*
 *  Copyright 2016 John Salatas <jsalatas@gmail.com>
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  2.010-1301, USA.
 */

import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.kquickcontrolsaddons 2.0
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.kirigami 2.5 as Kirigami

Item {
    id: button
    property alias icon: iconElement.source
    property alias text: textElement.text
    property string name

    width: Kirigami.Units.gridUnit * 5
    height: Kirigami.Units.gridUnit * 4

    visible: name != "empty"

    Rectangle {
        anchors.fill: parent
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.9)
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.18)
    }

    ColumnLayout {
        anchors.centerIn: parent

        Kirigami.Icon {
            id: iconElement

            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Kirigami.Units.iconSizes.medium
            Layout.preferredHeight: width

            source: icon
        }

        PlasmaComponents.Label {
            id: textElement
            Layout.alignment: Qt.AlignHCenter
            horizontalAlignment: Text.AlignHCenter
            elide: Text.ElideRight
            color: Kirigami.Theme.textColor
        }
    }
}
