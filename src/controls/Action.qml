/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls 2.4 as Controls
import "private"

import org.kde.kirigami 2.14 as Kirigami

/**
 * An item that represents an abstract Action
 *
 * @inherit QtQuick.Controls.Action
 */
Controls.Action {
    id: root

    /**
     * @brief This property holds whether the graphic representation of the action
     * is supposed to be visible.
     *
     * It's up to the action representation to honor this property.
     *
     * By default the action is visible.
     */
    property bool visible: true

    /**
     * @brief This property holds the icon name for the action. This will pick the icon with the given name from the current theme.
     *
     * @property string Action::iconName
     * @deprecated Use icon.name instead.
     */
    property alias iconName: root.icon.name

    /**
     * @brief This property holds an url to an icon file or resource url for the action.
     *
     * Defaults to the empty URL. Use this if you want a specific file rather than an icon from the theme
     *
     * @property url Action::iconSource
     * @deprecated Use icon.name instead.
     */
    property alias iconSource: root.icon.source

    /**
     * This property holds a tooltip text to be shown when hovering the control bound to this
     * action. Not all controls support tooltips on all platforms
     */
    property string tooltip

    /**
     * This property holds whether the action is a separator action.
     *
     * By default the action isn't a separator.
     */
    property bool separator: false

    /**
     * This property hols whether the actions in globalDrawers and contextDrawers will
     * become titles displaying the child actions as sub items.
     *
     * By default the action is not expandible.
     * @since 2.6
     */
    property bool expandible: false

    /**
     * This property holds the parent action of this parent.
     */
    property Controls.Action parent

    /**
     * This property holds a combination of values from the Action.DisplayHint enum.
     * These are provided to implementations to indicate a preference for certain display
     * styles. The default is DisplayHint.NoPreference.
     *
     * @note This property contains only preferences, implementations may choose to disregard them.
     *
     * @since 2.12
     */
    property int displayHint: Kirigami.DisplayHint.NoPreference

    /**
     * Helper function to check if a certain display hint has been set.
     *
     * This function is mostly convenience to enforce the mutual exclusivity of KeepVisible and AlwaysHide.
     *
     * @param hint The display hint to check if it is set.
     *
     * @return true if the hint was set for this action, false if not.
     *
     * @since 2.12
     *
     * @deprecated since 2.14, Use DisplayHint.displayHintSet(action, hint) instead.
     */
    function displayHintSet(hint) {
        print("Action::displayHintSet is deprecated, use DisplayHint.displayHintSet(action, hint)")
        return Kirigami.DisplayHint.displayHintSet(root, hint);
    }

    /**
     * This property holds a component that should be preferred when displaying this Action.
     *
     * This can be used to display custom components in the toolbar.
     *
     * @since 5.65
     * @since 2.12
     */
    property Component displayComponent: null

    /**
     * This action holds a list of children actions.
     *
     * This is useful for tree-like menus. For example for the GlobalDrawer.
     *
     * @code
     * Action {
     *    text: "Tools"
     *    Action {
     *        text: "Action1"
     *    }
     *    Action {
     *        text: "Action2"
     *    }
     * }
     * @endcode
     * @property list<Action> Action::children
     */
    default property alias children: root.__children

    /** @internal */
    property list<QtObject> __children

    onChildrenChanged: {
        var child;
        for (var i in children) {
            child = children[i];
            if (child.hasOwnProperty("parent")) {
                child.parent = root
            }
        }
    }

    /**
     * This property holds the visible children actions that are visible.
     *
     * @property list<Action> Action::visibleChildren
     */
    readonly property var visibleChildren: {
        let visible = [];
        for (let i in children) {
            const child = children[i];
            if (!child.hasOwnProperty("visible") || child.visible) {
                visible.push(child);
            }
        }
        return visible;
    }

    /**
     * Hints for implementations using Actions indicating preferences about how to display the action.
     *
     * @deprecated since 2.14, use Kirigami.DisplayHint instead.
     */
    enum DisplayHint {
        /**
         * Indicates there is no specific preference.
         */
        NoPreference = 0,
        /**
         * Only display an icon for this Action.
         */
        IconOnly = 1,
        /**
         * Try to keep the action visible even when space constrained.
         * Mutually exclusive with AlwaysHide, KeepVisible has priority.
         */
        KeepVisible = 2,
        /**
         * If possible, hide the action in an overflow menu or similar location.
         * Mutually exclusive with KeepVisible, KeepVisible has priority.
         */
        AlwaysHide = 4,
        /**
         * When this action has children, do not display any indicator (like a
         * menu arrow) for this action.
         */
        HideChildIndicator = 8
    }
}
