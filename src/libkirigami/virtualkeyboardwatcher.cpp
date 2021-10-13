/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *  SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "virtualkeyboardwatcher.h"

#ifdef KIRIGAMI_ENABLE_DBUS
#include "virtualkeyboard_interface.h"
#include <QDBusConnection>
#endif

namespace Kirigami
{
Q_GLOBAL_STATIC(VirtualKeyboardWatcher, virtualKeyboardWatcherSelf)

class VirtualKeyboardWatcher::Private
{
public:
#ifdef KIRIGAMI_ENABLE_DBUS
    OrgKdeKwinVirtualKeyboardInterface *interface = nullptr;
#endif

    bool available = false;
    bool enabled = false;
    bool active = false;
    bool visible = false;
};

VirtualKeyboardWatcher::VirtualKeyboardWatcher(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>())
{
#ifdef KIRIGAMI_ENABLE_DBUS
    d->interface = new OrgKdeKwinVirtualKeyboardInterface(QStringLiteral("org.kde.KWin"), QStringLiteral("/org/kde/KWin"), QDBusConnection::sessionBus(), this);

    connect(d->interface, &OrgKdeKwinVirtualKeyboardInterface::availableChanged, this, [this]() {
        d->available = d->interface->available();
        Q_EMIT availableChanged();
    });

    connect(d->interface, &OrgKdeKwinVirtualKeyboardInterface::enabledChanged, this, [this]() {
        d->enabled = d->interface->enabled();
        Q_EMIT enabledChanged();
    });

    connect(d->interface, &OrgKdeKwinVirtualKeyboardInterface::activeChanged, this, [this]() {
        d->active = d->interface->active();
        Q_EMIT activeChanged();
    });

    connect(d->interface, &OrgKdeKwinVirtualKeyboardInterface::visibleChanged, this, [this]() {
        d->visible = d->interface->visible();
        Q_EMIT visibleChanged();
    });
#endif
}

VirtualKeyboardWatcher::~VirtualKeyboardWatcher() = default;

bool VirtualKeyboardWatcher::available() const
{
    return d->available;
}

bool VirtualKeyboardWatcher::enabled() const
{
    return d->enabled;
}

void VirtualKeyboardWatcher::setEnabled(bool newEnabled)
{
    if (newEnabled == d->enabled) {
        return;
    }

    d->enabled = newEnabled;

#ifdef KIRIGAMI_ENABLE_DBUS
    d->interface->setEnabled(newEnabled);
#else
    Q_EMIT enabledChanged();
#endif
}

bool VirtualKeyboardWatcher::active() const
{
    return d->active;
}

void VirtualKeyboardWatcher::setActive(bool newActive)
{
    if (newActive == d->active) {
        return;
    }

    d->active = newActive;

#ifdef KIRIGAMI_ENABLE_DBUS
    d->interface->setActive(newActive);
#else
    Q_EMIT activeChanged();
#endif
}

bool VirtualKeyboardWatcher::visible() const
{
    return d->visible;
}

VirtualKeyboardWatcher *VirtualKeyboardWatcher::self()
{
    return virtualKeyboardWatcherSelf();
}

}
