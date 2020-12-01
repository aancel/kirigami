/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

/*!
    \qmltype PageRouter
    \instantiates PageRouter
    \inmodule Kirigami2

    \brief An item managing pages and data of a ColumnView using named routes.

    \section1 Using a PageRouter

    Applications typically manage their contents via elements called "pages" or "screens."
    In Kirigami, these are called \l {Page}{Pages} and are
    arranged in \l {PageRoute}{routes} using a PageRouter to manage them. The PageRouter
    manages a stack of \l {Page}{Pages} created from a pool of potential
    \l {PageRoute}{PageRoutes}.

    Unlike most traditional stacks, a PageRouter provides functions for random access to its pages
    with \l {navigateToRoute} and \l {routeActive}.

    When your user interface fits the stack paradigm and is likely to use random access navigation,
    using the PageRouter is appropriate. For simpler navigation, it is more appropriate to avoid
    the overhead of a PageRouter by using a \l {PageRow}{PageRow} instead.

    \section1 Navigation Model

    A PageRouter draws from a pool of \l {PageRoute}{PageRoutes} in order to construct
    its stack.

    \image PageRouterModel.svg

    You can push pages onto this stack...

    \image PageRouterPush.svg

    ...or pop them off...

    \image PageRouterPop.svg

    ...or navigate to an arbitrary collection of pages.

    \image PageRouterNavigate.svg

    Components are able to query the PageRouter about the currently active routes
    on the stack. This is useful for e.g. a card indicating that the page it takes
    the user to is currently active.

    \quotefile PageRouter.qml
*/

/*!
    \qmlproperty list<PageRoute> PageRouter::routes

    The routes this PageRouter knows about and can navigate to.

    \quotefile PageRouterRoutes.qml
*/

/*!
    \qmlproperty object PageRouter::initialRoute

    The page that the PageRouter will push upon
    creation. Changing it after creation will cause the PageRouter to reset
    its state. Not providing an initial route will result in undefined
    behavior.

    \quotefile PageRouterInitialRoute.qml
*/

/*!
    \qmlproperty ColumnView PageRouter::pageStack

    \brief The ColumnView being puppeted by the PageRouter.

    All PageRouters should be created with a ColumnView, and creating one without
    a ColumnView is undefined behaviour.

    \warning You should **not** directly interact with a ColumnView being puppeted
    by a PageRouter. Instead, use a PageRouter's functions to manipulate the
    ColumnView.

    \quotefile PageRouterColumnView.qml
*/

/*!
    \qmlproperty int PageRouter::cacheCapacity

    \brief How large the cache can be.

    The combined costs of preloaded routes will never exceed the pool capacity.
*/

/*!
    \qmlmethod void PageRouter::navigateToRoute(Route route)

    \code
    interface DetailedRoute {
        // the named page of the route
        route: string
        // the data to provide to the page
        data: any
    }
    type Route = DetailedRoute | string
    \endcode

    Causes the PageRouter to replace currently active pages with the provided \a route.

    \a route is the given route for the PageRouter to navigate to.

    \warning Navigating to a route not defined in a PageRouter's routes is undefined
    behavior and will likely result in a crash.
*/

/*!
    \qmlmethod bool PageRouter::routeActive(Route route)

    \brief Check whether the current route is on the stack.

    Returns true if \a route is on the stack.

    This returns true for partial routes like
    the following:

    \code
    PageRouter.navigateToRoute(["/home", "/login", "/google"])
    PageRouter.routeActive(["/home", "/login"]) // returns true
    \endcode

    This only works from the root page, e.g. the following will return false:
    \code
    PageRouter.navigateToRoute(["/home", "/login", "/google"])
    PageRouter.routeActive(["/login", "/google"]) // returns false
    \endcode
*/

#include <QJsonValue>
#include <QJsonObject>
#include <QJSValue>
#include <QJSEngine>
#include <QQmlProperty>
#include <QQuickWindow>
#include <qqmlpropertymap.h>
#include "pagerouter.h"

ParsedRoute* parseRoute(QJSValue value)
{
    if (value.isUndefined()) {
        return new ParsedRoute{};
    } else if (value.isString()) {
        return new ParsedRoute{
            value.toString(),
            QVariant()
        };
    } else {
        auto map = value.toVariant().value<QVariantMap>();
        map.remove(QStringLiteral("route"));
        map.remove(QStringLiteral("data"));
        return new ParsedRoute{
            value.property(QStringLiteral("route")).toString(),
            value.property(QStringLiteral("data")).toVariant(),
            map,
            false
        };
    }
}

