class SpeedUtils {
  /// Quite obviously convert a speed from m/s to knots. You can choose the
  /// decimal precision
  static double toKnots(double metersPerSecond, {decimalPositions = 1}) =>
      double.parse(
          (metersPerSecond * 1.94384).toStringAsFixed(decimalPositions));
}
