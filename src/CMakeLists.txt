
add_subdirectory(libkirigami)

ecm_add_qml_module(KirigamiModule URI "org.kde.kirigami" VERSION 2.0 CLASSNAME KirigamiPlugin)

ecm_add_qml_module_dependencies(KirigamiModule DEPENDS
    "QtQuick.Controls 2.15"
    "QtGraphicalEffects 1.0"
)

if (BUILD_SHARED_LIBS)
    ecm_create_qm_loader(kirigami_QM_LOADER libkirigami2plugin_qt)
else()
    set(KIRIGAMI_STATIC_FILES
        libkirigami/basictheme.cpp
        libkirigami/platformtheme.cpp
        libkirigami/styleselector.cpp
        libkirigami/tabletmodewatcher.cpp
        libkirigami/kirigamipluginfactory.cpp
        libkirigami/units.cpp
        ${CMAKE_CURRENT_BINARY_DIR}/libkirigami/loggingcategory.cpp
    )
    set_target_properties(KirigamiModule PROPERTIES AUTOMOC_MOC_OPTIONS -Muri=org.kde.kirigami)
endif()

qt_add_resources(SHADERS scenegraph/shaders/shaders.qrc)

if (NOT BUILD_SHARED_LIBS AND (UNIX AND NOT ANDROID AND NOT(APPLE) AND NOT(DISABLE_DBUS)))
    qt_add_dbus_interface(kirigami_SRCS libkirigami/org.kde.KWin.TabletModeManager.xml tabletmodemanager_interface)
    set(Kirigami_EXTRA_LIBS Qt5::DBus)
endif()

target_include_directories(KirigamiModule PRIVATE
    ${CMAKE_CURRENT_SOURCE_DIR}/libkirigami
    ${CMAKE_CURRENT_BINARY_DIR}/libkirigami
)

target_sources(KirigamiModule PRIVATE
    kirigamiplugin.cpp
    columnview.cpp
    enums.cpp
    delegaterecycler.cpp
    icon.cpp
    settings.cpp
    formlayoutattached.cpp
    pagepool.cpp
    imagecolors.cpp
    scenepositionattached.cpp
    mnemonicattached.cpp
    wheelhandler.cpp
    shadowedrectangle.cpp
    shadowedtexture.cpp
    colorutils.cpp
    pagerouter.cpp
    avatar.cpp
    toolbarlayout.cpp
    toolbarlayoutdelegate.cpp
    sizegroup.cpp
    spellcheckinghint.cpp
    scenegraph/managedtexturenode.cpp
    scenegraph/shadowedrectanglenode.cpp
    scenegraph/shadowedrectanglematerial.cpp
    scenegraph/shadowedborderrectanglematerial.cpp
    scenegraph/paintedrectangleitem.cpp
    scenegraph/shadowedtexturenode.cpp
    scenegraph/shadowedtexturematerial.cpp
    scenegraph/shadowedbordertexturematerial.cpp
    ${CMAKE_CURRENT_BINARY_DIR}/libkirigami/loggingcategory.cpp
    ${kirigami_QM_LOADER}
    ${KIRIGAMI_STATIC_FILES}
    ${SHADERS}
)

ecm_target_qml_sources(KirigamiModule SOURCES
    controls/Action.qml
    controls/AbstractApplicationHeader.qml
    controls/AbstractApplicationWindow.qml
    controls/AbstractListItem.qml
    controls/ApplicationHeader.qml
    controls/ToolBarApplicationHeader.qml
    controls/ApplicationWindow.qml
    controls/BasicListItem.qml
    controls/OverlayDrawer.qml
    controls/ContextDrawer.qml
    controls/GlobalDrawer.qml
    controls/Heading.qml
    controls/Separator.qml
    controls/PageRow.qml
    controls/Label.qml
    controls/OverlaySheet.qml
    controls/Page.qml
    controls/ScrollablePage.qml
    controls/SwipeListItem.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.1 SOURCES
    controls/AbstractItemViewHeader.qml
    controls/ItemViewHeader.qml
    controls/AbstractApplicationItem.qml
    controls/ApplicationItem.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.3 SOURCES
    controls/FormLayout.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.4 SOURCES
    controls/AbstractCard.qml
    controls/Card.qml
    controls/CardsListView.qml
    controls/CardsGridView.qml
    controls/CardsLayout.qml
    controls/InlineMessage.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.5 SOURCES
    controls/ListItemDragHandle.qml
    controls/ActionToolBar.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.6 SOURCES
    controls/AboutPage.qml
    controls/LinkButton.qml
    controls/UrlButton.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.7 SOURCES
    controls/ActionTextField.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.8 SOURCES
    controls/SearchField.qml
    controls/PasswordField.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.10 SOURCES
    controls/ListSectionHeader.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.11 SOURCES
    controls/PagePoolAction.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.12 SOURCES
    controls/ShadowedImage.qml
    controls/PlaceholderMessage.qml
    controls/RouterWindow.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.13 SOURCES
    controls/Avatar.qml
    controls/swipenavigator/SwipeNavigator.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.14 SOURCES
    controls/FlexColumn.qml
    controls/CheckableListItem.qml
    controls/Hero.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.17 SOURCES
    controls/swipenavigator/TabViewLayout.qml
    controls/swipenavigator/PageTab.qml
)