QList<ParsedRoute*> parseRoutes(QJSValue values)
{
    QList<ParsedRoute*> ret;
    if (values.isArray()) {
        const auto valuesList = values.toVariant().toList();
        for (const auto &route : valuesList) {
            if (route.toString() != QString()) {
                ret << new ParsedRoute{
                    route.toString(),
                    QVariant(),
                    QVariantMap(),
                    false,
                    nullptr
                };
            } else if (route.canConvert<QVariantMap>()) {
                auto map = route.value<QVariantMap>();
                auto copy = map;
                copy.remove(QStringLiteral("route"));
                copy.remove(QStringLiteral("data"));

                ret << new ParsedRoute{
                    map.value(QStringLiteral("route")).toString(),
                    map.value(QStringLiteral("data")),
                    copy,
                    false,
                    nullptr
                };
            }
        }
    } else {
        ret << parseRoute(values);
    }
    return ret;
}

PageRouter::PageRouter(QQuickItem *parent) : QObject(parent), m_paramMap(new QQmlPropertyMap), m_cache(), m_preload()
{
    connect(this, &PageRouter::pageStackChanged, [=]() {
        connect(m_pageStack, &ColumnView::currentIndexChanged, this, &PageRouter::currentIndexChanged);
    });
}

QQmlListProperty<PageRoute> PageRouter::routes()
{
    return QQmlListProperty<PageRoute>(this, nullptr, appendRoute, routeCount, route, clearRoutes);
}

void PageRouter::appendRoute(QQmlListProperty<PageRoute>* prop, PageRoute* route)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    router->m_routes.append(route);
}

int PageRouter::routeCount(QQmlListProperty<PageRoute>* prop)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    return router->m_routes.length();
}

PageRoute* PageRouter::route(QQmlListProperty<PageRoute>* prop, int index)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    return router->m_routes[index];
}

void PageRouter::clearRoutes(QQmlListProperty<PageRoute>* prop)
{
    auto router = qobject_cast<PageRouter*>(prop->object);
    router->m_routes.clear();
}

PageRouter::~PageRouter() {}

void PageRouter::classBegin()
{

}

void PageRouter::componentComplete()
{
    if (m_pageStack == nullptr) {
        qCritical() << "PageRouter should be created with a ColumnView. Not doing so is undefined behaviour, and is likely to result in a crash upon further interaction.";
    } else {
        Q_EMIT pageStackChanged();
        m_currentRoutes.clear();
        push(parseRoute(initialRoute()));
    }
}

bool PageRouter::routesContainsKey(const QString &key) const
{
    for (auto route : m_routes) {
        if (route->name() == key) return true;
    }
    return false;
}

QQmlComponent* PageRouter::routesValueForKey(const QString &key) const
{
    for (auto route : m_routes) {
        if (route->name() == key) return route->component();
    }
    return nullptr;
}

bool PageRouter::routesCacheForKey(const QString &key) const
{
    for (auto route : m_routes) {
        if (route->name() == key) return route->cache();
    }
    return false;
}

int PageRouter::routesCostForKey(const QString &key) const
{
    for (auto route : m_routes) {
        if (route->name() == key) return route->cost();
    }
    return -1;
}

// It would be nice if this could surgically update the
// param map instead of doing this brute force approach,
// but this seems to work well enough, and prematurely
// optimising stuff is pretty bad if it isn't found as
// a performance bottleneck.
void PageRouter::reevaluateParamMapProperties()
{
    QStringList currentKeys;

    for (auto item : m_currentRoutes) {
        for (auto key : item->properties.keys()) {
            currentKeys << key;

            auto& value = item->properties[key];
            m_paramMap->insert(key, value);
        }
    }

    for (auto key : m_paramMap->keys()) {
        if (!currentKeys.contains(key)) {
            m_paramMap->clear(key);
        }
    }
}

