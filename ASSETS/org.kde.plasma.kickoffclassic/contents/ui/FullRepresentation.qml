/*
    Copyright (C) 2011  Martin Gräßlin <mgraesslin@kde.org>
    Copyright (C) 2012  Gregor Taetzner <gregor@freenet.de>
    Copyright (C) 2012  Marco Martin <mart@kde.org>
    Copyright (C) 2013 2014 David Edmundson <davidedmundson@kde.org>
    Copyright 2014 Sebastian Kügler <sebas@kde.org>

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
import QtQuick 2.3
import QtQuick.Layouts 1.1
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.kquickcontrolsaddons 2.0
import org.kde.kirigami 2.5 as Kirigami
import org.kde.ksvg as KSvg
import org.kde.plasma.plasma5support as Plasma5Support

import org.kde.plasma.private.kicker 0.1 as Kicker

Item {
    id: root
    implicitWidth: Kirigami.Units.gridUnit * 26
    implicitHeight: Kirigami.Units.gridUnit * 34
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Layout.minimumWidth: implicitWidth
    Layout.minimumHeight: implicitHeight

    readonly property QtObject applet: (typeof plasmoid !== "undefined") ? plasmoid : null
    property string previousState
    property Item currentView: mainTabGroup.currentTab.decrementCurrentIndex ? mainTabGroup.currentTab : mainTabGroup.currentTab.item
    property KickoffButton firstButton: null
    property var configMenuItems

    property QtObject globalFavorites: rootModelFavorites

    state: "Normal"

    onFocusChanged: {
        header.input.forceActiveFocus();
    }

    function switchToInitial() {
        if (firstButton != null) {
            root.state = "Normal";
            activateTabButton(firstButton);
            header.query = ""
        }
    }

    function activateTabButton(button) {
        if (!button) {
            return;
        }
        if (button.tab) {
            mainTabGroup.currentTab = button.tab;
        }
        tabBar.currentTab = button;
    }

    Kicker.DragHelper {
        id: dragHelper

        dragIconSize: Kirigami.Units.iconSizes.medium
        onDropped: kickoff.dragSource = null
    }

    Kicker.AppsModel {
        id: rootModel

        autoPopulate: false

        appletInterface: applet

        appNameFormat: applet && applet.configuration && applet.configuration.showAppsByName ? 0 : 1
        flat: false
        sorted: applet && applet.configuration ? applet.configuration.alphaSort : false
        showSeparators: false
        showTopLevelItems: true

        favoritesModel: Kicker.KAStatsFavoritesModel {
            id: rootModelFavorites
            favorites: applet && applet.configuration ? applet.configuration.favorites : ""

            onFavoritesChanged: {
                if (applet && applet.configuration) {
                    applet.configuration.favorites = favorites;
                }
            }
        }

        Component.onCompleted: {
            favoritesModel.initForClient("org.kde.plasma.kickoff.favorites.instance-" + (applet ? applet.id : "0"))

            if (applet && applet.configuration && !applet.configuration.favoritesPortedToKAstats) {
                favoritesModel.portOldFavorites(applet.configuration.favorites);
                applet.configuration.favoritesPortedToKAstats = true;
            }

            rootModel.refresh();
        }
    }

    Plasma5Support.DataSource {
        id: pmSource
        engine: "powermanagement"
        connectedSources: ["PowerDevil"]
    }

    KSvg.Svg {
        id: arrowsSvg

        imagePath: "widgets/arrows"
        size: "16x16"
    }

    Header {
        id: header
    }

    Item {
        id: mainArea
        clip: true
        anchors.topMargin: mainTabGroup.state == "top" ? Kirigami.Units.smallSpacing : 0

        Item {
            id: mainTabGroup
            property Item currentTab: favoritesPage

            anchors {
                fill: parent
            }

            //pages
            FavoritesView {
                id: favoritesPage
                anchors.fill: parent
                visible: mainTabGroup.currentTab === favoritesPage
            }
            Loader {
                id: applicationsPage
                anchors.fill: parent
                active: mainTabGroup.currentTab == applicationsPage
                visible: active
                source: Qt.resolvedUrl("ApplicationsView.qml")
            }
            Loader {
                id: systemPage
                anchors.fill: parent
                active: mainTabGroup.currentTab == systemPage
                visible: active
                source: Qt.resolvedUrl("ComputerView.qml")
            }
            Loader {
                id: recentlyUsedPage
                anchors.fill: parent
                active: mainTabGroup.currentTab == recentlyUsedPage
                visible: active
                source: Qt.resolvedUrl("RecentlyUsedView.qml")
            }
            Loader {
                id: leavePage
                anchors.fill: parent
                active: mainTabGroup.currentTab == leavePage
                visible: active
                source: Qt.resolvedUrl("LeaveView.qml")
            }
            Loader {
                id: searchPage
                anchors.fill: parent
                active: root.state == "Search"
                visible: active
                //when: mainTabGroup.currentTab == searchPage || root.state == "Search"
                source: Qt.resolvedUrl("SearchView.qml")
            }

            state: {
                if (!applet) {
                    return "bottom";
                }
                switch (applet.location) {
                case PlasmaCore.Types.LeftEdge:
                    return LayoutMirroring.enabled ? "right" : "left";
                case PlasmaCore.Types.TopEdge:
                    return "top";
                case PlasmaCore.Types.RightEdge:
                    return LayoutMirroring.enabled ? "left" : "right";
                case PlasmaCore.Types.BottomEdge:
                default:
                    return "bottom";
                }
            }
            states: [
                State {
                    name: "left"
                    AnchorChanges {
                        target: header
                        anchors {
                            left: root.left
                            top: undefined
                            right: root.right
                            bottom: root.bottom
                        }
                    }
                    PropertyChanges {
                        target: header
                        width: header.implicitWidth
                    }
                    AnchorChanges {
                        target: mainArea
                        anchors {
                            left: tabBar.right
                            top: root.top
                            right: root.right
                            bottom: header.top
                        }
                    }
                    PropertyChanges {
                        target: tabBar
                        width: (tabBar.opacity == 0) ? 0 : Kirigami.Units.gridUnit * 6
                    }
                    AnchorChanges {
                        target: tabBar
                        anchors {
                            left: root.left
                            top: root.top
                            right: undefined
                            bottom: header.top
                        }
                    }
                    PropertyChanges {
                        target:tabBarSeparator
                        width: tabBarSeparatorLine.elementSize("vertical-line").width
                        elementId: "vertical-line"
                    }
                    AnchorChanges {
                        target: tabBarSeparator
                        anchors {
                            left: tabBar.right
                            top: tabBar.top
                            bottom:tabBar.bottom
                        }
                    }
                },
                State {
                    name: "top"
                    AnchorChanges {
                        target: header
                        anchors {
                            left: root.left
                            top: undefined
                            right: root.right
                            bottom: root.bottom
                        }
                    }
                    PropertyChanges {
                        target: header
                        height: header.implicitHeight
                    }
                    AnchorChanges {
                        target: mainArea
                        anchors {
                            left: root.left
                            top: tabBar.bottom
                            right: root.right
                            bottom: header.top
                        }
                    }
                    PropertyChanges {
                        target: tabBar
                        height: (tabBar.opacity == 0) ? 0 : Kirigami.Units.gridUnit * 5
                    }
                    AnchorChanges {
                        target: tabBar
                        anchors {
                            left: root.left
                            top: root.top
                            right: root.right
                            bottom: undefined
                        }
                    }
                    PropertyChanges {
                        target:tabBarSeparator
                        height: tabBarSeparatorLine.elementSize("horizontal-line").height
                        elementId: "horizontal-line"
                    }
                    AnchorChanges {
                        target: tabBarSeparator
                        anchors {
                            left: tabBar.left
                            right: tabBar.right
                            top: tabBar.bottom
                        }
                    }
                },
                State {
                    name: "right"
                    AnchorChanges {
                        target: header
                        anchors {
                            left: root.left
                            top: undefined
                            right: root.right
                            bottom: root.bottom
                        }
                    }
                    PropertyChanges {
                        target: header
                        width: header.implicitWidth
                    }
                    AnchorChanges {
                        target: mainArea
                        anchors {
                            left: root.left
                            top: root.top
                            right: tabBar.left
                            bottom: header.top
                        }
                    }
                    PropertyChanges {
                        target: tabBar
                        width: (tabBar.opacity == 0) ? 0 : Kirigami.Units.gridUnit * 6
                    }
                    AnchorChanges {
                        target: tabBar
                        anchors {
                            left: undefined
                            top: root.top
                            right: root.right
                            bottom: header.top
                        }
                    }
                    PropertyChanges {
                        target:tabBarSeparator
                        width: tabBarSeparatorLine.elementSize("vertical-line").width
                        elementId: "vertical-line"
                    }
                    AnchorChanges {
                        target: tabBarSeparator
                        anchors {
                            right: tabBar.left
                            top: tabBar.top
                            bottom: tabBar.bottom
                        }
                    }
                },
                State {
                    name: "bottom"
                    AnchorChanges {
                        target: header
                        anchors {
                            left: root.left
                            top: root.top
                            right: root.right
                            bottom: undefined
                        }
                    }
                    PropertyChanges {
                        target: header
                        height: header.implicitHeight
                    }
                    AnchorChanges {
                        target: mainArea
                        anchors {
                            left: root.left
                            top: header.bottom
                            right: root.right
                            bottom: tabBar.top
                        }
                    }
                    PropertyChanges {
                        target: tabBar
                        height: (tabBar.opacity == 0) ? 0 : Kirigami.Units.gridUnit * 5
                    }
                    AnchorChanges {
                        target: tabBar
                        anchors {
                            left: root.left
                            top: undefined
                            right: root.right
                            bottom: root.bottom
                        }
                    }
                    PropertyChanges {
                        target:tabBarSeparator
                        height: tabBarSeparatorLine.elementSize("horizontal-line").height
                        elementId: "horizontal-line"
                    }
                    AnchorChanges {
                        target: tabBarSeparator
                        anchors {
                            bottom: tabBar.top
                            left: tabBar.left
                            right: tabBar.right
                        }
                    }
                }
            ]
        } // mainTabGroup
    }

    Item {
        id: tabBar

        property int count: 5 // updated in createButtons()
        property Item currentTab: null
        readonly property bool vertical: applet && (applet.location === PlasmaCore.Types.LeftEdge
            || applet.location === PlasmaCore.Types.RightEdge)
        readonly property Item layout: vertical ? verticalLayout : horizontalLayout

        Behavior on width {
            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InQuad; }
            enabled: kickoff.expanded
        }
        Behavior on height {
            NumberAnimation { duration: Kirigami.Units.longDuration; easing.type: Easing.InQuad; }
            enabled: kickoff.expanded
        }

        onCurrentTabChanged: header.input.forceActiveFocus();

        Row {
            id: horizontalLayout
            anchors.fill: parent
            visible: !tabBar.vertical
            spacing: 0
        }

        Column {
            id: verticalLayout
            anchors.fill: parent
            visible: tabBar.vertical
            spacing: 0
        }

        Connections {
            target: kickoff
            ignoreUnknownSignals: true
            function onExpandedChanged() {
                if(menuItemsChanged()) {
                    createButtons();
                }
                if (!kickoff.expanded) {
                    switchToInitial();
                }
            }
        }
    } // tabBar

    KSvg.SvgItem {
        id: tabBarSeparator
        svg: KSvg.Svg {
            id: tabBarSeparatorLine
            imagePath: "widgets/line"
        }
    }

    MouseArea {
        anchors.fill: tabBar

        property var oldPos: null

        enabled: true
        hoverEnabled: applet && applet.configuration ? applet.configuration.switchTabsOnHover : false

        onExited: {
            // Reset so we switch immediately when MouseArea is entered
            // freshly, e.g. from the panel.
            oldPos = null;

            clickTimer.stop();
        }

        onPositionChanged: function(mouse) {
            // Reject multiple events with the same coordinates that QQuickWindow
            // synthesizes.
            if (oldPos === Qt.point(mouse.x, mouse.y)) {
                return;
            }

            var button = tabBar.layout.childAt(mouse.x, mouse.y);

            if (!button || button.objectName !== "KickoffButton") {
                clickTimer.stop();

                return;
            }

            // Switch immediately when MouseArea was freshly entered, e.g.
            // from the panel.
            if (oldPos === null) {
                oldPos = Qt.point(mouse.x, mouse.y);

                clickTimer.stop();
                activateTabButton(button);

                return;
            }

            var dx  = (mouse.x - oldPos.x);
            var dy  = (mouse.y - oldPos.y);

            // Check Manhattan length against drag distance to get a decent
            // pointer motion vector.
            if ((Math.abs(dx) + Math.abs(dy)) > Qt.styleHints.startDragDistance) {
                if (tabBar.currentTab !== button) {
                    var tabBarPos = mapToItem(tabBar, oldPos.x, oldPos.y);
                    oldPos = Qt.point(mouse.x, mouse.y);

                    var angleMouseMove = Math.atan2(dy, dx) * 180 / Math.PI;
                    var angleToCornerA = 0;
                    var angleToCornerB = 0;

                    switch (applet ? applet.location : PlasmaCore.Types.BottomEdge) {
                        case PlasmaCore.Types.TopEdge: {
                            angleToCornerA = Math.atan2(tabBar.height - tabBarPos.y, 0 - tabBarPos.x);
                            angleToCornerB = Math.atan2(tabBar.height - tabBarPos.y, tabBar.width - tabBarPos.x);

                            break;
                        }
                        case PlasmaCore.Types.LeftEdge: {
                            angleToCornerA = Math.atan2(0 - tabBarPos.y, tabBar.width - tabBarPos.x);
                            angleToCornerB = Math.atan2(tabBar.height - tabBarPos.y, tabBar.width - tabBarPos.x);

                            break;
                        }
                        case PlasmaCore.Types.RightEdge: {
                            angleToCornerA = Math.atan2(0 - tabBarPos.y, 0 - tabBarPos.x);
                            angleToCornerB = Math.atan2(tabBar.height - tabBarPos.y, 0 - tabBarPos.x);

                            break;
                        }
                        // PlasmaCore.Types.BottomEdge
                        default: {
                            angleToCornerA = Math.atan2(0 - tabBarPos.y, 0 - tabBarPos.x);
                            angleToCornerB = Math.atan2(0 - tabBarPos.y, tabBar.width - tabBarPos.x);
                        }
                    }

                    // Degrees are nicer to debug than radians.
                    angleToCornerA = angleToCornerA * 180 / Math.PI;
                    angleToCornerB = angleToCornerB * 180 / Math.PI;

                    var lower = Math.min(angleToCornerA, angleToCornerB);
                    var upper = Math.max(angleToCornerA, angleToCornerB);

                    // If the motion vector is outside the angle range from oldPos to the
                    // relevant tab bar corners, switch immediately. Otherwise start the
                    // timer, which gets aborted should the pointer exit the tab bar
                    // early.
                    var inRange = (lower < angleMouseMove == angleMouseMove < upper);

                    // Mirror-flip.
                    if ((applet && applet.location === PlasmaCore.Types.RightEdge) ? inRange : !inRange) {
                        clickTimer.stop();
                        activateTabButton(button);

                        return;
                    } else {
                        clickTimer.pendingButton = button;
                        clickTimer.start();
                    }
                } else {
                    oldPos = Qt.point(mouse.x, mouse.y);
                }
            }
        }

        onClicked: function(mouse) {
            clickTimer.stop();

            var button = tabBar.layout.childAt(mouse.x, mouse.y);

            if (!button || button.objectName !== "KickoffButton") {
                return;
            }

            activateTabButton(button);
        }

        Timer {
            id: clickTimer

            property Item pendingButton: null

            interval: 250

            onTriggered: {
                if (pendingButton) {
                    activateTabButton(pendingButton);
                }
            }
        }
    }

    Keys.forwardTo: [tabBar.layout]

    Keys.onPressed: {

        if (mainTabGroup.currentTab == applicationsPage) {
            if (event.key !== Qt.Key_Tab) {
                root.state = "Applications";
            }
        }

        switch(event.key) {
            case Qt.Key_Up: {
                currentView.decrementCurrentIndex();
                event.accepted = true;
                break;
            }
            case Qt.Key_Down: {
                currentView.incrementCurrentIndex();
                event.accepted = true;
                break;
            }
            case Qt.Key_Left: {
                if (header.input.focus && header.state == "query") {
                    break;
                }
                if (!currentView.deactivateCurrentIndex()) {
                    if (root.state == "Applications") {
                        mainTabGroup.currentTab = firstButton.tab;
                        tabBar.currentTab = firstButton;
                    }
                    root.state = "Normal"
                }
                event.accepted = true;
                break;
            }
            case Qt.Key_Right: {
                if (header.input.focus && header.state == "query") {
                    break;
                }
                currentView.activateCurrentIndex();
                event.accepted = true;
                break;
            }
            case Qt.Key_Tab: {
                root.state == "Applications" ? root.state = "Normal" : root.state = "Applications";
                event.accepted = true;
                break;
            }
            case Qt.Key_Enter:
            case Qt.Key_Return: {
                currentView.activateCurrentIndex(1);
                event.accepted = true;
                break;
            }
            case Qt.Key_Escape: {
                if (header.state != "query") {
                    if (applet) {
                        applet.expanded = false;
                    }
                } else {
                    header.query = "";
                }
                event.accepted = true;
                break;
            }
            case Qt.Key_Menu: {
                currentView.openContextMenu();
                event.accepted = true;
                break;
            }
            default:
                if (!header.input.focus) {
                    header.input.forceActiveFocus();
                }
        }
    }

    states: [
        State {
            name: "Normal"
            PropertyChanges {
                target: root
                Keys.forwardTo: [tabBar.layout]
            }
            PropertyChanges {
                target: tabBar
                //Set the opacity and NOT the visibility, as visibility is recursive
                //and this binding would be executed also on popup show/hide
                //as recommended by the docs: https://doc.qt.io/qt-5/qml-qtquick-item.html#visible-prop
                //plus, it triggers https://bugreports.qt.io/browse/QTBUG-66907
                //in which a mousearea may think it's under the mouse while it isn't
                opacity: tabBar.count > 1 ? 1 : 0
            }
        },
        State {
            name: "Applications"
            PropertyChanges {
                target: root
                Keys.forwardTo: [root]
            }
            PropertyChanges {
                target: tabBar
                opacity: tabBar.count > 1 ? 1 : 0
            }
        },
        State {
            name: "Search"
            PropertyChanges {
                target: tabBar
                opacity: 0
            }
            PropertyChanges {
                target: mainTabGroup
                currentTab: searchPage
            }
            PropertyChanges {
                target: root
                Keys.forwardTo: [root]
            }
        }
    ] // states

    function getButtonDefinition(name) {
        switch(name) {
        case "bookmark":
            return {tab: favoritesPage, iconSource: "favorite-symbolic", labelText: i18n("Favorites")};
        case "application":
            return {tab: applicationsPage, iconSource: "applications-all-symbolic", labelText: i18n("Applications")};
        case "computer":
            return {tab: systemPage, iconSource: "computer-symbolic", labelText: i18n("Computer")};
        case "used":
            return {tab: recentlyUsedPage, iconSource: "view-history-symbolic", labelText: i18n("History")};
        case "leave":
            return {tab: leavePage, iconSource: "system-log-out-symbolic", labelText: i18n("Leave")};
        }
    }

    Component {
        id: kickoffButton
        KickoffButton {}
    }


    Component.onCompleted: {
        createButtons();
    }

    function getEnabled(configuration) {
        var res = [];
        for(var i = 0; i < configuration.length; i++) {
            var confItemName = configuration[i].substring(0, configuration[i].indexOf(":"));
            var confItemEnabled = configuration[i].substring(configuration[i].length-1) === "t";
            if(confItemEnabled && getButtonDefinition(confItemName)) {
                res.push(confItemName);
            }
        }

        return res;
    }

    function createButtons() {
        if (!applet || !applet.configuration) {
            return;
        }
        configMenuItems = applet.configuration.menuItems;
        var menuItems = getEnabled(applet.configuration.menuItems);
        tabBar.count = menuItems.length

        // remove old menu items
        for(var i = tabBar.layout.children.length -1; i >= 0; i--)  {
            if(tabBar.layout.children[i].objectName === "KickoffButton") {
                tabBar.layout.children[i].destroy();
            }
        }

        for (var i = 0; i < menuItems.length; i++) {
             var props = getButtonDefinition(menuItems[i]);
             if (!props) {
                 continue;
             }
             props.tabGroup = mainTabGroup;
             props.tabBar = tabBar;
             props.width = Qt.binding(function() {
                 return tabBar.vertical
                     ? tabBar.layout.width
                     : tabBar.layout.width / Math.max(1, tabBar.count);
             });
             props.height = Qt.binding(function() {
                 return tabBar.vertical
                     ? tabBar.layout.height / Math.max(1, tabBar.count)
                     : tabBar.layout.height;
             });
             var button = kickoffButton.createObject(tabBar.layout, props);
             if(i === 0) {
                 firstButton = button;
                 switchToInitial();
             }
        }

    }

    function menuItemsChanged() {
        if (!applet || !applet.configuration) {
            return false;
        }
        if(configMenuItems.length !== applet.configuration.menuItems.length) {
            return true;
        }

        for(var i = 0; i < configMenuItems.length; i++) {
            if(configMenuItems[i] !== applet.configuration.menuItems[i]) {
                return true;
            }
        }
        return false;
    }
}
