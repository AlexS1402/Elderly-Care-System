class Schedule {
  final String time;

  Schedule({required this.time});

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      time: json['ScheduledTime'],
    );
  }
}