void PageRouter::push(ParsedRoute* route)
{
    Q_ASSERT(route);
    if (!routesContainsKey(route->name)) {
        qCritical() << "Route" << route->name << "not defined";
        return;
    }
    if (routesCacheForKey(route->name)) {
        auto push = [route, this](ParsedRoute* item) {
            m_currentRoutes << item;

            for ( auto it = route->properties.begin(); it != route->properties.end(); it++ ) {
                item->item->setProperty(qUtf8Printable(it.key()), it.value());
                item->properties[it.key()] = it.value();
            }
            reevaluateParamMapProperties();

            m_pageStack->addItem(item->item);
        };
        auto item = m_cache.take(qMakePair(route->name, route->hash()));
        if (item && item->item) {
            push(item);
            return;
        }
        item = m_preload.take(qMakePair(route->name, route->hash()));
        if (item && item->item) {
            push(item);
            return;
        }
    }
    auto context = qmlContext(this);
    auto component = routesValueForKey(route->name);
    auto createAndPush = [component, context, route, this]() {
        // We use beginCreate and completeCreate to allow
        // for a PageRouterAttached to find its parent
        // on construction time.
        auto item = component->beginCreate(context);
        item->setParent(this);
        auto qqItem = qobject_cast<QQuickItem*>(item);
        if (!qqItem) {
            qCritical() << "Route" << route->name << "is not an item! This is undefined behaviour and will likely crash your application.";
        }
        for ( auto it = route->properties.begin(); it != route->properties.end(); it++ ) {
            qqItem->setProperty(qUtf8Printable(it.key()), it.value());
        }
        route->setItem(qqItem);
        route->cache = routesCacheForKey(route->name);
        m_currentRoutes << route;
        reevaluateParamMapProperties();

        auto attached = qobject_cast<PageRouterAttached*>(qmlAttachedPropertiesObject<PageRouter>(item, true));
        attached->m_router = this;
        component->completeCreate();
        m_pageStack->addItem(qqItem);
        m_pageStack->setCurrentIndex(m_currentRoutes.length()-1);
    };

    if (component->status() == QQmlComponent::Ready) {
        createAndPush();
    } else if (component->status() == QQmlComponent::Loading) {
        connect(component, &QQmlComponent::statusChanged, [=](QQmlComponent::Status status) {
            // Loading can only go to Ready or Error.
            if (status != QQmlComponent::Ready) {
                qCritical() << "Failed to push route:" << component->errors();
            }
            createAndPush();
        });
    } else {
        qCritical() << "Failed to push route:" << component->errors();
    }
}

QJSValue PageRouter::initialRoute() const
{
    return m_initialRoute;
}

void PageRouter::setInitialRoute(QJSValue value)
{
    m_initialRoute = value;
}

void PageRouter::navigateToRoute(QJSValue route)
{
    auto incomingRoutes = parseRoutes(route);
    QList<ParsedRoute*> resolvedRoutes;

    if (incomingRoutes.length() <= m_currentRoutes.length()) {
        resolvedRoutes = m_currentRoutes.mid(0, incomingRoutes.length());
    } else {
        resolvedRoutes = m_currentRoutes;
        resolvedRoutes.reserve(incomingRoutes.length()-m_currentRoutes.length());
    }

    for (int i = 0; i < incomingRoutes.length(); i++) {
        auto incoming = incomingRoutes.at(i);
        Q_ASSERT(incoming);
        if (i >= resolvedRoutes.length()) {
            resolvedRoutes.append(incoming);
        } else { 
            auto current = resolvedRoutes.value(i);
            Q_ASSERT(current);
            auto props = incoming->properties;
            if (current->name != incoming->name || current->data != incoming->data) {
                resolvedRoutes.replace(i, incoming);
            }
            resolvedRoutes[i]->properties.clear();
            for (auto it = props.constBegin(); it != props.constEnd(); it++) {
                resolvedRoutes[i]->properties.insert(it.key(), it.value());
            }
        }
    }

    for (const auto &route : qAsConst(m_currentRoutes)) {
        if (!resolvedRoutes.contains(route)) {
            placeInCache(route);
        }
    }

    m_pageStack->clear();
    m_currentRoutes.clear();
    for (auto toPush : qAsConst(resolvedRoutes)) {
        push(toPush);
    }
    reevaluateParamMapProperties();
    Q_EMIT navigationChanged();
}

void PageRouter::bringToView(QJSValue route)
{
    if (route.isNumber()) {
        auto index = route.toNumber();
        m_pageStack->setCurrentIndex(index);
    } else {
        auto parsed = parseRoute(route);
        auto index = 0;
        for (auto currentRoute : qAsConst(m_currentRoutes)) {
            if (currentRoute->name == parsed->name && currentRoute->data == parsed->data) {
                m_pageStack->setCurrentIndex(index);
                return;
            }
            index++;
        }
        qWarning() << "Route" << parsed->name << "with data" << parsed->data << "is not on the current stack of routes.";
    }
}

