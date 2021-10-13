/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#include "inputmethod.h"

#include "libkirigami/virtualkeyboardwatcher.h"

class Q_DECL_HIDDEN InputMethod::Private
{
public:
    Type type = Type::NoInputMethod;

    bool enabled = false;
    bool active = false;
};

InputMethod::InputMethod(QObject *parent)
    : QObject(parent)
    , d(std::make_unique<Private>())
{
    auto watcher = Kirigami::VirtualKeyboardWatcher::self();

    connect(watcher, &Kirigami::VirtualKeyboardWatcher::availableChanged, this, [this]() {
        if (Kirigami::VirtualKeyboardWatcher::self()->available()) {
            d->type = Type::VirtualKeyboard;
        } else {
            d->type = Type::NoInputMethod;
        }
        Q_EMIT typeChanged();
    });

    connect(watcher, &Kirigami::VirtualKeyboardWatcher::enabledChanged, this, [this]() {
        d->enabled = Kirigami::VirtualKeyboardWatcher::self()->enabled();
        Q_EMIT enabledChanged();
    });

    connect(watcher, &Kirigami::VirtualKeyboardWatcher::activeChanged, this, [this]() {
        d->active = Kirigami::VirtualKeyboardWatcher::self()->active();
        Q_EMIT activeChanged();
    });

    d->type = watcher->available() ? Type::VirtualKeyboard : Type::NoInputMethod;
    d->enabled = watcher->enabled();
    d->active = watcher->active();
}

InputMethod::~InputMethod() = default;

InputMethod::Type InputMethod::type() const
{
    return d->type;
}

bool InputMethod::enabled() const
{
    return d->enabled;
}

void InputMethod::setEnabled(bool newEnabled)
{
    if (newEnabled == d->enabled) {
        return;
    }

    d->enabled = newEnabled;
    Q_EMIT enabledChanged();
}

bool InputMethod::active() const
{
    return d->active;
}

void InputMethod::setActive(bool newActive)
{
    if (newActive == d->active) {
        return;
    }

    d->active = newActive;

    Q_EMIT activeChanged();
}
