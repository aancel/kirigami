/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.15 as Controls
import QtGraphicalEffects 1.12
import org.kde.kirigami 2.12 as Kirigami
import "templates/private" as Private

/**
 * Popup dialog that is used for short tasks and user interaction.
 * 
 * Dialog consists of three components: the header, the content, 
 * and the footer.
 * 
 * By default, the header is a heading with text specified by the 
 * `title` property.
 * 
 * By default, the footer consists of a row of buttons specified by 
 * the `footerActions` and `customFooterActions` properties.
 * 
 * The `implicitHeight` and `implicitWidth` of the dialog contentItem is 
 * the primary hint used for the dialog size. The dialog will be the 
 * minimum size required for the header, footer and content unless 
 * it is larger than `maximumHeight` and `maximumWidth`. Use
 * `preferredHeight` and `preferredWidth` in order to manually specify
 * a size for the dialog.
 * 
 * If the content height exceeds the maximum height of the dialog, the 
 * dialog's contents will become scrollable.
 * 
 * If the contentItem is a ListView, the dialog will take care of the
 * necessary scrollbars and scrolling behaviour.
 * 
 * Example for a selection dialog:
 * 
 * @code{.qml}
 * import QtQuick 2.15
 * import QtQuick.Layouts 1.2
 * import QtQuick.Controls 2.15 as Controls
 * import org.kde.kirigami 2.18 as Kirigami
 * 
 * Kirigami.Dialog {
 *     title: i18n("Dialog")
 *     padding: 0
 * 
 *     footerActions: Kirigami.Dialog.Actions.Ok | Kirigami.Dialog.Actions.Cancel
 * 
 *     onAccepted: console.log("OK button pressed")
 *     onRejected: console.log("Cancel button pressed")
 * 
 *     ColumnLayout {
 *         Repeater {
 *             model: 5
 *             delegate: Controls.CheckDelegate {
 *                 topPadding: Kirigami.Units.smallSpacing * 2
 *                 bottomPadding: Kirigami.Units.smallSpacing * 2
 *                 implicitWidth: Kirigami.Units.gridUnit * 16
 *                 text: modelData
 *             }
 *         }
 *     }
 * }
 * @endcode
 * 
 * Example with scrolling (ListView scrolling behaviour is handled by Dialog):
 * 
 * @code{.qml}
 * Kirigami.ScrollableDialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *     
 *     ListView {
 *         // hints for the dialog dimensions
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *         
 *         model: 100
 *         delegate: Controls.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: Kirigami.Units.gridUnit * 16
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 * 
 * There are also sub-components of Dialog that target specific usecases, 
 * and can reduce boilerplate code if used:
 * 
 * @see PromptDialog
 * @see MenuDialog
 * 
 * @inherit QtQuick.QtObject
 */
