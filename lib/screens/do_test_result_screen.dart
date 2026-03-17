import 'package:flutter/material.dart';
import '../data_providers/quiz.dart';
import './test_result_detail.dart';
import './do_test_screen.dart';

class DoTestResultScreen extends StatefulWidget {
  final int quizId;
  final int attemptId;
  final String quizName;

  const DoTestResultScreen({
    super.key,
    required this.quizId,
    required this.attemptId,
    required this.quizName,
  });

  @override
  State<DoTestResultScreen> createState() => _DoTestResultScreenState();
}

class _DoTestResultScreenState extends State<DoTestResultScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _data;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await QuizAPI.historyAttempt(attemptId: widget.attemptId);
      if (mounted) {
        setState(() {
          _data = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Lỗi khi tải kết quả làm bài";
          _isLoading = false;
        });
      }
    }
  }

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null || timestamp == 0 || timestamp == "") return "--";
    int ts = (timestamp is String) ? (int.tryParse(timestamp) ?? 0) : (timestamp as int);
    if (ts == 0) return "--";
    final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  String _formatDuration(dynamic duration) {
    if (duration == null) return "--";
    int d = (duration is String) ? (int.tryParse(duration) ?? 0) : (duration as int);
    if (d < 60) return "$d giây";
    final minutes = d ~/ 60;
    final seconds = d % 60;
    return "$minutes phút $seconds giây";
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF1A1A1A),
        body: Center(child: CircularProgressIndicator(color: Colors.white)),
      );
    }

    if (_error != null) {
      return Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: Center(child: Text(_error!, style: const TextStyle(color: Colors.white))),
      );
    }

    // Map data from local_quiz_get_attempt_review response
    // Typical response structure might differ, adjusting based on common Moodle API patterns
    final attempt = _data?['attempt'] ?? {};
    final questions = _data?['questions'] as List? ?? [];
    
    int totalQuestions = questions.length;
    int correctCount = 0;
    int wrongCount = 0;
    
    for (var q in questions) {
      final state = q['state']?.toString().toLowerCase();
      if (state == 'gradedright' || state == 'correct') {
        correctCount++;
      } else if (state == 'gradedwrong' || state == 'incorrect') {
        wrongCount++;
      }
    }
    
    // Raw score (e.g., number of correct answers)
    final rawScore = double.tryParse(attempt['sumgrades']?.toString() ?? "0") ?? correctCount.toDouble();
    // Max raw score is usually the number of questions (assuming each question is 1 point)
    final maxRawScore = totalQuestions > 0 ? totalQuestions.toDouble() : 10.0;
    
    // Scaled grade (scaled to 10 points)
    final scaledGrade = maxRawScore > 0 ? (rawScore / maxRawScore) * 10.0 : 0.0;
    
    final duration = (attempt['timefinish'] ?? 0) - (attempt['timestart'] ?? 0);

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          widget.quizName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          children: [
            const SizedBox(height: 20),
            // Score Circle (displays scaled grade / 10)
            _buildScoreCircle(scaledGrade, 10.0),
            const SizedBox(height: 40),
            
            // Stats rows
            _buildStatRow("Đã làm:", "$totalQuestions/$totalQuestions câu", isBold: true),
            _buildStatRow("Làm đúng:", "$correctCount câu", isBold: true, trailing: const Icon(Icons.check_circle, color: Colors.green, size: 24)),
            _buildStatRow("Làm sai:", "$wrongCount câu", isBold: true, trailing: const Icon(Icons.cancel, color: Colors.red, size: 24)),
            _buildStatRow("Điểm hệ số $totalQuestions:", "${rawScore.toInt()}/$totalQuestions đ", isBold: true),
            _buildStatRow("Điểm hệ số 10:", "${scaledGrade.toStringAsFixed(1)}/10 đ", isBold: true),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(color: Colors.white24, thickness: 1),
            ),
            
            // Time info
            _buildSummaryRow("Tổng thời gian làm bài", _formatDuration(duration)),
            _buildSummaryRow("Thời gian bắt đầu:", _formatDateTime(attempt['timestart'])),
            _buildSummaryRow("Thời gian kết thúc", _formatDateTime(attempt['timefinish'])),
            
            const SizedBox(height: 20),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Phản hồi",
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 12),
            const Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Bạn cần dành nhiều thời gian để học tập hơn nữa. Hãy cố gắng lên.",
                style: TextStyle(color: Colors.white, fontSize: 14, height: 1.5),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildScoreCircle(double score, double maxScore) {
    return Container(
      width: 160,
      height: 160,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white, width: 8),
      ),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              score.toStringAsFixed(1),
              style: const TextStyle(color: Colors.white, fontSize: 48, fontWeight: FontWeight.bold),
            ),
            Container(height: 2, width: 60, color: Colors.white54),
            Text(
              maxScore.toInt().toString(),
              style: const TextStyle(color: Colors.white70, fontSize: 24),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isBold = false, Widget? trailing}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 16),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          if (trailing != null) ...[
            const SizedBox(width: 8),
            trailing,
          ]
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.white, fontSize: 16)),
          Text(value, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TestResultDetailScreen(
                      quizId: widget.quizId,
                      attemptId: widget.attemptId,
                      quizName: widget.quizName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF66BB6A),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Xem chi tiết", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => DoTestScreen(
                      quizId: widget.quizId,
                      quizName: widget.quizName,
                    ),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A9F4),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Làm lại", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
