class SensorData {
  final DateTime timestamp;
  final double value;

  SensorData({
    required this.timestamp,
    required this.value,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      timestamp: DateTime.parse(json['Timestamp']),
      value: json['Value'].toDouble(),
    );
  }
}
