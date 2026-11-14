/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright 2014 Sebastian Kügler <sebas@kde.org>
    Copyright (C) 2015-2018  Eike Hein <hein@kde.org>

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
import org.kde.plasma.components as PlasmaComponents
import org.kde.draganddrop 2.0
import org.kde.ksvg as KSvg
import org.kde.kirigami 2.5 as Kirigami

import "code/tools.js" as Tools

Item {
    id: listItem

    enabled: !model.disabled

    width: ListView.view.width - Math.max(0, listRightInset)
    height: (Kirigami.Units.smallSpacing * 2) + Math.max(elementIcon.height, titleElement.implicitHeight + subTitleElement.implicitHeight)

    signal reset
    signal actionTriggered(string actionId, variant actionArgument)
    signal aboutToShowActionMenu(variant actionMenu)
    signal addBreadcrumb(var model, string title)

    readonly property int itemIndex: model.index
    readonly property string url: model.url || ""
    readonly property var decoration: model.decoration || ""

    property bool dropEnabled: false
    property bool appView: false
    property int listRightInset: 0
    property bool modelChildren: model.hasChildren || false
    property bool isCurrent: listItem.ListView.view.currentIndex === index;
    property bool showAppsByName: plasmoid.configuration.showAppsByName

    readonly property string favoriteIdValue: {
        if (model.favoriteId !== null && model.favoriteId !== undefined && model.favoriteId !== "") {
            return model.favoriteId;
        }
        if (url !== null && url !== undefined && url !== "") {
            return String(url);
        }
        return "";
    }
    readonly property bool hasFavoriteAction: favoriteIdValue.length > 0
    property bool hasActionList: true
    property Item menu: actionMenu
    property bool usePlasmaIcon: false
    readonly property bool categoryIconToggleEnabled: appView
        && model.hasChildren
        && plasmoid
        && plasmoid.configuration
    readonly property bool useSymbolicCategoryIcons: categoryIconToggleEnabled
        && plasmoid.configuration.symbolicCategoryIcons
    readonly property string iconNameCandidate: {
        if (typeof model.decorationName === "string" && model.decorationName.length > 0) {
            return model.decorationName;
        }
        if (typeof model.iconName === "string" && model.iconName.length > 0) {
            return model.iconName;
        }
        if (typeof model.icon === "string" && model.icon.length > 0) {
            return model.icon;
        }
        if (typeof decoration === "string" && decoration.length > 0) {
            return decoration;
        }
        return "";
    }
    readonly property var iconSource: {
        if (!categoryIconToggleEnabled) {
            return decoration;
        }

        if (iconNameCandidate.length === 0) {
            return decoration;
        }

        if (iconNameCandidate.indexOf("file:") === 0
            || iconNameCandidate.indexOf("qrc:") === 0
            || iconNameCandidate.indexOf("/") !== -1) {
            return iconNameCandidate;
        }

        var isSymbolicName = iconNameCandidate.length >= 9
            && iconNameCandidate.slice(-9) === "-symbolic";

        if (useSymbolicCategoryIcons) {
            if (isSymbolicName) {
                return iconNameCandidate;
            }
            return iconNameCandidate + "-symbolic";
        }

        // Force colorful category icons by stripping symbolic suffix when present.
        if (isSymbolicName) {
            return iconNameCandidate.slice(0, -9);
        }
        return iconNameCandidate;
    }

    onAboutToShowActionMenu: function(actionMenuObject) {
        // Safe mode: avoid native model.actionList entirely; it crashes in libkickerplugin on some Plasma 6 setups.
        var actionList = [{
            text: i18n("Open"),
            icon: "system-run",
            actionId: "_kickoffclassic_activate"
        }];
        var favoritesModel = null;
        if (ListView.view && ListView.view.model && ("favoritesModel" in ListView.view.model)) {
            favoritesModel = ListView.view.model.favoritesModel;
        }
        if (!favoritesModel && typeof globalFavorites !== "undefined" && globalFavorites) {
            favoritesModel = globalFavorites;
        }
        Tools.fillActionMenu(i18n, actionMenuObject, actionList, favoritesModel, hasFavoriteAction ? favoriteIdValue : null);
    }

    onActionTriggered: {
        if (actionId === "_kickoffclassic_activate") {
            listItem.activate();
            return;
        }

        if (Tools.triggerAction(ListView.view.model, model.index, actionId, actionArgument) === true) {
            plasmoid.expanded = false;
        }

        if (actionId.indexOf("_kicker_favorite_") === 0) {
            switchToInitial();
        }
    }

    function activate() {
        var view = listItem.ListView.view;

        if (model.hasChildren) {
            var childModel = view.model.modelForRow(index);

            listItem.addBreadcrumb(childModel, display);
            view.model = childModel;
        } else {
            view.model.trigger(index, "", null);
            plasmoid.expanded = false;
            listItem.reset();
        }
    }

    function openActionMenu(x, y) {
        aboutToShowActionMenu(actionMenu);
        actionMenu.open(x, y);
    }

    ActionMenu {
        id: actionMenu

        onActionClicked: {
            actionTriggered(actionId, actionArgument);
        }
    }

    Kirigami.Icon {
        id: elementIcon

        anchors {
            left: parent.left
            leftMargin: Kirigami.Units.smallSpacing * 6
            verticalCenter: parent.verticalCenter
        }
        width: Kirigami.Units.iconSizes.medium
        height: width

        source: listItem.iconSource
    }

    PlasmaComponents.Label {
        id: titleElement

        y: Math.round((parent.height - titleElement.height - ( (subTitleElement.text != "") ? subTitleElement.implicitHeight : 0) ) / 2)
        anchors {
            //bottom: elementIcon.verticalCenter
            left: elementIcon.right
            right: arrow.left
            leftMargin: Kirigami.Units.smallSpacing * 4
            rightMargin: Kirigami.Units.smallSpacing * 6
        }
        height: implicitHeight //undo PC2 height override, remove when porting to PC3
        // TODO: games should always show the by name!
        text: model.display
        elide: Text.ElideRight
        horizontalAlignment: Text.AlignLeft
    }

    PlasmaComponents.Label {
        id: subTitleElement

        anchors {
            left: titleElement.left
            right: arrow.right
            top: titleElement.bottom
        }
        height: implicitHeight

        text: model.description || ""
        opacity: isCurrent ? 0.8 : 0.6
        elide: Text.ElideMiddle
        horizontalAlignment: Text.AlignLeft
    }

    KSvg.SvgItem {
        id: arrow

        anchors {
            right: parent.right
            rightMargin: Kirigami.Units.smallSpacing * 6
            verticalCenter: parent.verticalCenter
        }

        width: visible ? Kirigami.Units.iconSizes.small : 0
        height: width

        visible: (model.hasChildren === true)
        opacity: (listItem.ListView.view.currentIndex === index) ? 1.0 : 0.4

        svg: arrowsSvg
        elementId: (Qt.application.layoutDirection == Qt.RightToLeft) ? "left-arrow" : "right-arrow"
    }

    Keys.onPressed: {
        if (event.key === Qt.Key_Menu && hasActionList) {
            event.accepted = true;
            openActionMenu();
        } else if ((event.key === Qt.Key_Enter || event.key === Qt.Key_Return) && !modelChildren) {
            if (!modelChildren) {
                event.accepted = true;
                listItem.activate();
            }
        }
    }
} // listItem
