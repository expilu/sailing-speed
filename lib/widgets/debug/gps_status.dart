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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Location services: $locationEnabledStatus'),
        Text('Location permission: $locationPermissionStatus'),
        Text(
            'Has location permission: ${(ref.watch(providerHasLocationPermission).asData?.value ?? false) ? 'yes' : 'no'}'),
      ],
    );
  }
}
