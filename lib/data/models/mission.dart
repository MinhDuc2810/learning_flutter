class Mission {
  final String id;
  final String name;
  final String courseId;
  final String courseName;
  final int state; // 0: incomplete, 1: complete, etc.
  final int deadline; // Unix timestamp
  final String type; // e.g., 'quiz', 'assign', 'resource'

  Mission({
    required this.id,
    required this.name,
    required this.courseId,
    required this.courseName,
    required this.state,
    this.deadline = 0,
    this.type = 'quiz',
  });

  String get stateName {
    switch (state) {
      case 1:
        return "Đã hoàn thành";
      case 0:
      default:
        return "Chưa hoàn thành";
    }
  }

  String? get formattedDeadline {
    if (deadline == 0) return null;
    final date = DateTime.fromMillisecondsSinceEpoch(deadline * 1000);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  factory Mission.fromJson(Map<String, dynamic> json) {
    return Mission(
      id: json['cmid']?.toString() ?? '',
      name: json['fullname'] ?? json['name'] ?? '',
      courseId: json['courseid']?.toString() ?? '',
      courseName: json['coursename'] ?? 'Khóa học',
      state: json['state'] ?? 0,
      deadline: json['deadline'] is int ? json['deadline'] : 0,
      type: json['modname'] ?? 'quiz',
    );
  }
}
