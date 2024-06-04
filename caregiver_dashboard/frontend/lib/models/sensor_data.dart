class SensorData {
  final String timeInterval;
  final double avgHeartRate;

  SensorData({
    required this.timeInterval,
    required this.avgHeartRate,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timeInterval: json['timeInterval'] ?? '', // Default to empty string if null
      avgHeartRate: json['avgHeartRate']?.toDouble() ?? 0.0, // Default to 0.0 if null
    );
  }
}
