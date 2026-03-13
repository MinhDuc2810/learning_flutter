import 'dart:convert';

class Course {
  final String id;
  final String fullname;
  final String? shortname;
  final String? courseimage; // base64 SVG or URL
  final int? startdate; // Unix timestamp
  final int? enddate; // Unix timestamp
  final String? ngayThi;
  final double progress;
  final String? summary;
  final String? slburl;
  final List<Teacher> teachers;

  Course({
    required this.id,
    required this.fullname,
    this.shortname,
    this.courseimage,
    this.summary,
    this.startdate,
    this.enddate,
    this.ngayThi,
    this.slburl,
    this.progress = 0,
    this.teachers = const [],
  });

  String get formattedStartDate {
    if (startdate == null || startdate == 0) return "Chưa xác định";
    final date = DateTime.fromMillisecondsSinceEpoch(startdate! * 1000);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String get instructorName {
    if (teachers.isEmpty) return "Đang cập nhật";
    final t = teachers.first;
    // Format "LastName FirstName" or whatever the user prefers.
    return "${t.lastname} ${t.firstname}".trim();
  }

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id']?.toString() ?? '',
      fullname: json['fullname'] ?? '',
      shortname: json['shortname'],
      courseimage: json['courseimage'],
      summary: json['summary'],
      startdate: json['startdate'],
      enddate: json['enddate'],
      ngayThi: json['ngay_thi'],
      slburl: json['slburl'],
      progress: (json['progress'] ?? 0).toDouble(),
      teachers: (json['teachers'] as List?)
              ?.map((t) => Teacher.fromJson(t))
              .toList() ??
          [],
    );
  }
}

class Teacher {
  final int id;
  final String firstname;
  final String lastname;
  final String? avatar;

  Teacher({
    required this.id,
    required this.firstname,
    required this.lastname,
    this.avatar,
  });

  factory Teacher.fromJson(Map<String, dynamic> json) {
    return Teacher(
      id: json['id'] ?? 0,
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      avatar: json['avatar'],
    );
  }
}
