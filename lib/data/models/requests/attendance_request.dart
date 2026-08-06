class AttendanceRequest {
  final int status;

  const AttendanceRequest({required this.status});

  Map<String, dynamic> toJson() => {'status': status};
}
