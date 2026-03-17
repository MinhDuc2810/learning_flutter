import 'package:flutter/material.dart';
import '../data_providers/quiz.dart';
import '../utils/html_utils.dart';
import './do_test_screen.dart';

class TestResultDetailScreen extends StatefulWidget {
  final int quizId;
  final int attemptId;
  final String quizName;

  const TestResultDetailScreen({
    super.key,
    required this.quizId,
    required this.attemptId,
    required this.quizName,
  });

  @override
  State<TestResultDetailScreen> createState() => _TestResultDetailScreenState();
}

class _TestResultDetailScreenState extends State<TestResultDetailScreen> {
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
          _error = "Lỗi khi tải chi tiết bài làm";
          _isLoading = false;
        });
      }
    }
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

    final questions = _data?['questions'] as List? ?? [];
    final attempt = _data?['attempt'] ?? {};
    
    int totalQuestions = questions.length;
    int correctCount = 0;
    for (var q in questions) {
      if (q['state'] == 'gradedright' || q['state'] == 'correct') {
        correctCount++;
      }
    }

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
      body: Column(
        children: [
          _buildSubHeader(correctCount, totalQuestions, attempt['sumgrades'] ?? "0"),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: questions.length,
              itemBuilder: (context, index) {
                return _buildQuestionCard(questions[index]);
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomButtons(),
    );
  }

  Widget _buildSubHeader(int correct, int total, dynamic grade) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            "Trả lời đúng:",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w500),
          ),
          Row(
            children: [
              Text(
                "$correct/$total",
                style: const TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(width: 8),
              const Text("-", style: TextStyle(color: Colors.white70)),
              const SizedBox(width: 8),
              Text(
                "$grade",
                style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(width: 8),
              const Icon(Icons.bookmark, color: Colors.white70, size: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final bool isCorrect = q['state'] == 'gradedright' || q['state'] == 'correct';
    final int questionNumber = q['number'] ?? 0;
    
    List<dynamic> options = q['answertext'] as List? ?? [];
    String questionText = HtmlUtils.stripHtml(q['questiontext'] ?? "");
    final dynamic chosenId = q['chosenid'];
    final dynamic rightAnswerId = q['rightanswerid'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Câu $questionNumber:",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                ),
                const SizedBox(height: 8),
                Text(
                  questionText,
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black, height: 1.4),
                ),
                const SizedBox(height: 24),
                
                // Options List
                ...options.map((opt) => _buildOptionRow(opt, chosenId, rightAnswerId)),
              ],
            ),
          ),
          
          // Feedback Section (Conditional background color)
          _buildFeedbackBox(q, isCorrect),
        ],
      ),
    );
  }

  Widget _buildOptionRow(Map<String, dynamic> opt, dynamic chosenId, dynamic rightAnswerId) {
    // Robust comparison for selected answer
    final bool isSelected = opt['id']?.toString() == chosenId?.toString() && chosenId != null && chosenId != 0;
    
    // Robust comparison for correct answer
    final bool isCorrectChoice = opt['id']?.toString() == rightAnswerId?.toString() || 
                                 (opt['fraction']?.toString() == "1") || 
                                 (opt['fraction']?.toString() == "1.0");
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected 
                    ? (isCorrectChoice ? const Color(0xFF66BB6A) : const Color(0xFFEF5350))
                    : Colors.grey.shade400,
                width: 1.5,
              ),
              color: isSelected 
                  ? (isCorrectChoice ? const Color(0xFF66BB6A) : const Color(0xFFEF5350))
                  : Colors.transparent,
            ),
            child: isSelected ? const Center(child: Icon(Icons.circle, size: 10, color: Colors.white)) : null,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              HtmlUtils.stripHtml(opt['answer'] ?? ""),
              style: const TextStyle(fontSize: 15, color: Colors.black, fontWeight: FontWeight.w400),
            ),
          ),
          if (isSelected) 
            Padding(
              padding: const EdgeInsets.only(left: 8),
              child: Icon(
                isCorrectChoice ? Icons.check_circle : Icons.cancel,
                color: isCorrectChoice ? const Color(0xFF66BB6A) : const Color(0xFFEF5350),
                size: 28,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFeedbackBox(Map<String, dynamic> q, bool isCorrect) {
    // Light blue for correct, light red/pink for incorrect
    final Color bgColor = isCorrect ? const Color(0xFFE1F5FE) : const Color(0xFFFFEBEE);
    
    // Find correct answer text with fallbacks
    String rightAnswerText = HtmlUtils.stripHtml(q['rightanswer'] ?? "");
    
    // Clean up redundant prefixes in rightAnswerText if they exist
    rightAnswerText = rightAnswerText
        .replaceAll(RegExp(r'^(Đúng|Sai)\.\s*Đáp\s*án\s*đúng\s*là:\s*', caseSensitive: false), '')
        .trim();

    if (rightAnswerText.isEmpty) {
      final options = q['answertext'] as List? ?? [];
      try {
        final correctOpt = options.firstWhere(
          (opt) => opt['id']?.toString() == q['rightanswerid']?.toString() || 
                   opt['fraction']?.toString() == "1" || 
                   opt['fraction']?.toString() == "1.0",
          orElse: () => null,
        );
        if (correctOpt != null) {
          rightAnswerText = HtmlUtils.stripHtml(correctOpt['answer'] ?? "");
        }
      } catch (_) {}
    }

    // Feedback/Explanation cleaning
    String rawFeedback = HtmlUtils.stripHtml(q['feedback'] ?? "");
    if (rawFeedback.isEmpty) {
      rawFeedback = HtmlUtils.stripHtml(q['generalfeedback'] ?? "");
    }
    
    // Clean up redundant prefixes in feedback text if they exist (Moodle often bundles these)
    String feedbackText = rawFeedback
        .replaceAll(RegExp(r'^(Đúng|Sai)\.\s*Đáp\s*án\s*đúng\s*là:.*?(Vì:|Giải thích:)', caseSensitive: false), '')
        .replaceAll(RegExp(r'^(Vì:|Giải thích:)', caseSensitive: false), '')
        .trim();

    if (feedbackText.isEmpty && rawFeedback.isNotEmpty) {
      feedbackText = rawFeedback; // Fallback to raw if cleaning cleared everything
    }

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.5),
              children: [
                TextSpan(
                  text: isCorrect ? "Đúng. \nĐáp án đúng là: " : "Sai. \nĐáp án đúng là: ",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: rightAnswerText.isNotEmpty ? rightAnswerText : "--"),
              ],
            ),
          ),
          const SizedBox(height: 16),
          RichText(
            text: TextSpan(
              style: const TextStyle(fontSize: 15, color: Colors.black, height: 1.5),
              children: [
                const TextSpan(text: "Vì: ", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: feedbackText.isNotEmpty ? feedbackText : "Câu hỏi này hiện chưa có phần giải thích chi tiết."),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Reference section
          RichText(
            text: const TextSpan(
              style: TextStyle(fontSize: 15, color: Colors.black, height: 1.5),
              children: [
                TextSpan(text: "Tham khảo: ", style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: "Bài 1, mục 1.1.1. Một số khái niệm liên quan"),
              ],
            ),
          ),
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
            child: TextButton(
              onPressed: () {},
              child: const Text("Danh sách câu hỏi", style: TextStyle(color: Colors.white, fontSize: 16)),
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
