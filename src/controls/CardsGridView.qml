/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.10
import QtQuick.Controls 2.0 as Controls
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private"

/**
 * CardsGridView is used to display a grid of Cards generated from any model.
 * The behavior is same as CardsLayout, and it allows cards to be put in one or two
 * columns depending on the available width.
 *
 * GridView has the limitation that every Card must have the same exact height,
 * so cellHeight must be manually set to a value in which the content fits
 * for every item.
 *
 * If possible use cards only when you don't need to instantiate a lot
 * and use CardsLayout instead.
 *
 * @inherit QtQuick.GridView
 * @see CardsLayout
 * @since 2.4
 */
CardsGridViewPrivate {
    id: root

    /**
     * This property holds the the number of columns the gridview has.
     * @since 2.5
     */
    readonly property int columns: Math.max(1,
                        Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                 Math.floor(width/minimumColumnWidth),
                                 Math.ceil(width/maximumColumnWidth))
                       );

    /**
     * This property holds the maximum number of columns.
     *
     * By default there is not limit.
     *
     * @since 2.5
     */
    property int maximumColumns: Infinity

    /**
     * @brief This property holds the maximum width the columns may have.
     *
     * The cards will never become wider than this size; when the GridView is wider
     * than maximumColumnWidth, it will switch from one to two columns.
     *
     * If the default needs to be overridden for some reason,
     * it is advised to express this unit as a multiple
     * of Kirigami.Units.gridUnit
     */
    property int maximumColumnWidth: Kirigami.Units.gridUnit * 20

    /**
     * This property holds the minimum width the columns may have.
     *
     * The cards will never become smaller than this size.
     *
     * If the default needs to be overridden for some reason,
     * it is advised to express this unit as a multiple
     * of Kirigami.Units.gridUnit
     * @since 2.5
     */
    property int minimumColumnWidth: Kirigami.Units.gridUnit * 12

    cellWidth: Math.floor(width/columns)
    cellHeight: Math.max(Kirigami.Units.gridUnit * 15, Math.min(cellWidth, maximumColumnWidth) / 1.2)

    /**
     * This property holds the delegate of the CardsGridView.
     *
     * @see QtQuick.ListView::delegate
     */
    default property alias delegate: root._delegateComponent

    topMargin: Kirigami.Units.largeSpacing * 2
}