bool PageRouter::routeActive(QJSValue route)
{
    auto parsed = parseRoutes(route);
    if (parsed.length() > m_currentRoutes.length()) {
        return false;
    }
    for (int i = 0; i < parsed.length(); i++) {
        if (parsed[i]->name != m_currentRoutes[i]->name) {
            return false;
        }
        if (parsed[i]->data.isValid()) {
            if (parsed[i]->data != m_currentRoutes[i]->data) {
                return false;
            }
        }
    }
    return true;
}

void PageRouter::pushRoute(QJSValue route)
{
    push(parseRoute(route));
    Q_EMIT navigationChanged();
}

void PageRouter::popRoute()
{
    m_pageStack->pop(m_currentRoutes.last()->item);
    placeInCache(m_currentRoutes.last());
    m_currentRoutes.removeLast();
    reevaluateParamMapProperties();
    Q_EMIT navigationChanged();
}

QVariant PageRouter::dataFor(QObject *object)
{
    auto pointer = object;
    auto qqiPointer = qobject_cast<QQuickItem*>(object);
    QHash<QQuickItem*,ParsedRoute*> routes;
    for (auto route : qAsConst(m_cache.items)) {
        routes[route->item] = route;
    }
    for (auto route : qAsConst(m_preload.items)) {
        routes[route->item] = route;
    }
    for (auto route : qAsConst(m_currentRoutes)) {
        routes[route->item] = route;
    }
    while (qqiPointer != nullptr) {
        const auto keys = routes.keys();
        for (auto item : keys) {
            if (item == qqiPointer) {
                return routes[item]->data;
            }
        }
        qqiPointer = qqiPointer->parentItem();
    }
    while (pointer != nullptr) {
        const auto keys = routes.keys();
        for (auto item : keys) {
            if (item == pointer) {
                return routes[item]->data;
            }
        }
        pointer = pointer->parent();
    }
    return QVariant();
}

bool PageRouter::isActive(QObject *object)
{
    auto pointer = object;
    while (pointer != nullptr) {
        auto index = 0;
        for (auto route : qAsConst(m_currentRoutes)) {
            if (route->item == pointer) {
                return m_pageStack->currentIndex() == index;
            }
            index++;
        }
        pointer = pointer->parent();
    }
    qWarning() << "Object" << object << "not in current routes";
    return false;
}

PageRouterAttached* PageRouter::qmlAttachedProperties(QObject *object)
{
    auto attached = new PageRouterAttached(object);
    return attached;
}

QSet<QObject*> flatParentTree(QObject* object)
{
    // See below comment in Climber::climbObjectParents for why this is here.
    static const QMetaObject* metaObject = QMetaType::metaObjectForType(QMetaType::type("QQuickItem*"));
    QSet<QObject*> ret;
    // Use an inline struct type so that climbItemParents and climbObjectParents
    // can call eachother
    struct Climber
    {
        void climbItemParents(QSet<QObject*> &out, QQuickItem *item) {
            auto parent = item->parentItem();
            while (parent != nullptr) {
                out << parent;
                climbObjectParents(out, parent);
                parent = parent->parentItem();
            }
        }
        void climbObjectParents(QSet<QObject*> &out, QObject *object) {
            auto parent = object->parent();
            while (parent != nullptr) {
                out << parent;
                // We manually call metaObject()->inherits() and
                // use a reinterpret cast because qobject_cast seems
                // to have stability issues here due to mutable 
                // pointer mechanics.
                if (parent->metaObject()->inherits(metaObject)) {
                    climbItemParents(out, reinterpret_cast<QQuickItem*>(parent));
                }
                parent = parent->parent();
            }
        }
    };
    Climber climber;
    if (qobject_cast<QQuickItem*>(object)) {
        climber.climbItemParents(ret, qobject_cast<QQuickItem*>(object));
    }
    climber.climbObjectParents(ret, object);
    return ret;
}

