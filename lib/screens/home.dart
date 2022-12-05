import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sailing_speed/providers/gps.dart';
import 'package:sailing_speed/widgets/debug/gps_status.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: Stack(
        children: [
          Center(child: Text('${ref.watch(providerSpeedKnots) ?? '-'}')),
          const Positioned(bottom: 0.0, child: DebugGpsStatus()),
        ],
      ),
    );
  }
}
