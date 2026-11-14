/***************************************************************************
 *   Copyright (C) 2013 by Aurélien Gâteau <agateau@kde.org>               *
 *   Copyright (C) 2014-2015 by Eike Hein <hein@kde.org>                   *
 *                                                                         *
 *   This program is free software; you can redistribute it and/or modify  *
 *   it under the terms of the GNU General Public License as published by  *
 *   the Free Software Foundation; either version 2 of the License, or     *
 *   (at your option) any later version.                                   *
 *                                                                         *
 *   This program is distributed in the hope that it will be useful,       *
 *   but WITHOUT ANY WARRANTY; without even the implied warranty of        *
 *   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the         *
 *   GNU General Public License for more details.                          *
 *                                                                         *
 *   You should have received a copy of the GNU General Public License     *
 *   along with this program; if not, write to the                         *
 *   Free Software Foundation, Inc.,                                       *
 *   51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA .        *
 ***************************************************************************/

import QtQuick 2.0
import QtQuick.Controls 2.15 as QQC2

Item {
    id: root

    property QtObject menu
    property Item visualParent
    property variant actionList
    property bool opened: menu ? menu.visible : false

    signal actionClicked(string actionId, variant actionArgument)
    signal closed

    onActionListChanged: refreshMenu();

    onOpenedChanged: {
        if (!opened) {
            closed();
        }
    }

    function open(x, y) {
        if (!actionList || !actionList.length) {
            return;
        }

        if (!menu) {
            refreshMenu();
        }

        if (typeof x === "number" && typeof y === "number") {
            menu.x = x;
            menu.y = y;
        }

        // Do not reparent to a delegate item: it can make the popup render
        // inside a clipped ListView item and appear as "not opening".
        if (typeof menu.popup === "function") {
            menu.popup();
        } else {
            menu.open();
        }
    }

    function refreshMenu() {
        if (menu) {
            menu.destroy();
        }

        if (!actionList) {
            return;
        }

        menu = contextMenuComponent.createObject(root);
        fillMenu(menu, actionList);
    }

    function fillMenu(targetMenu, items) {
        items.forEach(function(actionItem) {
            if (actionItem.subActions) {
                var submenu = submenuComponent.createObject(targetMenu, {
                    "title": actionItem.text ? actionItem.text : ""
                });
                targetMenu.addMenu(submenu);
                fillMenu(submenu, actionItem.subActions);
            } else if (actionItem.type === "separator") {
                targetMenu.addItem(separatorComponent.createObject(targetMenu));
            } else {
                targetMenu.addAction(contextMenuActionComponent.createObject(targetMenu, {
                    "actionItem": actionItem
                }));
            }
        });
    }

    Component {
        id: contextMenuComponent

        QQC2.Menu {
            onClosed: root.closed()
        }
    }

    Component {
        id: submenuComponent
        QQC2.Menu {}
    }

    Component {
        id: separatorComponent
        QQC2.MenuSeparator {}
    }

    Component {
        id: contextMenuActionComponent

        QQC2.Action {
            property variant actionItem

            text      : actionItem.text ? actionItem.text : ""
            enabled   : actionItem.type !== "title" && ("enabled" in actionItem ? actionItem.enabled : true)
            checkable : actionItem.checkable ? actionItem.checkable : false
            checked   : actionItem.checked ? actionItem.checked : false
            icon.name : actionItem.icon ? actionItem.icon : ""

            onTriggered: {
                actionClicked(actionItem.actionId, actionItem.actionArgument);
            }
        }
    }
}
