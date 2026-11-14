/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright (C) 2012  Marco Martin <mart@kde.org>
    Copyright (C) 2013  David Edmundson <davidedmundson@kde.org>
    Copyright (C) 2015  Eike Hein <hein@kde.org>

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
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kirigami 2.5 as Kirigami
import org.kde.kquickcontrolsaddons 2.0

import org.kde.plasma.private.kicker 0.1 as Kicker

PlasmoidItem {
    id: kickoff

    readonly property QtObject applet: (typeof plasmoid !== "undefined") ? plasmoid : null
    readonly property int panelIconSize: Kirigami.Units.iconSizes.medium

    switchWidth: Kirigami.Units.gridUnit * 20
    switchHeight: Kirigami.Units.gridUnit * 30

    fullRepresentation: FullRepresentation {}

    compactRepresentation: MouseArea {
        id: compactRoot

        implicitWidth: panelIconSize
        implicitHeight: panelIconSize
        Layout.minimumWidth: 0
        Layout.minimumHeight: 0
        Layout.maximumWidth: -1
        Layout.maximumHeight: -1


        hoverEnabled: true
        onClicked: {
            if (applet) {
                applet.expanded = !applet.expanded;
            }
        }

        DropArea {
            id: compactDragArea
            anchors.fill: parent
        }

        Timer {
            id: expandOnDragTimer
            interval: 250
            running: compactDragArea.containsDrag
            onTriggered: {
                if (applet) {
                    applet.expanded = true;
                }
            }
        }

        Kirigami.Icon {
            id: buttonIcon

            anchors.fill: parent
            source: (applet && applet.configuration) ? applet.configuration.icon : "start-here-kde"
        }
    }

    property Item dragSource: null

    Kicker.ProcessRunner {
        id: processRunner;
    }

    function action_menuedit() {
        processRunner.runMenuEditor();
    }

    Component.onCompleted: {
        if (!applet) {
            return;
        }
        if (applet.hasOwnProperty("activationTogglesExpanded")) {
            applet.activationTogglesExpanded = true
        }
        if (applet.immutability !== PlasmaCore.Types.SystemImmutable) {
            applet.setAction("menuedit", i18n("Edit Applications..."), "kmenuedit");
        }
    }
} // root
