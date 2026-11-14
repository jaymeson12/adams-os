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

import QtQuick 2.5
import QtQml.Models 2.1

import org.kde.kirigami 2.5 as Kirigami
import org.kde.plasma.plasma5support as Plasma5Support


GridView {
    id: configButtons

    cellHeight: Kirigami.Units.gridUnit * 5 + Kirigami.Units.smallSpacing
    cellWidth: Kirigami.Units.gridUnit * 5

    implicitWidth: cellWidth * 5
    implicitHeight: cellHeight * 2
    readonly property real rowsTopY: (headerItem ? headerItem.height : 0)
    readonly property real zoneHeight: cellHeight
    readonly property real delegateHeight: Kirigami.Units.gridUnit * 4
    readonly property real dropZoneMargin: 15

    property var items: {
        "bookmark":    { icon: "favorite-symbolic", text: i18n("Favorites")},
        "application": { icon: "applications-all-symbolic", text: i18n("Applications")},
        "computer":    { icon: "computer-symbolic", text: i18n("Computer")},
        "used":        { icon: "view-history-symbolic", text: i18n("History")},
        "leave":       { icon: "system-log-out-symbolic", text: i18n("Leave")}
    }


    property var menuItems

    property var previousCell: [-1, -1]

    property alias listModel: visualModel.model
    property int sourceIndex: -1

    Component.onCompleted: {
        var configuredItems = plasmoid.configuration.menuItems || [];
        menuItems = configuredItems.filter(function(configItem) {
            var itemName = configItem.substring(0, configItem.indexOf(":"));
            return items[itemName] !== undefined;
        });
        if (configuredItems.length !== menuItems.length) {
            plasmoid.configuration.menuItems = menuItems;
        }
        resetModel();
    }

    function updateModel() {
        var enabledItems = [];
        var disabledItems = [];
        for(var i = 0; i < menuItems.length; i++) {
            var confItemName = menuItems[i].substring(0, menuItems[i].indexOf(":"));
            var confItemEnabled = menuItems[i].substring(menuItems[i].length-1) === "t";

            var listItem = items[confItemName];
            if (!listItem) {
                continue;
            }
            listItem['name'] = confItemName;
            listItem['enabled'] = confItemEnabled;
            if(confItemEnabled) {
                enabledItems.push(listItem);
            } else {
                disabledItems.push(listItem);
            }
        }
        fillEmpty(enabledItems);
        fillEmpty(disabledItems);

        return enabledItems.concat(disabledItems);
    }

    function fillEmpty(list) {
        var emptyItem = { icon: undefined, text: undefined, name: 'empty', enabled: undefined};
        var itemsToAdd = 5 - list.length;
        for(var j = 0; j < itemsToAdd; j++) {
            list.push(emptyItem);
        }
    }

    function updateConfiguration() {
        var newMenuItems = [];
        for(var i = 0; i < visualModel.items.count; i++) {
            var itemName = visualModel.items.get(i).model['name'];

            if(itemName !== 'empty') {
                var configItem = itemName +":" +(i<5?"t":"f");
                newMenuItems.push(configItem);
            }

        }
        menuItems = newMenuItems;
        resetModel();
    }

    function resetModel() {
        listModel.clear();
        var items = updateModel();
        for(var i = 0; i< items.length; i++) {
            listModel.append(items[i]);
        }
    }

    displaced: Transition {
        NumberAnimation { properties: "x,y"; easing.type: Easing.OutQuad }
    }

    Rectangle {
        id: activeZoneBox
        z: -1
        x: configButtons.dropZoneMargin
        y: configButtons.rowsTopY + configButtons.dropZoneMargin
        width: configButtons.cellWidth * 5 - configButtons.dropZoneMargin * 2
        height: configButtons.delegateHeight - configButtons.dropZoneMargin * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.03)
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.22)
    }

    Rectangle {
        id: inactiveZoneBox
        z: -1
        x: configButtons.dropZoneMargin
        y: configButtons.rowsTopY + configButtons.zoneHeight + configButtons.dropZoneMargin
        width: configButtons.cellWidth * 5 - configButtons.dropZoneMargin * 2
        height: configButtons.delegateHeight - configButtons.dropZoneMargin * 2
        radius: Kirigami.Units.smallSpacing
        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.03)
        border.width: 1
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.22)
    }

    Plasma5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
    }

    model: DelegateModel {
        id: visualModel
        model: ListModel {
            id: listModel
        }

        delegate: MouseArea {
            id: delegateRoot

            width: Kirigami.Units.gridUnit * 5
            height: Kirigami.Units.gridUnit * 4

            property int visualIndex: DelegateModel.itemsIndex

            drag.target: button

            onReleased: {
                button.Drag.drop()
            }

            KickoffConfigurationButton {
                id: button

                icon: model.icon === "pm" ? (pmSource.data["PowerDevil"] && pmSource.data["PowerDevil"]["Is Lid Present"] ? "computer-laptop" : "computer") : model.icon
                text: model.text || ""

                name: model.name

                anchors {
                    horizontalCenter: parent.horizontalCenter;
                    verticalCenter: parent.verticalCenter
                }


                Drag.active: delegateRoot.drag.active && name != 'empty'
                Drag.source: delegateRoot
                Drag.hotSpot.x: 36
                Drag.hotSpot.y: 36

                onStateChanged: {
                    if(!Drag.active && sourceIndex != -1) {
                        sourceIndex = -1;
                        updateConfiguration();
                    }
                }

                states: [
                    State {
                        when: button.Drag.active
                        ParentChange {
                            target: button;
                            parent: configButtons;
                        }

                        AnchorChanges {
                            target: button;
                            anchors.horizontalCenter: undefined;
                            anchors.verticalCenter: undefined;
                        }
                    }
                ]
            }

            DropArea {
                anchors { fill: parent; margins: 15 }

                onEntered: function(drag) {
                    var source = drag.source.visualIndex;
                    var target = delegateRoot.visualIndex;
                    sourceIndex = drag.source.visualIndex;
                    if(!(previousCell[0] === source && previousCell[1] === target)) {
                        previousCell = [source, target];
                         if(source < 5 && target >= 5) {
                             visualModel.items.move(source, target);
                             visualModel.items.move(target === 9 ? 8 : 9, 4);
                         } else if (source >= 5 && target < 5) {
                             visualModel.items.move(source, target);
                             visualModel.items.move(5, 9);
                         } else {
                            visualModel.items.move(source, target);
                        }
                    }
                }
                onDropped: function(drag) {
                    updateConfiguration();
                    sourceIndex = -1;
                    previousCell = [-1, -1];
                }
            }
        }
    }

    header: Kirigami.Heading {
        level: 2
        text: i18n("Active Tabs")
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }

    // the middle label is placed right the middle of the grid view, which is a single grid with a gap in the middle
    Kirigami.Heading {
        id: inactiveHeading
        level: 2
        text: i18n("Inactive Tabs")
        y: activeZoneBox.y + activeZoneBox.height
            + Math.max(0, (inactiveZoneBox.y - (activeZoneBox.y + activeZoneBox.height) - implicitHeight) / 2)
        width: parent.width
        horizontalAlignment: Text.AlignHCenter
    }
}
