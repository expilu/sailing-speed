import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailing_speed/providers/gps.dart';

class DebugGpsStatus extends ConsumerWidget {
  const DebugGpsStatus({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationEnabledStatus = ref.watch(providerLocationEnabled).when(
          loading: () => 'loading',
          data: (data) => data ? 'enabled' : 'disabled',
          error: (error, st) => 'error',
        );

    final locationPermissionStatus = ref.watch(providerLocationPermission).when(
          loading: () => 'loading',
          data: (data) => data.name,
          error: (error, st) => 'error',
        );

    final positionFix = ref.watch(providerGpsPositionFix);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location services: $locationEnabledStatus'),
        Text('Location permission: $locationPermissionStatus'),
        Text(
            'Has location permission: ${(ref.watch(providerHasLocationPermission).asData?.value ?? false) ? 'yes' : 'no'}'),
        Text('Latitude: ${positionFix?.latitude ?? '-'}'),
        Text('Longitude: ${positionFix?.longitude ?? '-'}'),
        Text('Location accuracy: ${positionFix?.accuracy ?? '-'}'),
        Text(
            'Location accuracy status: ${ref.watch(providerLocationAccuracy).asData?.value.name ?? '-'}'),
        Text('Speed: ${positionFix?.speed ?? '-'}'),
        Text('Speed accuracy: ${positionFix?.speedAccuracy ?? '-'}'),
        Text('Heading: ${positionFix?.heading ?? '-'}'),
        Text('Altitude: ${positionFix?.altitude ?? '-'}'),
        Text(
            'Mocked: ${positionFix != null ? (positionFix.isMocked ? 'yes' : 'no') : '-'}'),
      ],
    );
  }
}
