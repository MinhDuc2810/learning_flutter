class AcademicResult {
  final int courseId;
  final String courseName;
  final String? courseCode;
  final String status;
  final String? examDateExpected;
  final String? startDate;
  final String? endDate;
  final String? examDate;
  final String midTermGrade;
  final String attendanceGrade;
  final String attendanceGradeOriginal;
  final String processGrade;
  final String? processGradeFormula;
  final String examCondition;
  final bool showProcessGrade;

  AcademicResult({
    required this.courseId,
    required this.courseName,
    this.courseCode,
    required this.status,
    this.examDateExpected,
    this.startDate,
    this.endDate,
    this.examDate,
    required this.midTermGrade,
    required this.attendanceGrade,
    required this.attendanceGradeOriginal,
    required this.processGrade,
    this.processGradeFormula,
    required this.examCondition,
    required this.showProcessGrade,
  });

  factory AcademicResult.fromJson(Map<String, dynamic> json) {
    return AcademicResult(
      courseId: json['courseid'] ?? 0,
      courseName: json['ten_mon'] ?? '',
      courseCode: json['ma_mon'],
      status: json['trang_thai'] ?? '',
      examDateExpected: json['ngay_thi_du_kien'],
      startDate: json['ngay_bat_dau'],
      endDate: json['ngay_ket_thuc'],
      examDate: json['ngay_thi'],
      midTermGrade: json['diem_kiem_tra_giua_ky']?.toString() ?? '0',
      attendanceGrade: json['diem_chuyen_can']?.toString() ?? '0',
      attendanceGradeOriginal:
          json['diem_chuyen_can_original']?.toString() ?? '0',
      processGrade: json['diem_qua_trinh']?.toString() ?? '0',
      processGradeFormula: json['cong_thuc_diem_qua_trinh'],
      examCondition: json['dieu_kien_thi'] ?? '',
      showProcessGrade: json['hien_diem_qua_trinh'] ?? false,
    );
  }
}