QtObject {
    id: root
    
    /**
     * The dialog's contents.
     * 
     * The initial height and width of the dialog is calculated from the 
     * `implicitWidth` and `implicitHeight` of this item.
     */
    default property Item contentItem
    
    /**
     * The absolute maximum height the dialog can be (including the header 
     * and footer).
     * 
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * This is the window height, subtracted by largeSpacing on both the top 
     * and bottom.
     */
    readonly property real absoluteMaximumHeight: dialog.parent.height - Kirigami.Units.largeSpacing * 2
    
    /**
     * The absolute maximum width the dialog can be.
     * 
     * By default, it is the window width, subtracted by largeSpacing on both 
     * the top and bottom.
     */
    readonly property real absoluteMaximumWidth: dialog.parent.width - Kirigami.Units.largeSpacing * 2
    
    /**
     * The maximum height the dialog can be (including the header 
     * and footer).
     * 
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     * 
     * By default, this is `absoluteMaximumHeight`.
     */
    property real maximumHeight: absoluteMaximumHeight
    
    /**
     * The maximum width the dialog can be.
     * 
     * By default, this is `absoluteMaximumWidth`.
     */
    property real maximumWidth: absoluteMaximumWidth
    
    /**
     * The current height of the dialog.
     * 
     * It is not recommended to set the height of the dialog here, set 
     * `preferredHeight` or the content's `implicitHeight` instead.
     */
    property alias height: dialog.height
    
    /**
     * The current width of the dialog.
     * 
     * It is not recommended to set the width of the dialog here, set 
     * `preferredWidth` or the content's `implicitWidth` instead.
     */
    property alias width: dialog.width
    
    /**
     * Specify the preferred height of the dialog.
     * 
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     * 
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1
    
    /**
     * Specify the preferred width of the dialog.
     * 
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     * 
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1
    
    /**
     * The implicit height of the dialog's header, footer and contents together.
     */
    readonly property alias implicitHeight: column.implicitHeight
    
    /**
     * The implicit width of the dialog's header, footer and contents together.
     */
    readonly property alias implicitWidth: column.implicitWidth
    
    /**
     * The text to show in the dialog header.
     * 
     * The text is a single line, if it goes beyond the width of the dialog 
     * header, it will be elided.
     * 
     * Note: This is ignored if a custom header is set.
     */
    property string title: ""
    
    /**
     * Dialog.Actions provides pre-built footer buttons for use with 
     * the footerActions property.
     * 
     * Clicking each action closes the dialog, and also either triggers
     * the `accepted()` or `rejected()` signal.
     *
     * To specify custom footer buttons, see the `customFooterActions` property.
     *
     * * `None`
     * * `Ok` - triggers accepted() signal
     * * `Cancel` - triggers rejected() signal
     * * `Close` - triggers accepted() signal
     * * `Done` - triggers accepted() signal
     * * `Save` - triggers accepted() signal
     * * `Apply` - triggers accepted() signal
     * * `Yes` - triggers accepted() signal
     * * `No` - triggers rejected() signal
     */
    enum Actions {
        None = 0,
        Ok = 1,
        Cancel = 2,
        Close = 4,
        Done = 8,
        Save = 16,
        Apply = 32,
        Yes = 64,
        No = 128
    }
    
    /**
     * The actions provided in the footer.
     * 
     * If you would like to define custom actions, see `customFooterActions`.
     * 
     * Note: this is ignored if a custom footer is set.
     * 
     * Suggested pairings:
     * * `Dialog.Actions.Ok` | `Dialog.Actions.Cancel`
     * * `Dialog.Actions.Yes` | `Dialog.Actions.No`
     * * `Dialog.Actions.Save` | `Dialog.Actions.Cancel`
     * * `Dialog.Actions.Apply` | `Dialog.Actions.Cancel`
     * * `Dialog.Actions.Done`
     * * `Dialog.Actions.Close`
     * * `Dialog.Actions.None`
     */
    property int footerActions: Dialog.Actions.Close
    
    /**
     * Define a list of custom actions in the footer.
     * 
     * If `footerActions` is not `Dialog.Actions.None`, then the footer actions
     * will be displayed after the `customFooterActions` in the row.
     * 
     * Note: this is ignored if a custom footer is set.
     * 
     * @code{.qml}
     * import QtQuick 2.15
     * import QtQuick.Controls 2.15 as Controls
     * import org.kde.kirigami 2.18 as Kirigami
     * 
     * Kirigami.PromptDialog {
     *     id: dialog
     *     title: i18n("Confirm Playback")
     *     subtitle: i18n("Are you sure you want to play this song? It's really loud!")
     * 
     *     footerActions: Kirigami.Dialog.Actions.Cancel
     *     customFooterActions: [
     *         Kirigami.Action {
     *             text: i18n("Play")
     *             iconName: "media-playback-start"
     *             onTriggered: {
     *                 //...
     *                 dialog.close();
     *             }
     *         }
     *     ]
     * }
     * @endcode
     * 
     * @see Action
     */
    property list<Action> customFooterActions
    
    /**
     * The label used for the `title` property.
     */
    property alias headerLabel: heading
    
    /**
     * The header of the dialog.
     * 
     * Specifying a custom header will remove the label used in the 
     * `title` property.
     * 
     * When specifying a custom header item, be sure to set an 
     * `implicitHeight` and `implicitWidth`, as it will be used in 
     * dialog calculations.
     * 
     * If you simply do not want a header, set the property to null.
     */
    property Item header: Controls.Control {
        // needs to explicitly be set for each side to work
        topPadding: Kirigami.Units.largeSpacing
        bottomPadding: Kirigami.Units.largeSpacing
        leftPadding: Kirigami.Units.largeSpacing
        rightPadding: Kirigami.Units.largeSpacing
        
        // top header bar (title and close button)
        contentItem: Kirigami.Heading {
            id: heading
            Layout.fillWidth: true
            level: 2
            text: root.title == "" ? " " : root.title // always have text to ensure header height
            elide: Text.ElideRight
            
            // use tooltip for long text that is elided
            Controls.ToolTip.visible: truncated && titleHoverHandler.hovered
            Controls.ToolTip.text: root.title
            HoverHandler { id: titleHoverHandler }
        }
    }
    
    /**
     * The footer of the dialog.
     * 
     * Specifying a custom footer will remove the footer buttons.
     * 
     * When specifying a custom footer item, be sure to set an 
     * `implicitHeight` and `implicitWidth`, as it will be used in 
     * dialog calculations.
     * 
     * If you simply do not want a footer, set the property to null.
     */
    property Item footer: Controls.Control {
        // needs to explicitly be set for each side to work
        // don't have height if the footer has no buttons
        topPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        bottomPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        leftPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        rightPadding: contentItem.implicitHeight > 0 ? Kirigami.Units.smallSpacing : 0
        
        // footer buttons
        contentItem: RowLayout {
            spacing: Kirigami.Units.smallSpacing
            Item { Layout.fillWidth: true }
            Repeater {
                model: {
                    // custom defined actions precede default actions
                    let actions = root.customFooterActions;
                    
                    // order matters here (in the left -> right arrangement of buttons)
                    if ((root.footerActions & Dialog.Actions.Ok) == Dialog.Actions.Ok) actions.push(okAction); 
                    if ((root.footerActions & Dialog.Actions.Cancel) == Dialog.Actions.Cancel) actions.push(cancelAction); 
                    if ((root.footerActions & Dialog.Actions.Close) == Dialog.Actions.Close) actions.push(closeAction);
                    if ((root.footerActions & Dialog.Actions.Done) == Dialog.Actions.Done) actions.push(doneAction);
                    if ((root.footerActions & Dialog.Actions.Save) == Dialog.Actions.Save) actions.push(saveAction);
                    if ((root.footerActions & Dialog.Actions.Apply) == Dialog.Actions.Apply) actions.push(applyAction);
                    if ((root.footerActions & Dialog.Actions.Yes) == Dialog.Actions.Yes) actions.push(yesAction);
                    if ((root.footerActions & Dialog.Actions.No) == Dialog.Actions.No) actions.push(noAction);
                    
                    return actions;
                }
                
                delegate: Controls.Button {
                    action: modelData
                    flat: root.flatFooterButtons
                }
            }
        }
    }
    
    /**
     * The left padding of the content.
     */
    property real leftPadding: root.padding
    
    /**
     * The right padding of the content.
     */
    property real rightPadding: root.padding
    
    /**
     * The top padding of the content.
     */
    property real topPadding: root.padding
    
    /**
     * The bottom padding of the content.
     */
    property real bottomPadding: root.padding
    
    /**
     * The padding of the content.
     */
    property double padding: Kirigami.Units.smallSpacing
    
    /**
     * The `QtQuick.Controls.Popup` item used in the dialog.
     */
    property alias popup: dialog
    
    /**
     * Whether or not the footer button style should be flat instead of raised.
     */
    property bool flatFooterButtons: false
    
    /**
     * Whether or not the dialog is visible.
     */
    property alias visible: dialog.visible
    
    /**
     * The parent of the item. 
     */
    property Item parent
    
    /**
     * Emitted when the dialog has been opened.
     */
    signal opened()
    
    /**
     * Emitted when the dialog has been closed.
     */
    signal closed()
    
    /**
     * Emitted when the dialog has had a footer button pressed
     * that has an `accepted()` signal associated with it.
     * 
     * See the `footerActions` property.
     */
    signal accepted()
    
    /**
     * Emitted when the dialog has had a footer button pressed
     * that has an `rejected()` signal associated with it.
     * 
     * See the `footerActions` property.
     */
    signal rejected()

    /**
     * Opens the dialog.
     */
    function open() {
        dialog.open();
    }
    
    /**
     * Closes the dialog.
     */
    function close() {
        dialog.close();
    }
    
    // visible dialog component
    property var rootItem: Controls.Popup {
        id: dialog
        
        onOpened: root.opened();
        onClosed: root.closed();
        
        parent: {
            if (root.parent) {
                return root.parent;
            } else {
                return applicationWindow().overlay;
            }
        }
        
        modal: true
        clip: false
        padding: 0

        // center dialog
        x: Math.round((parent.width - implicitWidth) / 2)
        y: Math.round((parent.height - implicitHeight) / 2) + Kirigami.Units.gridUnit * 2 * (1 - opacity) // move animation
        
        enter: Transition {
            NumberAnimation { property: "opacity"; from: 0.0; to: 1.0; duration: Kirigami.Units.longDuration }
        }
        exit: Transition {
            NumberAnimation { property: "opacity"; from: 1.0; to: 0.0; duration: Kirigami.Units.longDuration }
        }
        
        // black background
        Controls.Overlay.modal: Rectangle {
            color: Qt.rgba(0, 0, 0, 0.3 * dialog.opacity)
        }
        
        // dialog background
        background: Item {
            RectangularGlow {
                anchors.fill: rect
                anchors.topMargin: 1
                cornerRadius: rect.radius * 2
                glowRadius: 2
                spread: 0.2
                color: Qt.rgba(0, 0, 0, 0.3)
            }
            
            Rectangle {
                id: rect
                anchors.fill: parent
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
        }
        
        // actual dialog contents
        ColumnLayout {
            id: column
            spacing: 0
            
            // cap maximum width and maximum height at absoluteMaximumWidth and absoluteMaximumHeight
            property real calculatedMaximumWidth: root.maximumWidth > root.absoluteMaximumWidth ? root.absoluteMaximumWidth : root.maximumWidth
            property real calculatedMaximumHeight: root.maximumHeight > root.absoluteMaximumHeight ? root.absoluteMaximumHeight : root.maximumHeight
            
            // ensure that the dialog has rounded top corners (if header is not shown)
            Rectangle {
                id: roundedHeaderBuffer
                z: -1 // below content
                visible: !headerControl.show
                Layout.fillWidth: true
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
                implicitHeight: Kirigami.Units.smallSpacing * 2
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
            
            // header
            Controls.Control {
                id: headerControl
                contentItem: root.header
                
                property bool show: contentItem && contentItem.implicitHeight != 0
                
                Layout.fillWidth: true
                Layout.maximumWidth: column.calculatedMaximumWidth
                
                // needs to explicitly be set for each side to work
                // we let the contentItem do the padding themselves
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                
                background: Rectangle {
                    visible: headerControl.show
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.smallSpacing
                    
                    // cover bottom rounded corners
                    Rectangle {
                        color: Kirigami.Theme.backgroundColor
                        height: Kirigami.Units.smallSpacing
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.bottom: parent.bottom
                    }
                }
            }
            
            // header separator
            Kirigami.Separator {
                id: headerSeparator
                Layout.fillWidth: true
                visible: headerControl.show
            }
            
            // dialog content
            Private.ScrollView {
                id: contentControl
                contentItem: root.contentItem
                canFlickWithMouse: true

                // ensure view colour scheme, and background color
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
                // needs to explicitly be set for each side to work
                leftPadding: root.leftPadding
                rightPadding: root.rightPadding + contentControl.verticalScrollBarWidth
                topPadding: root.topPadding
                bottomPadding: root.bottomPadding + contentControl.horizontalScrollBarHeight
                
                // height of everything else in the dialog other than the content
                property real otherHeights: {
                    let h = headerControl.height + footerControl.height + headerSeparator.height + footerSeparator.height;
                    if (roundedHeaderBuffer.visible) h += roundedHeaderBuffer.height;
                    if (roundedFooterBuffer.visible) h += roundedFooterBuffer.height;
                    return h;
                }
                
                property real calculatedImplicitWidth: root.contentItem.implicitWidth + leftPadding + rightPadding
                property real calculatedImplicitHeight: root.contentItem.implicitHeight + topPadding + bottomPadding
                
                // don't enforce preferred width and height if not set
                Layout.preferredWidth: root.preferredWidth >= 0 ? root.preferredWidth : calculatedImplicitWidth
                Layout.preferredHeight: root.preferredHeight >= 0 ? root.preferredHeight - otherHeights : calculatedImplicitHeight
                
                Layout.fillWidth: true
                Layout.maximumWidth: column.calculatedMaximumWidth
                Layout.maximumHeight: column.calculatedMaximumHeight - otherHeights // we enforce maximum height solely from the content
                
                // give an implied width and height to the contentItem so that features like word wrapping work
                // cannot placed directly in contentControl as a child, so we must use a property
                property var widthHint: Binding {
                    target: root.contentItem
                    property: "width"
                    value: contentControl.Layout.preferredWidth - contentControl.leftPadding - contentControl.rightPadding
                }
                property var heightHint: Binding {
                    target: root.contentItem
                    property: "height"
                    value: contentControl.Layout.preferredHeight - contentControl.topPadding - contentControl.bottomPadding
                }
                
                // give explicit warnings since the maximumHeight is ignored when negative, so developers aren't confused
                Component.onCompleted: {
                    if (contentControl.Layout.maximumHeight < 0 || contentControl.Layout.maximumHeight === Infinity) {
                        console.log("Dialog Warning: the calculated maximumHeight for the content is less than zero, ignoring...");
                    }
                }
            }
            
            // footer separator
            Kirigami.Separator {
                id: footerSeparator
                Layout.fillWidth: true
                visible: footerControl.show
            }
            
            // footer
            Controls.Control {
                id: footerControl
                contentItem: root.footer
                
                property bool show: contentItem && contentItem.implicitHeight != 0
                
                Layout.fillWidth: true
                Layout.maximumWidth: column.calculatedMaximumWidth
                
                // needs to explicitly be set for each side to work
                // we let the contentItem do the padding themselves
                topPadding: 0; bottomPadding: 0; leftPadding: 0; rightPadding: 0
                
                background: Rectangle {
                    visible: footerControl.show
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    color: Kirigami.Theme.backgroundColor
                    radius: Kirigami.Units.smallSpacing
                    
                    // cover top rounded corners
                    Rectangle {
                        color: Kirigami.Theme.backgroundColor
                        height: Kirigami.Units.smallSpacing
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.top: parent.top
                    }
                }
            }
            
            // ensure that the dialog has rounded bottom corners (if header is not shown)
            Rectangle {
                id: roundedFooterBuffer
                z: -1 // below content
                visible: !footerControl.show
                Layout.fillWidth: true
                Kirigami.Theme.inherit: false
                Kirigami.Theme.colorSet: Kirigami.Theme.View
                
                implicitHeight: Kirigami.Units.smallSpacing
                color: Kirigami.Theme.backgroundColor
                radius: Kirigami.Units.smallSpacing
            }
        }
        
        // default dialog actions provided
        Kirigami.Action {
            id: okAction
            text: i18n("OK")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: cancelAction
            text: i18n("Cancel")
            iconName: "dialog-cancel"
            onTriggered: { root.rejected(); root.close(); }
        }
        Kirigami.Action {
            id: closeAction
            text: i18n("Close")
            iconName: "dialog-close"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: doneAction
            text: i18n("Done")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: saveAction
            text: i18n("Save")
            iconName: "dialog-close"
            onTriggered: { root.accepted(); root.close(); }
        }
        Kirigami.Action {
            id: applyAction
            text: i18n("Apply")
            iconName: "dialog-ok-apply"
            onTriggered: { root.accepted(); root.close() }
        }
        Kirigami.Action {
            id: yesAction
            text: i18n("Yes")
            iconName: "dialog-ok"
            onTriggered: { root.accepted(); root.close() }
        }
        Kirigami.Action {
            id: noAction
            text: i18n("No")
            iconName: "dialog-cancel"
            onTriggered: { root.rejected(); root.close(); }
        }
    }
}

