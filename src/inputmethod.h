/*
 * SPDX-FileCopyrightText: 2021 Arjen Hiemstra <ahiemstra@heimr.nl>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

#ifndef INPUTMETHOD_H
#define INPUTMETHOD_H

#include <memory>

#include <QObject>

/**
 * This exposes information about the current used input method.
 */
class InputMethod : public QObject
{
    Q_OBJECT

public:
    enum Type {
        NoInputMethod, ///< No input method detected.
        VirtualKeyboard, ///< The system has a virtual keyboard that may be active.
        Other ///< Some other type of input method is active.
    };

    InputMethod(QObject *parent = nullptr);
    ~InputMethod() override;

    /**
     * The type of input method that is currently enabled.
     */
    Q_PROPERTY(Type type READ type NOTIFY typeChanged)
    Type type() const;
    Q_SIGNAL void typeChanged();

    /**
     * Is the current input method enabled.
     *
     * If this is false, that means the input method is available but not in use.
     */
    Q_PROPERTY(bool enabled READ enabled WRITE setEnabled NOTIFY enabledChanged)
    bool enabled() const;
    void setEnabled(bool newEnabled);
    Q_SIGNAL void enabledChanged();

    /**
     * Whether the current input method is active.
     *
     * What active means depends on the type of input method. In case of a
     * virtual keyboard for example, it would mean the virtual keyboard is
     * visible.
     */
    Q_PROPERTY(bool active READ active WRITE setActive NOTIFY activeChanged)
    bool active() const;
    void setActive(bool newActive);
    Q_SIGNAL void activeChanged();

private:
    class Private;
    const std::unique_ptr<Private> d;
};

#endif // INPUTMETHOD_H