void PageRouter::preload(ParsedRoute* route)
{
    for (auto preloaded : qAsConst(m_preload.items)) {
        if (preloaded->equals(route)) {
            delete route;
            return;
        }
    }
    if (!routesContainsKey(route->name)) {
        qCritical() << "Route" << route->name << "not defined";
        delete route;
        return;
    }
    auto context = qmlContext(this);
    auto component = routesValueForKey(route->name);
    auto createAndCache = [component, context, route, this]() {
        auto item = component->beginCreate(context);
        item->setParent(this);
        auto qqItem = qobject_cast<QQuickItem*>(item);
        if (!qqItem) {
            qCritical() << "Route" << route->name << "is not an item! This is undefined behaviour and will likely crash your application.";
        }
        for ( auto it = route->properties.begin(); it != route->properties.end(); it++ ) {
            qqItem->setProperty(qUtf8Printable(it.key()), it.value());
        }
        route->setItem(qqItem);
        route->cache = routesCacheForKey(route->name);
        auto attached = qobject_cast<PageRouterAttached*>(qmlAttachedPropertiesObject<PageRouter>(item, true));
        attached->m_router = this;
        component->completeCreate();
        if (!route->cache) {
            qCritical() << "Route" << route->name << "is being preloaded despite it not having caching enabled.";
            delete route;
            return;
        }
        auto string = route->name;
        auto hash = route->hash();
        m_preload.insert(qMakePair(string, hash), route, routesCostForKey(route->name));
    };

    if (component->status() == QQmlComponent::Ready) {
        createAndCache();
    } else if (component->status() == QQmlComponent::Loading) {
        connect(component, &QQmlComponent::statusChanged, [=](QQmlComponent::Status status) {
            // Loading can only go to Ready or Error.
            if (status != QQmlComponent::Ready) {
                qCritical() << "Failed to push route:" << component->errors();
            }
            createAndCache();
        });
    } else {
        qCritical() << "Failed to push route:" << component->errors();
    }
}

void PageRouter::unpreload(ParsedRoute* route)
{
    ParsedRoute* toDelete = nullptr;
    for (auto preloaded : qAsConst(m_preload.items)) {
        if (preloaded->equals(route)) {
            toDelete = preloaded;
        }
    }
    if (toDelete != nullptr) {
        m_preload.take(qMakePair(toDelete->name, toDelete->hash()));
        delete toDelete;
    }
    delete route;
}

void PreloadRouteGroup::handleChange()
{
    if (!(m_parent->m_router)) {
        qCritical() << "PreloadRouteGroup does not have a parent PageRouter";
        return;
    }
    auto r = m_parent->m_router;
    auto parsed = parseRoute(m_route);
    if (m_when) {
        r->preload(parsed);
    } else {
        r->unpreload(parsed);
    }
}

PreloadRouteGroup::~PreloadRouteGroup()
{
    if (m_parent->m_router) {
        m_parent->m_router->unpreload(parseRoute(m_route));
    }
}

void PageRouterAttached::findParent()
{
    QQuickItem *parent = qobject_cast<QQuickItem *>(this->parent());
    while (parent != nullptr) {
        auto attached = qobject_cast<PageRouterAttached*>(qmlAttachedPropertiesObject<PageRouter>(parent, false));
        if (attached != nullptr && attached->m_router != nullptr) {
            m_router = attached->m_router;
            Q_EMIT routerChanged();
            Q_EMIT dataChanged();
            Q_EMIT isCurrentChanged();
            Q_EMIT navigationChanged();
            break;
        }
        parent = parent->parentItem();
    }
}