ecm_target_qml_sources(KirigamiModule VERSION 2.18 SOURCES
    controls/settingscomponents/CategorizedSettings.qml
    controls/settingscomponents/SettingAction.qml
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH private SOURCES
    controls/private/ActionButton.qml
    controls/private/ActionIconGroup.qml
    controls/private/ActionMenuItem.qml
    controls/private/ActionsMenu.qml
    controls/private/BannerImage.qml
    controls/private/CardsGridViewPrivate.qml
    controls/private/ContextDrawerActionItem.qml
    controls/private/CornerShadow.qml
    controls/private/DefaultCardBackground.qml
    controls/private/DefaultListItemBackground.qml
    controls/private/EdgeShadow.qml
    controls/private/GlobalDrawerActionItem.qml
    controls/private/PageActionPropertyGroup.qml
    controls/private/PrivateActionToolButton.qml
    controls/private/RefreshableScrollView.qml
    controls/private/SwipeItemEventFilter.qml
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH private/globaltoolbar SOURCES
    controls/private/globaltoolbar/AbstractPageHeader.qml
    controls/private/globaltoolbar/BreadcrumbControl.qml
    controls/private/globaltoolbar/PageRowGlobalToolBarStyleGroup.qml
    controls/private/globaltoolbar/PageRowGlobalToolBarUI.qml
    controls/private/globaltoolbar/TabBarControl.qml
    controls/private/globaltoolbar/TitlesPageHeader.qml
    controls/private/globaltoolbar/ToolBarPageHeader.qml
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH swipenavigator SOURCES
    controls/swipenavigator/PrivateSwipeHighlight.qml
    controls/swipenavigator/PrivateSwipeProgress.qml
    controls/swipenavigator/PrivateSwipeStack.qml
    controls/swipenavigator/PrivateSwipeTab.qml
    controls/swipenavigator/PrivateSwipeTabBar.qml
    controls/swipenavigator/templates/PageTab.qml
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH templates SOURCES
    controls/templates/AbstractApplicationHeader.qml
    controls/templates/AbstractCard.qml
    controls/templates/AbstractListItem.qml
    controls/templates/ApplicationHeader.qml
    controls/templates/InlineMessage.qml
    controls/templates/OverlayDrawer.qml
    controls/templates/OverlaySheet.qml
    controls/templates/SingletonHeaderSizeGroup.qml
    controls/templates/SwipeListItem.qml
    controls/templates/qmldir
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH templates/private SOURCES
    controls/templates/private/BackButton.qml
    controls/templates/private/BorderPropertiesGroup.qml
    controls/templates/private/ContextIcon.qml
    controls/templates/private/ForwardButton.qml
    controls/templates/private/GenericDrawerIcon.qml
    controls/templates/private/IconPropertiesGroup.qml
    controls/templates/private/MenuIcon.qml
    controls/templates/private/PassiveNotification.qml
    controls/templates/private/ScrollView.qml
)

ecm_target_qml_sources(KirigamiModule PRIVATE PATH styles/Material SOURCES
    styles/Material/AbstractListItem.qml
    styles/Material/InlineMessage.qml
    styles/Material/Label.qml
    styles/Material/SwipeListItem.qml
    styles/Material/Theme.qml
)

if (DESKTOP_ENABLED)
    ecm_target_qml_sources(KirigamiModule PRIVATE PATH styles/org.kde.desktop SOURCES
        styles/org.kde.desktop/AbstractApplicationHeader.qml
        styles/org.kde.desktop/AbstractListItem.qml
        styles/org.kde.desktop/SwipeListItem.qml
        styles/org.kde.desktop/Theme.qml
    )
endif()

target_link_libraries(KirigamiModule
    PUBLIC Qt5::Core
    PRIVATE ${Kirigami_EXTRA_LIBS} Qt5::GuiPrivate Qt5::Qml Qt5::Quick Qt5::QuickControls2 Qt5::Concurrent KF5Kirigami2
)

ecm_finalize_qml_module(KirigamiModule DESTINATION ${KDE_INSTALL_QMLDIR})

ecm_generate_qmltypes(org.kde.kirigami 2.0 DESTINATION ${KDE_INSTALL_QMLDIR}/org/kde/kirigami.2)

if (ANDROID)
    install(FILES KF5Kirigami2-android-dependencies.xml
        DESTINATION ${KDE_INSTALL_LIBDIR}
        RENAME KF5Kirigami2_${CMAKE_ANDROID_ARCH_ABI}-android-dependencies.xml
    )
endif()
