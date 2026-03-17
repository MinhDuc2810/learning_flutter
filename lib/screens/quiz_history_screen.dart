import 'package:flutter/material.dart';
import '../data_providers/quiz.dart';
import '../utils/html_utils.dart';
import '../theme/ons_color.dart';
import '../data/models/course.dart';
import './do_test_result_screen.dart';
import './do_test_screen.dart';

class QuizHistoryScreen extends StatefulWidget {
  final int quizId;
  final String courseId;
  final String quizName;
  final String courseName;
  final String instructorName;
  final Teacher? quizTeacher;

  const QuizHistoryScreen({
    super.key,
    required this.quizId,
    required this.courseId,
    required this.quizName,
    required this.courseName,
    required this.instructorName,
    this.quizTeacher,
  });

  @override
  State<QuizHistoryScreen> createState() => _QuizHistoryScreenState();
}

class _QuizHistoryScreenState extends State<QuizHistoryScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _quiz;
  List<dynamic> _attempts = [];
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchHistory();
  }

  Future<void> _fetchHistory() async {
    try {
      final response = await QuizAPI.historyQuiz(quizId: widget.quizId);
      if (mounted) {
        setState(() {
          // Robust parsing of response
          if (response is Map) {
            _quiz = response['quiz'];
            final rawAttempts = response['attempts'];
            if (rawAttempts is List) {
              _attempts = List.from(rawAttempts);
            } else {
              _attempts = [];
            }
          }

          // Safe sort: handle strings, nulls, and ints
          _attempts.sort((a, b) {
            final aVal = int.tryParse(a['attempt']?.toString() ?? '0') ?? 0;
            final bVal = int.tryParse(b['attempt']?.toString() ?? '0') ?? 0;
            return bVal.compareTo(aVal);
          });
          
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Lỗi khi tải lịch sử luyện tập";
          _isLoading = false;
        });
      }
    }
  }

  String _getGradeMethod(dynamic method) {
    int m = 0;
    if (method is int) m = method;
    if (method is String) m = int.tryParse(method) ?? 0;

    switch (m) {
      case 1: return "Điểm làm bài cao nhất";
      case 2: return "Điểm trung bình";
      case 3: return "Điểm lần đầu";
      case 4: return "Điểm lần cuối";
      default: return "Không xác định";
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null || timestamp == 0 || timestamp == "") return "Không xác định";
    
    int ts;
    if (timestamp is String) {
      ts = int.tryParse(timestamp) ?? 0;
    } else {
      ts = timestamp as int;
    }
    
    if (ts == 0) return "Không xác định";
    
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatDuration(dynamic start, dynamic finish) {
    if (start == null || finish == null || finish == 0) return "--";
    
    int s = (start is String) ? (int.tryParse(start) ?? 0) : (start as int);
    int f = (finish is String) ? (int.tryParse(finish) ?? 0) : (finish as int);
    
    if (f == 0) return "--";
    
    final duration = f - s;
    if (duration < 60) return "$duration giây";
    final minutes = duration ~/ 60;
    final seconds = duration % 60;
    if (minutes < 60) return "$minutes phút $seconds giây";
    
    final hours = minutes ~/ 60;
    final remMinutes = minutes % 60;
    return "$hours giờ $remMinutes phút";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.quizName)),
        body: Center(child: Text(_error!)),
      );
    }

    // Use data from API or fall back to defaults
    String userGrade = _quiz?['usergrade']?.toString() ?? "0.00";
    
    // Fallback: if usergrade is not in quiz object, find the maximum grade in attempts
    if ((userGrade == "0.00" || userGrade == "0") && _attempts.isNotEmpty) {
      double maxGrade = 0;
      for (var attempt in _attempts) {
        final g = double.tryParse(attempt['grade']?.toString() ?? attempt['sumgrades']?.toString() ?? "0") ?? 0;
        if (g > maxGrade) maxGrade = g;
      }
      if (maxGrade > 0) {
        userGrade = maxGrade.toStringAsFixed(2);
      }
    }

    final intro = _quiz?['intro'] ?? "";

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _fetchHistory,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.quizName,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (intro.isNotEmpty)
                      Text(
                        HtmlUtils.stripHtml(intro),
                        style: const TextStyle(fontSize: 15, color: Colors.black87, height: 1.5),
                      ),
                    const SizedBox(height: 24),
                    _buildInfoRow("Phương pháp chấm điểm", _getGradeMethod(_quiz?['grademethod'])),
                    _buildInfoRow("Thời gian mở luyện tập", _formatDateTime(_quiz?['timeopen'])),
                    _buildInfoRow("Thời gian đóng luyện tập", _formatDateTime(_quiz?['timeclose'])),
                    const SizedBox(height: 24),
                    Row(
                      children: [
                        const Text(
                          "Điểm làm bài cao nhất ",
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                        ),
                        Text(
                          userGrade,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: HexColor(StringColor.primary1),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_attempts.isEmpty)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 32),
                          child: Text("Bạn chưa thực hiện lần làm bài nào."),
                        ),
                      )
                    else
                      ..._attempts.map((attempt) => _buildAttemptCard(attempt)),
                  ],
                ),
              ),
            ),
          ),
          _buildBottomButton(),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        bottom: 24,
        left: 8,
        right: 16,
      ),
      width: double.infinity,
      decoration: BoxDecoration(
        color: HexColor(StringColor.primary1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.courseName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 14,
                      backgroundColor: Colors.white.withOpacity(0.2),
                      backgroundImage: (widget.quizTeacher?.avatar != null && widget.quizTeacher!.avatar!.isNotEmpty)
                          ? NetworkImage(widget.quizTeacher!.avatar!)
                          : null,
                      child: (widget.quizTeacher?.avatar == null || widget.quizTeacher!.avatar!.isEmpty)
                          ? const Icon(Icons.person, size: 20, color: Colors.white)
                          : null,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      "Giảng viên: ${widget.instructorName}",
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: Colors.black, fontSize: 15, height: 1.5),
          children: [
            TextSpan(text: "$label: "),
            TextSpan(
              text: value,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttemptCard(dynamic attempt) {
    final int attemptNum = attempt['attempt'] ?? 0;
    final String state = attempt['state'] ?? "";
    final bool isFinished = state == "finished";
    
    // Use "grade" or "sumgrades" based on what's available
    dynamic rawGrade = attempt['grade'] ?? attempt['sumgrades'] ?? "0";
    String gradeValue = rawGrade.toString();
    double? gradeDouble = double.tryParse(gradeValue);
    if (gradeDouble != null) {
      gradeValue = gradeDouble.toStringAsFixed(2);
    }
    
    final statusText = isFinished ? "Hoàn thành" : "Chưa hoàn thành";
    final durationText = _formatDuration(attempt['timestart'], attempt['timefinish']);
    final dateText = _formatDateTime(attempt['timefinish'] ?? attempt['timemodified'] ?? attempt['timestart']);

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF8F9FA),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFEEEEEE)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Lần $attemptNum",
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                InkWell(
                  onTap: () {
                    if (isFinished) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoTestResultScreen(
                            quizId: widget.quizId,
                            attemptId: attempt['id'] ?? 0,
                            quizName: widget.quizName,
                          ),
                        ),
                      );
                    } else {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => DoTestScreen(
                            quizId: widget.quizId,
                            attemptId: attempt['id'] ?? 0,
                            quizName: widget.quizName,
                            courseId: int.tryParse(widget.courseId),
                          ),
                        ),
                      );
                    }
                  },
                  child: Text(
                    isFinished ? "Xem lại >" : "Tiếp tục >",
                    style: TextStyle(
                      color: HexColor(StringColor.primary1),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, thickness: 1, color: Color(0xFFEEEEEE)),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAttemptInfoItem(
                      "Điểm",
                      gradeValue,
                      icon: isFinished ? Icons.check_circle : Icons.cancel,
                      iconColor: isFinished ? Colors.green : Colors.red,
                    ),
                    _buildAttemptInfoItem("Trạng thái", statusText, alignRight: true),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildAttemptInfoItem("Thời gian", durationText),
                    _buildAttemptInfoItem("Ngày", dateText, alignRight: true),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAttemptInfoItem(
    String label,
    String value, {
    IconData? icon,
    Color? iconColor,
    bool alignRight = false,
  }) {
    return Column(
      crossAxisAlignment: alignRight ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: 13),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!alignRight && icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 4),
                child: Icon(icon, size: 18, color: iconColor),
              ),
            Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
            ),
            if (alignRight && icon != null)
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Icon(icon, size: 18, color: iconColor),
              ),
          ],
        ),
      ],
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () {
          if (_attempts.isNotEmpty) {
            // Find the first unfinished attempt if any
            final unfinished = _attempts.firstWhere(
              (a) => a['state'] != "finished",
              orElse: () => _attempts.first,
            );
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => DoTestScreen(
                  quizId: widget.quizId,
                  attemptId: unfinished['id'] ?? 0,
                  quizName: widget.quizName,
                  courseId: int.tryParse(widget.courseId),
                ),
              ),
            );
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: HexColor(StringColor.primary1),
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          elevation: 0,
        ),
        child: const Text(
          "Tiếp tục làm bài",
          style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
