/*
 *    Copyright 2014  Sebastian Kügler <sebas@kde.org>
 *    SPDX-FileCopyrightText: (C) 2020 Carl Schwan <carl@carlschwan.eu>
 *
 *    This program is free software; you can redistribute it and/or modify
 *    it under the terms of the GNU General Public License as published by
 *    the Free Software Foundation; either version 2 of the License, or
 *    (at your option) any later version.
 *
 *    This program is distributed in the hope that it will be useful,
 *    but WITHOUT ANY WARRANTY; without even the implied warranty of
 *    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *    GNU General Public License for more details.
 *
 *    You should have received a copy of the GNU General Public License along
 *    with this program; if not, write to the Free Software Foundation, Inc.,
 *    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import Qt5Compat.GraphicalEffects 1.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.13 as Kirigami
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.plasma5support as Plasma5Support

PlasmaExtras.PlasmoidHeading {
    id: header

    implicitHeight: headerRow.implicitHeight
        + contentLayout.anchors.topMargin
        + contentLayout.anchors.bottomMargin

    property alias query: queryField.text
    property Item input: queryField
    property string loginName: ""
    property string displayName: i18n("User")
    property string avatarPath: ""
    property string avatarUrl: avatarPath.length > 0
        ? (avatarPath.indexOf("file://") === 0 ? avatarPath : "file://" + avatarPath)
        : ""

    state: "name"

    Component.onCompleted: {
        userInfoSource.connectedSources = [
            "sh -lc 'u=$(id -un); n=$(getent passwd \"$u\" 2>/dev/null | cut -d: -f5 | cut -d, -f1); [ -n \"$n\" ] || n=\"$u\"; icon=\"\"; cfg=\"/var/lib/AccountsService/users/$u\"; if [ -r \"$cfg\" ]; then icon=$(grep \"^Icon=\" \"$cfg\" | head -n1 | cut -d= -f2-); fi; if [ -z \"$icon\" ]; then for p in \"$HOME/.face\" \"$HOME/.face.icon\" \"/var/lib/AccountsService/icons/$u\"; do [ -r \"$p\" ] && { icon=\"$p\"; break; }; done; fi; printf \"%s\\n%s\\n%s\\n\" \"$u\" \"$n\" \"$icon\"'"
        ];
    }

    Plasma5Support.DataSource {
        id: userInfoSource
        engine: "executable"
        connectedSources: []
        onNewData: function(sourceName, data) {
            const stdout = (data && data.stdout) ? data.stdout.trim() : "";
            if (!stdout.length) {
                return;
            }
            const lines = stdout.split("\n");
            if (lines.length > 0 && lines[0].length > 0) {
                header.loginName = lines[0];
            }
            if (lines.length > 1 && lines[1].length > 0) {
                header.displayName = lines[1];
            } else if (header.loginName.length > 0) {
                header.displayName = header.loginName;
            }
            if (lines.length > 2 && lines[2].length > 0) {
                header.avatarPath = lines[2];
            } else {
                header.avatarPath = "";
            }
        }
    }

    ColumnLayout {
        id: contentLayout
        anchors.fill: parent
        anchors.leftMargin: Kirigami.Units.largeSpacing
        anchors.rightMargin: Kirigami.Units.largeSpacing
        anchors.topMargin: Kirigami.Units.largeSpacing
        anchors.bottomMargin: Kirigami.Units.largeSpacing
        spacing: 0

        RowLayout {
            id: headerRow
            Layout.fillWidth: true
            spacing: Kirigami.Units.largeSpacing

            Item {
                id: avatarContainer
                Layout.preferredWidth: Kirigami.Units.gridUnit * 2.8
                Layout.preferredHeight: Kirigami.Units.gridUnit * 2.8
                Layout.alignment: Qt.AlignTop

                Image {
                    id: avatarImage
                    anchors.fill: parent
                    source: header.avatarUrl
                    visible: false
                    cache: false
                    asynchronous: true
                    smooth: false
                    sourceSize.width: avatarContainer.width
                    sourceSize.height: avatarContainer.height
                }

                OpacityMask {
                    anchors.fill: parent
                    visible: avatarImage.status === Image.Ready
                    source: avatarImage
                    maskSource: Rectangle {
                        width: avatarContainer.width
                        height: avatarContainer.height
                        radius: width / 2
                    }
                }

                Rectangle {
                    anchors.fill: parent
                    color: "transparent"
                    border.width: 1
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                    radius: width / 2
                }

                Kirigami.Icon {
                    visible: avatarImage.status !== Image.Ready
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    source: "user-identity"
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                PlasmaComponents.Label {
                    id: userLabel
                    Layout.fillWidth: true
                    text: header.displayName
                    font.bold: true
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignLeft
                }

                PlasmaComponents.TextField {
                    id: queryField
                    Layout.fillWidth: true

                    placeholderText: i18n("Search...")
                    clearButtonShown: true

                    onTextChanged: {
                        if (text.length > 0) {
                            header.state = "query";
                            if (root.state != "Search") {
                                root.previousState = root.state;
                                root.state = "Search";
                            }
                        } else {
                            header.state = "name";
                            root.state = root.previousState;
                        }
                    }
                }
            }
        }

    }
}
