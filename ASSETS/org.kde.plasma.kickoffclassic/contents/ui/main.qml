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
            kickoff.expanded = !kickoff.expanded;
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
                kickoff.expanded = true;
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
        id: processRunner
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
        // setAction() is not available on all Plasma 6 applet interfaces.
    }
}
