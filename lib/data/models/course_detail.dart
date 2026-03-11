import 'course.dart';

class CourseDetail {
  final Course course;
  final List<Teacher> teachers;
  final List<dynamic> qlht;
  final List<CourseStudent> students;
  final List<CourseSection> sections;

  CourseDetail({
    required this.course,
    required this.teachers,
    required this.qlht,
    required this.students,
    required this.sections,
  });

  factory CourseDetail.fromJson(Map<String, dynamic> json) {
    return CourseDetail(
      course: Course.fromJson(json['course'] ?? {}),
      teachers: (json['teacher'] as List?)
              ?.map((t) => Teacher.fromJson(t))
              .toList() ??
          [],
      qlht: json['qlht'] ?? [],
      students: (json['student'] as List?)
              ?.map((s) => CourseStudent.fromJson(s))
              .toList() ??
          [],
      sections: (json['section'] as List?)
              ?.map((s) => CourseSection.fromJson(s))
              .toList() ??
          [],
    );
  }
}

class CourseStudent {
  final int id;
  final String? fullname;
  final String? profileimageurl;

  CourseStudent({required this.id, this.fullname, this.profileimageurl});

  factory CourseStudent.fromJson(Map<String, dynamic> json) {
    return CourseStudent(
      id: json['id'] ?? 0,
      fullname: json['fullname'],
      profileimageurl: json['profileimageurl'],
    );
  }
}

class CourseSection {
  final int id;
  final String name;
  final String? summary;
  final String? summaryStripped;
  final List<CourseModule> modules;

  CourseSection({
    required this.id,
    required this.name,
    this.summary,
    this.summaryStripped,
    required this.modules,
  });

  factory CourseSection.fromJson(Map<String, dynamic> json) {
    return CourseSection(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      summary: json['summary'],
      summaryStripped: json['summary_striptag'],
      modules: (json['modules'] as List?)
              ?.map((m) => CourseModule.fromJson(m))
              .toList() ??
          [],
    );
  }
}

class CourseModule {
  final int id;
  final String name;
  final String modname; // e.g. 'resource', 'quiz'
  final String? url;

  CourseModule({
    required this.id,
    required this.name,
    required this.modname,
    this.url,
  });

  factory CourseModule.fromJson(Map<String, dynamic> json) {
    return CourseModule(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      modname: json['modname'] ?? '',
      url: json['url'],
    );
  }
}
