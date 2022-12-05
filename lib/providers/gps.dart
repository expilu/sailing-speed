import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

/// Provides if location services are enabled in the device so the app is able
/// to use GPS
final providerLocationEnabled =
    FutureProvider((ref) => Geolocator.isLocationServiceEnabled());

/// Provides if the app has permissions to use location services.
/// If permission is denied, it will ask the user for it
final providerLocationPermission = FutureProvider((ref) async {
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
final providerHasLocationPermission = FutureProvider((ref) async {
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

/// Listens to GPS position fixes and provides them. Position fixes include
/// speed and heading
final providerGpsPositionFix = Provider.autoDispose<Position?>((ref) {
  final hasLocationPermission =
      ref.watch(providerHasLocationPermission).asData?.value ?? false;

  StreamSubscription<Position>? positionStream;

  if (hasLocationPermission) {
    positionStream = Geolocator.getPositionStream(
        locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
    )).listen((position) => ref.state = position);
  }

  ref.onDispose(() => positionStream?.cancel());

  return null;
});