void PageRouterAttached::navigateToRoute(QJSValue route)
{
    if (m_router) {
        m_router->navigateToRoute(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

bool PageRouterAttached::routeActive(QJSValue route)
{
    if (m_router) {
        return m_router->routeActive(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return false;
    }
}

void PageRouterAttached::pushRoute(QJSValue route)
{
    if (m_router) {
        m_router->pushRoute(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

void PageRouterAttached::popRoute()
{
    if (m_router) {
        m_router->popRoute();
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

void PageRouterAttached::bringToView(QJSValue route)
{
    if (m_router) {
        m_router->bringToView(route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return;
    }
}

/*!
    \qmlattachedproperty variant PageRouter::data

    The data for the page this item belongs to. Accessing this property
    outside of a PageRouter will result in undefined behavior.
*/

QVariant PageRouterAttached::data() const
{
    if (m_router) {
        return m_router->dataFor(parent());
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return QVariant();
    }
}

/*!
    \qmlattachedproperty bool PageRouter::isCurrent

    Whether the page this item belongs to is the current index of the ColumnView.
    Accessing this property outside of a PageRouter will result in undefined behaviour.
*/

bool PageRouterAttached::isCurrent() const
{
    if (m_router) {
        return m_router->isActive(parent());
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return false;
    }
}

/*!
    \qmlattachedproperty bool PageRouter::watchedRouteActive

    Whether the watchedRoute is currently active.

    \sa PageRouter::watchedRoute
*/

bool PageRouterAttached::watchedRouteActive()
{
    if (m_router) {
        return m_router->routeActive(m_watchedRoute);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
        return false;
    }
}

void PageRouterAttached::setWatchedRoute(QJSValue route)
{
    m_watchedRoute = route;
    Q_EMIT watchedRouteChanged();
}

/*!
    \qmlattachedproperty PageRouter PageRouter::router

    The PageRouter that this item belongs to.
*/

/*!
    \qmlattachedproperty object PageRouter::preload.route

    The route to preload.
*/

/*!
    \qmlattachedproperty object PageRouter::preload.when

    When the route should be preloaded.
*/

/*!
    \qmlattachedproperty object PageRouter::watchedRoute

    Which route this PageRouterAttached should watch for.

    \quotefile PageRouterWatchedRoute.qml

    \sa PageRouter::watchedRouteActive
*/

QJSValue PageRouterAttached::watchedRoute()
{
    return m_watchedRoute;
}

void PageRouterAttached::pushFromHere(QJSValue route)
{
    if (m_router) {
        m_router->pushFromObject(parent(), route);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
    }
}

void PageRouterAttached::replaceFromHere(QJSValue route)
{
    if (m_router) {
        m_router->pushFromObject(parent(), route, true);
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
    }
}

void PageRouterAttached::popFromHere()
{
    if (m_router) {
        m_router->pushFromObject(parent(), QJSValue());
    } else {
        qCritical() << "PageRouterAttached does not have a parent PageRouter";
    }
}

void PageRouter::placeInCache(ParsedRoute *route)
{
    Q_ASSERT(route);
    if (!route->cache) {
        delete route;
        return;
    }
    auto string = route->name;
    auto hash = route->hash();
    m_cache.insert(qMakePair(string, hash), route, routesCostForKey(route->name));
}

void PageRouter::pushFromObject(QObject *object, QJSValue inputRoute, bool replace)
{
    const auto parsed = parseRoutes(inputRoute);
    const auto objects = flatParentTree(object);

    for (const auto& obj : objects) {
        bool popping = false;
        for (auto route : qAsConst(m_currentRoutes)) {
            if (popping) {
                m_currentRoutes.removeAll(route);
                reevaluateParamMapProperties();
                placeInCache(route);
                continue;
            }
            if (route->item == obj) {
                m_pageStack->pop(route->item);
                if (replace) {
                    m_currentRoutes.removeAll(route);
                    reevaluateParamMapProperties();
                    m_pageStack->removeItem(route->item);
                }
                popping = true;
            }
        }
        if (popping) {
            if (!inputRoute.isUndefined()) {
                for (auto route : parsed) {
                    push(route);
                }
            }
            Q_EMIT navigationChanged();
            return;
        }
    }
    qWarning() << "Object" << object << "not in current routes";
}

QJSValue PageRouter::currentRoutes() const
{
    auto engine = qjsEngine(this);
    auto ret = engine->newArray(m_currentRoutes.length());
    for (int i = 0; i < m_currentRoutes.length(); ++i) {
        auto object = engine->newObject();
        object.setProperty(QStringLiteral("route"), m_currentRoutes[i]->name);
        object.setProperty(QStringLiteral("data"), engine->toScriptValue(m_currentRoutes[i]->data));
        auto keys = m_currentRoutes[i]->properties.keys();
        for (auto key : keys) {
            object.setProperty(key, engine->toScriptValue(m_currentRoutes[i]->properties[key]));
        }
        ret.setProperty(i, object);
    }
    return ret;
}

PageRouterAttached::PageRouterAttached(QObject *parent) : QObject(parent), m_preload(new PreloadRouteGroup(this))
{
    findParent();
    auto item = qobject_cast<QQuickItem*>(parent);
    if (item != nullptr) {
        connect(item, &QQuickItem::windowChanged, this, [this]() {
            findParent();
        });
        connect(item, &QQuickItem::parentChanged, this, [this]() {
            findParent();
        });
    }
}
