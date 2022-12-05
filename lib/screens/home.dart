import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailing_speed/providers/gps.dart';
import 'package:sailing_speed/widgets/debug/gps_status.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Column(
        children: [
          Text('${ref.watch(providerSpeedKnots) ?? '-'}'),
          const DebugGpsStatus(),
        ],
      ),
    );
  }
}
