import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import Logos.Theme
import Logos.Controls

// Sidebar with two filter sections: Categories on top, Types below,
// separated by a thin divider per Figma. Each section is independent —
// users can pick one category AND one type concurrently.
Item {
    id: root


    property list<string> categories: []
    property int currentIndex: 0

    property list<string> types: []
    property int currentTypeIndex: -1

    signal categorySelected(int index)
    signal typeSelected(int index)

    // Exposed for the ui-tests categories-scroll test. The tests also
    // drive scrollArea.contentY directly to bring a Types entry into
    // view: both sections live in this one Flickable, so a long
    // Categories list pushes the Types entries below the clipped
    // viewport, where a synthesised click lands on nothing.
    readonly property alias scrollArea: scrollArea
    readonly property bool overflowing: scrollArea.contentHeight > scrollArea.height

    objectName: "pmui.CategorySidebar"
    implicitWidth: 200
    implicitHeight: innerCol.implicitHeight

    Flickable {
        id: scrollArea
        objectName: "pmui.CategorySidebar.scrollArea"
        anchors.fill: parent
        clip: true
        contentWidth: width
        contentHeight: innerCol.implicitHeight
        boundsBehavior: Flickable.StopAtBounds
        ScrollBar.vertical: LogosScrollBar {
            policy: ScrollBar.AsNeeded
            visible: scrollArea.contentHeight > scrollArea.height
        }

        ColumnLayout {
            id: innerCol
            width: scrollArea.width
            spacing: Theme.spacing.tiny

            LogosText {
                Layout.topMargin: Theme.spacing.tiny
                Layout.bottomMargin: Theme.spacing.tiny
                text: qsTr("Categories")
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightRegular
                color: Theme.palette.text
            }

            ListView {
                id: categoriesView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                interactive: false
                spacing: Theme.spacing.tiny
                model: root.categories
                currentIndex: root.currentIndex

                delegate: SidebarNavItem {
                    // Addressable by the ui-tests: both sections are
                    // SidebarNavItems and a category can share a catalog
                    // type's label, so the index is the only unambiguous
                    // handle on a specific entry.
                    objectName: "pmui.CategorySidebar.category." + index
                    width: ListView.view.width
                    text: modelData
                    highlighted: ListView.isCurrentItem
                    onClicked: root.categorySelected(index)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacing.xlarge
                Layout.bottomMargin: Theme.spacing.xlarge
                height: 1
                color: Theme.palette.borderSubtle
            }

            LogosText {
                Layout.topMargin: Theme.spacing.tiny
                Layout.bottomMargin: Theme.spacing.tiny
                text: qsTr("Types")
                font.pixelSize: Theme.typography.subtitleText
                font.weight: Theme.typography.weightRegular
                color: Theme.palette.text
            }

            ListView {
                id: typesView
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                interactive: false
                spacing: Theme.spacing.tiny
                model: root.types
                currentIndex: root.currentTypeIndex

                delegate: SidebarNavItem {
                    objectName: "pmui.CategorySidebar.type." + index
                    width: ListView.view.width
                    text: modelData
                    highlighted: ListView.isCurrentItem
                    onClicked: root.typeSelected(index)
                }
            }
        }
    }

    component SidebarNavItem: LogosItemDelegate {
        id: cell
        radius: Theme.spacing.radiusLarge
        highlightColor: Theme.palette.backgroundButton
        hoverColor: "transparent"
        textColor: (cell.highlighted || cell.hovered)
                       ? Theme.palette.text
                       : Theme.palette.textTertiary
    }
}
