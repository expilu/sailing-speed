class SpeedUtils {
  /// Quite obviously converts a speed from m/s to knots. You can choose the
  /// decimal precision
  static double toKnots(double metersPerSecond, {decimalPositions = 1}) =>
      double.parse(
          (metersPerSecond * 1.94384).toStringAsFixed(decimalPositions));

  /// Quite obviously converts a speed from m/s to Km/h
  static int toKmh(double metersPerSecond) => (metersPerSecond * 3.6).round();
}
