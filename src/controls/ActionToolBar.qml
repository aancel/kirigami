/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as Controls
import org.kde.kirigami 2.14 as Kirigami
import "private"

/**
 * @brief This is a simple toolbar built out of a list of actions.
 *
 * In the ActionToolBar, each action is represented by a QtQuick.Controls.ToolButton.
 * The ActionToolBar component will try to display has many actions as possible but
 * those that won't fit will go in a an overflow manu.
 *
 * @inherit QtQuick.Controls.Control
 * @since 2.5
 */
Controls.Control {
    id: root
    /**
     * @brief This property holds a list of action that will appear in the ActionToolBar.
     * The ActionToolBar component will try to display has many of these actions as possible
     * as a list of ToolButton but those that won't fit will go in a an overflow manu.
     *
     * @property list<Action> ActionToolBar::actions
     */
    property alias actions: layout.actions

    /**
     * This property holds a list of actions that will always be displayed in the overflow
     * menu even if there is enough place.
     *
     * @since 2.6
     * @property list<Action> ActionToolBar::hiddenActions
     * @deprecated since 2.14, use the AlwaysHide hint on actions instead.
     */
    property list<QtObject> hiddenActions
    onHiddenActionsChanged: print("ActionToolBar::hiddenActions is deprecated, use the AlwaysHide hint on your actions instead")

    /**
     * This property holds whether we want our buttons to have a flat appearance.
     *
     * By default action will be using flat QtQuick.Controls.ToolButton.
     */
    property bool flat: true

    /**
     * This property holds the controls the label position regarding the icon.
     *
     * It is the same value to control individual Button components, permitted values are:
     *
     * * `Button.IconOnly`
     * * `Button.TextOnly`
     * * `Button.TextBesideIcon`
     * * `Button.TextUnderIcon`
     */
    property int display: Controls.Button.TextBesideIcon

    /**
     * This property holds the alignment of the buttons.
     *
     * When there is more space available than required by the visible delegates,
     * we need to determine how to place the delegates. This property determines
     * how to do that.
     *
     * @property Qt::Alignment alignment
     */
    property alias alignment: layout.alignment

    /**
     * This property holds the position of the toolbar.
     *
     * If this ActionToolBar is the contentItem of a QQC2 Toolbar, the position is binded to the ToolBar's position
     *
     * Permitted values are:
     *
     * * ToolBar.Header: The toolbar is at the top, as a window or page header.
     * * ToolBar.Footer: The toolbar is at the bottom, as a window or page footer.
     */
    property int position: parent && parent.hasOwnProperty("position")
            ? parent.position
            : Controls.ToolBar.Header

    /**
     * This property holds the maximum with of the content of this ToolBar.
     *
     * If the toolbar's width is larger than this value, empty space will
     * be added on the sides, according to the Alignment property.
     *
     * The value of this property is derived from the ToolBar's actions and their properties.
     *
     * @property int maximumContentWidth
     */
    readonly property alias maximumContentWidth: layout.implicitWidth

    /**
     * This property holds the name of the icon to use for the overflow menu button.
     *
     * @since 5.65
     * @since 2.12
     */
    property string overflowIconName: "overflow-menu"

    /**
     * This property holds the combined width of the visible delegates.
     *
     * @property int visibleWidth
     */
    property alias visibleWidth: layout.visibleWidth

    /**
     * This property exposes the heightMode of the internal layout.
     *
     * \sa ToolBarLayout::heightMode
     */
    property alias heightMode: layout.heightMode

    implicitHeight: layout.implicitHeight
    implicitWidth: layout.implicitWidth

    Layout.minimumWidth: layout.minimumWidth
    Layout.preferredWidth: 0
    Layout.fillWidth: true

    leftPadding: 0
    rightPadding: 0
    topPadding: 0
    bottomPadding: 0

    contentItem: Kirigami.ToolBarLayout {
        id: layout
        spacing: Kirigami.Units.smallSpacing
        layoutDirection: root.LayoutMirroring.enabled ? Qt.RightToLeft : Qt.LeftToRight

        fullDelegate: PrivateActionToolButton {
            flat: root.flat
            display: root.display
            action: Kirigami.ToolBarLayout.action
        }

        iconDelegate: PrivateActionToolButton {
            flat: root.flat
            display: Controls.Button.IconOnly
            action: Kirigami.ToolBarLayout.action

            showMenuArrow: false

            menuActions: {
                if (action.displayComponent) {
                    return [action]
                }

                if (action.children) {
                    return Array.prototype.map.call(action.children, i => i)
                }

                return []
            }
        }

        moreButton: PrivateActionToolButton {
            flat: root.flat

            action: Kirigami.Action {
                tooltip: qsTr("More Actions")
                icon.name: root.overflowIconName
                displayHint: Kirigami.DisplayHint.IconOnly | Kirigami.DisplayHint.HideChildIndicator
            }

            menuActions: {
                if (root.hiddenActions.length == 0) {
                    return root.actions
                } else {
                    result = []
                    result.concat(Array.prototype.map.call(root.actions, (i) => i))
                    result.concat(Array.prototype.map.call(hiddenActions, (i) => i))
                    return result
                }
            }

            menuComponent: ActionsMenu {
                submenuComponent: ActionsMenu {
                    Binding {
                        target: parentItem
                        property: "visible"
                        value: layout.hiddenActions.includes(parentAction)
                               && (parentAction.visible === undefined || parentAction.visible)
                    }
                }

                itemDelegate: ActionMenuItem {
                    visible: layout.hiddenActions.includes(action)
                             && (action.visible === undefined || action.visible)
                }

                loaderDelegate: Loader {
                    property var action
                    height: visible ? implicitHeight : 0
                    visible: layout.hiddenActions.includes(action)
                             && (action.visible === undefined || action.visible)
                }

                separatorDelegate: Controls.MenuSeparator {
                    property var action
                    visible: layout.hiddenActions.includes(action)
                             && (action.visible === undefined || action.visible)
                }
            }
        }
    }
}
