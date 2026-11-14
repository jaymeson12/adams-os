/*
 *  Copyright 2013 David Edmundson <davidedmundson@kde.org>
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
import QtQuick.Layouts 1.1
import QtQuick.Controls 2.5

import org.kde.iconthemes as KIconThemes
import org.kde.kirigami 2.5 as Kirigami

ColumnLayout {

    property string cfg_icon: (plasmoid.configuration.icon && plasmoid.configuration.icon.length > 0)
        ? plasmoid.configuration.icon
        : cfg_iconDefault
    property var cfg_favorites: []
    property var cfg_favoritesDefault: []
    property bool cfg_favoritesPortedToKAstats: false
    property bool cfg_favoritesPortedToKAstatsDefault: false
    property string cfg_iconDefault: "start-here-kde"
    property var cfg_menuItemsDefault: ["bookmark:t", "application:t", "computer:t", "used:t", "leave:t"]
    property bool cfg_showAppsByNameDefault: true
    property bool cfg_symbolicCategoryIconsDefault: false
    property bool cfg_switchTabsOnHoverDefault: true
    property var cfg_systemApplications: []
    property var cfg_systemApplicationsDefault: []
    property bool cfg_alphaSortDefault: false
    property string title: ""
    property alias cfg_switchTabsOnHover: switchTabsOnHoverCheckbox.checked
    property alias cfg_showAppsByName: showApplicationsByNameCheckbox.checked
    property alias cfg_symbolicCategoryIcons: symbolicCategoryIconsCheckbox.checked
    property alias cfg_alphaSort: alphaSort.checked
    property alias cfg_menuItems: configButtons.menuItems

    Item {
        Layout.preferredHeight: Kirigami.Units.smallSpacing * 2
    }

    Kirigami.FormLayout {
        RowLayout {
            Kirigami.FormData.label: i18n("Icon:")
            spacing: Kirigami.Units.smallSpacing

            Rectangle {
                Layout.preferredWidth: Kirigami.Units.iconSizes.large + Kirigami.Units.smallSpacing * 2
                Layout.preferredHeight: Layout.preferredWidth
                radius: Kirigami.Units.smallSpacing
                color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                border.width: 1
                border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.12)

                Kirigami.Icon {
                    anchors.fill: parent
                    anchors.margins: Kirigami.Units.smallSpacing
                    width: Kirigami.Units.iconSizes.large
                    height: width
                    source: cfg_icon
                }
            }

            TextField {
                id: iconNameField
                Layout.fillWidth: true
                text: cfg_icon
                placeholderText: i18n("Icon name")
                readOnly: true
            }

            Button {
                text: i18nc("@action:button Open icon chooser", "Choose...")
                onClicked: iconDialog.open()
            }

            Button {
                text: i18nc("@action:button Reset icon to default", "Reset")
                onClicked: {
                    cfg_icon = cfg_iconDefault;
                    iconNameField.text = cfg_icon;
                }
            }

            KIconThemes.IconDialog {
                id: iconDialog
                title: i18n("Choose Icon")
                onIconNameChanged: {
                    if (iconName && iconName.length > 0) {
                        cfg_icon = iconName;
                        iconNameField.text = iconName;
                    }
                }
            }
        }

        Item {
            Kirigami.FormData.isSection: true
        }

        CheckBox {
            id: switchTabsOnHoverCheckbox

            Kirigami.FormData.label: i18n("General:")

            text: i18n("Switch tabs on hover")
        }

        CheckBox {
            id: showApplicationsByNameCheckbox
            text: i18n("Show applications by name")
        }

        CheckBox {
            id: symbolicCategoryIconsCheckbox
            text: i18n("Use symbolic category icons")
        }

        CheckBox {
            id: alphaSort
            text: i18n("Sort alphabetically")
        }
    }

    Label {
        Layout.fillWidth: true
        text: i18n("Drag tabs between the boxes to show/hide them, or reorder the visible tabs by dragging.")
        wrapMode: Text.WordWrap
        horizontalAlignment: Text.AlignHCenter
    }
    ConfigButtons {
        id: configButtons
        Layout.alignment: Qt.AlignHCenter
    }

    Item {
        Layout.fillHeight: true
    }
}
