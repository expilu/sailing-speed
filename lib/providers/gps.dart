import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sailing_speed/utils/speed.dart';

/// Provides if location services are enabled in the device so the app is able
/// to use GPS
final providerLocationEnabled =
    FutureProvider.autoDispose((ref) => Geolocator.isLocationServiceEnabled());

/// Provides if the app has permissions to use location services.
/// If permission is denied, it will ask the user for it
final providerLocationPermission = FutureProvider.autoDispose((ref) async {
  final locationEnabled = await ref.watch(providerLocationEnabled.future);

  if (locationEnabled) {
    LocationPermission permission = await Geolocator.checkPermission();

    // When the permission is denied ask for it and await.
    // Keep in mind that if the result was deniedForever, the app can no longer
    // ask for permissions and the user must be directed to the app settings
    // in the system to get permission
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    return permission;
  } else {
    return LocationPermission.unableToDetermine;
  }
});

/// Provides if the app can use GPS
final providerHasLocationPermission = FutureProvider.autoDispose((ref) async {
  final locationPermission = await ref.watch(providerLocationPermission.future);

  switch (locationPermission) {
    case LocationPermission.denied:
    case LocationPermission.deniedForever:
    case LocationPermission.unableToDetermine:
      return false;
    case LocationPermission.whileInUse:
    case LocationPermission.always:
      return true;
  }
});

/// Provides the enabled accuracy for GPS services. Mainly to react to having
/// reduced accuracy to inform the user to change settings to precise accuracy
final providerLocationAccuracy = FutureProvider.autoDispose((ref) async {
  final hasLocationPermission =
      await ref.watch(providerHasLocationPermission.future);

  if (hasLocationPermission) {
    return await Geolocator.getLocationAccuracy();
  } else {
    return LocationAccuracyStatus.unknown;
  }
});

/// Provides updates on the current status of the GPS service
final providerGpsServiceStatus = Provider.autoDispose<ServiceStatus?>((ref) {
  final hasLocationPermission =
      ref.watch(providerHasLocationPermission).asData?.value ?? false;

  StreamSubscription<ServiceStatus>? statusStream;

  if (hasLocationPermission) {
    statusStream = Geolocator.getServiceStatusStream()
        .listen((status) => ref.state = status);
  }

  ref.onDispose(() => statusStream?.cancel());

  return null;
});

/// Listens to GPS position fixes and provides them. Position fixes include
/// speed and heading
final providerGpsPositionFix = Provider.autoDispose<Position?>((ref) {
  final hasLocationPermission =
      ref.watch(providerHasLocationPermission).asData?.value ?? false;

  StreamSubscription<Position>? positionStream;

  late LocationSettings locationSettings;

  if (defaultTargetPlatform == TargetPlatform.android) {
    locationSettings = AndroidSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      intervalDuration: const Duration(milliseconds: 100),
    );
  } else if (defaultTargetPlatform == TargetPlatform.iOS) {
    locationSettings = AppleSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      activityType: ActivityType.otherNavigation,
      pauseLocationUpdatesAutomatically: false,
    );
  } else {
    locationSettings =
        const LocationSettings(accuracy: LocationAccuracy.bestForNavigation);
  }

  if (hasLocationPermission) {
    positionStream =
        Geolocator.getPositionStream(locationSettings: locationSettings)
            .listen((position) => ref.state = position);
  }

  ref.onDispose(() => positionStream?.cancel());

  return null;
});

/// Provides the time passed between GPS fixes
final providerGpsUpdateInterval = Provider.autoDispose<Duration?>((ref) {
  ref.listen(providerGpsPositionFix, (previous, next) {
    if (previous?.timestamp != null && next?.timestamp != null) {
      ref.state = next!.timestamp!.difference(previous!.timestamp!);
    } else {
      ref.state = null;
    }
  });

  return null;
});

/// Provides the current speed in m/s, when available
final providerSpeed =
    Provider.autoDispose((ref) => ref.watch(providerGpsPositionFix)?.speed);

/// Provides the current speed in knots, when available
final providerSpeedKnots = Provider.autoDispose<double?>((ref) {
  double? speed = ref.watch(providerSpeed);

  if (speed != null) {
    speed = SpeedUtils.toKnots(speed);
  }

  return speed;
});

/// Provides the current speed in Km/h, when available
final providerSpeedKmh = Provider.autoDispose<int?>((ref) {
  double? speedMs = ref.watch(providerSpeed);
  int? speedKmh;

  if (speedMs != null) {
    speedKmh = SpeedUtils.toKmh(speedMs);
  }

  return speedKmh;
});
