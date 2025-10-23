import 'dart:async';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

typedef OrientationSetter = Future<void> Function(
  List<DeviceOrientation> orientations,
);

/// Centralizes app-wide orientation preferences and applies overrides per route.
class RouteOrientationController {
  RouteOrientationController({
    required List<DeviceOrientation> defaultOrientations,
    Map<String, List<DeviceOrientation>> routeOverrides = const {},
    OrientationSetter? setter,
  })  : assert(
          defaultOrientations.isNotEmpty,
          'defaultOrientations must not be empty; provide at least one valid DeviceOrientation',
        ),
        defaultOrientations = List.unmodifiable(defaultOrientations),
        routeOverrides = Map.unmodifiable(
          routeOverrides.map<String, List<DeviceOrientation>>(
            (key, value) => MapEntry<String, List<DeviceOrientation>>(
              key,
              List<DeviceOrientation>.unmodifiable(value),
            ),
          ),
        ),
        _setter = setter ?? SystemChrome.setPreferredOrientations;

  /// Default orientations applied when no explicit route override exists.
  final List<DeviceOrientation> defaultOrientations;

  /// Map of route names to orientation overrides. Each entry is stored as an unmodifiable list.
  final Map<String, List<DeviceOrientation>> routeOverrides;

  final OrientationSetter _setter;

  late final NavigatorObserver navigatorObserver =
      _RouteOrientationObserver(this);

  /// Applies the default orientations to the device.
  ///
  /// Returns a Future that resolves when [SystemChrome.setPreferredOrientations]
  /// completes. If the operation fails, the Future will complete with an error.
  Future<void> applyDefault() => _setter(defaultOrientations);

  /// Applies the orientations for the given [routeName].
  ///
  /// If a route-specific override exists in [routeOverrides], those orientations
  /// are applied. Otherwise, falls back to [defaultOrientations].
  ///
  /// Parameters:
  ///   - [routeName]: The name of the route (from route settings).
  ///
  /// Returns a Future that resolves when [SystemChrome.setPreferredOrientations]
  /// completes. If the operation fails, the Future will complete with an error.
  Future<void> applyForRoute(String? routeName) =>
      _setter(routeOverrides[routeName] ?? defaultOrientations);
}

class _RouteOrientationObserver extends NavigatorObserver {
  _RouteOrientationObserver(this._controller);

  final RouteOrientationController _controller;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPush(route, previousRoute);
    _controller.applyForRoute(route.settings.name).catchError(
      (Object error, StackTrace stackTrace) {
        debugPrint(
          'RouteOrientationController.didPush failed for route '${route.settings.name}': $error\n$stackTrace',
        );
      },
    );
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    super.didReplace(newRoute: newRoute, oldRoute: oldRoute);
    _controller.applyForRoute(newRoute?.settings.name).catchError(
      (Object error, StackTrace stackTrace) {
        debugPrint(
          'RouteOrientationController.didReplace failed for route '${newRoute?.settings.name}': $error\n$stackTrace',
        );
      },
    );
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didPop(route, previousRoute);
    _controller.applyForRoute(previousRoute?.settings.name).catchError(
      (Object error, StackTrace stackTrace) {
        debugPrint(
          'RouteOrientationController.didPop failed for route '${previousRoute?.settings.name}': $error\n$stackTrace',
        );
      },
    );
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    super.didRemove(route, previousRoute);
    _controller.applyForRoute(previousRoute?.settings.name).catchError(
      (Object error, StackTrace stackTrace) {
        debugPrint(
          'RouteOrientationController.didRemove failed for route '${previousRoute?.settings.name}': $error\n$stackTrace',
        );
      },
    );
  }
}
