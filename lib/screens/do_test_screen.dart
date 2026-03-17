import 'dart:async';
import 'package:flutter/material.dart';
import '../data_providers/quiz.dart';
import '../data_providers/quiz_server.dart';
import '../data_providers/course.dart';
import '../data_providers/trigger.dart';
import '../utils/html_utils.dart';
import '../utils/logger.dart';

class DoTestScreen extends StatefulWidget {
  final int quizId;
  final int? attemptId;
  final String quizName;
  final int? courseId;

  const DoTestScreen({
    super.key,
    required this.quizId,
    this.attemptId,
    required this.quizName,
    this.courseId,
  });

  @override
  State<DoTestScreen> createState() => _DoTestScreenState();
}

class _DoTestScreenState extends State<DoTestScreen> {
  bool _isLoading = true;
  bool _isSaving = false;
  Map<String, dynamic>? _data;
  String? _error;
  Timer? _timer;
  int _remainingSeconds = 0;
  int? _currentAttemptId;
  int? _courseId;
  
  // Track if there's an ongoing save operation
  Future<void>? _pendingSave;

  @override
  void initState() {
    super.initState();
    _currentAttemptId = widget.attemptId;
    _courseId = widget.courseId;
    _initializeQuiz();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _initializeQuiz() async {
    try {
      await TriggerAPI.viewQuiz(quizId: widget.quizId);

      if (_courseId != null) {
        await CourseAPI.getLanguage(courseId: _courseId.toString());
      }

      if (_currentAttemptId == null) {
        final history = await QuizAPI.historyQuiz(quizId: widget.quizId);
        final attempts = history['attempts'] as List? ?? [];
        
        final activeAttempt = attempts.firstWhere(
          (a) => a['state'] == 'inprogress' || a['state'] == 'overdue',
          orElse: () => null,
        );

        if (activeAttempt != null) {
          _currentAttemptId = activeAttempt['id'];
        } else {
          final newAttempt = await QuizAPI.startQuiz(
            quizId: widget.quizId,
          );
          _currentAttemptId = newAttempt['attempt']?['id'];
        }
      }

      if (_currentAttemptId == null) throw Exception("Could not get attempt ID");

      final response = await QuizAPI.quizContent(
        attemptId: _currentAttemptId!,
      );
      
      final questions = response['questions'] as List? ?? [];

      try {
        final serverData = await QuizServerAPI.getAttempt(attemptid: _currentAttemptId!.toString());
        if (serverData != null) {
          final serverMap = serverData as Map<String, dynamic>;
          
          for (var q in questions) {
            final slot = q['slot'].toString();
            
            if (serverMap.containsKey(slot)) {
              final slotData = serverMap[slot] as Map<String, dynamic>? ?? {};
              
              // Lấy answer
              final answers = slotData['answers'] as Map<String, dynamic>? ?? {};
              if (answers.containsKey('-1')) {
                dynamic val = answers['-1'];
                int savedIndex = -1;
                if (val is String) {
                  savedIndex = int.tryParse(val) ?? -1;
                } else if (val is int) {
                  savedIndex = val;
                }
                
                if (savedIndex != -1) {
                  final options = q['answertext'] as List? ?? [];
                  if (savedIndex >= 0 && savedIndex < options.length) {
                    q['chosenid'] = options[savedIndex]['id'];
                    q['chosenIndex'] = savedIndex;
                  }
                }
              }
              
              // Lấy flag
              final flagged = slotData['flagged'];
              if (flagged == true || flagged == 1 || flagged == "true") {
                q['flagged'] = 1;
              }
            }
          }
        }
      } catch (e) {
        logger("DEBUG: Error restoring from server: $e");
      }

      if (_courseId == null && response['attempt']?['quiz'] != null) {
        _courseId = int.tryParse(response['attempt']['quiz']['course'].toString());
      }
      
      if (_courseId != null) {
        await CourseAPI.detailCourse(courseId: _courseId.toString());
      }

      if (mounted) {
        setState(() {
          _data = response;
          _isLoading = false;
          _remainingSeconds = response['attempt']?['remaining'] ?? 0;
          if (_remainingSeconds > 0) {
            _startTimer();
          }
        });
      }
    } catch (e) {
      logger("DEBUG: Error in _initializeQuiz: $e");
      if (mounted) {
        setState(() {
          _error = "Lỗi khi chuẩn bị bài tập: $e";
          _isLoading = false;
        });
      }
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingSeconds > 0) {
        setState(() {
          _remainingSeconds--;
        });
        
        if (_remainingSeconds == 30) {
           _checkStatus();
        }
      } else {
        timer.cancel();
        _submitQuiz(isAuto: true);
      }
    });
  }

  Future<void> _checkStatus() async {
    if (_currentAttemptId == null) return;
    try {
      final response = await QuizAPI.quizContent(attemptId: _currentAttemptId!);
      if (response['attempt']?['state'] == 'overdue') {
        _submitQuiz(isAuto: true);
      }
    } catch (e) {
      logger("DEBUG: Error checking status: $e");
    }
  }

  Future<void> _handleExit() async {
    // Wait for any pending save to finish before popping
    if (_isSaving && _pendingSave != null) {
      setState(() => _isLoading = true); // Brief loading state
      await _pendingSave;
    }
    if (mounted) {
      Navigator.pop(context);
    }
  }

  Future<void> _submitQuiz({bool isAuto = false}) async {
    if (_currentAttemptId == null || _data == null) return;

    if (isAuto) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Hết thời gian! Đang tự động nộp bài...")),
      );
    } else {
      bool? confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Xác nhận nộp bài"),
          content: const Text("Bạn có chắc chắn muốn nộp bài?"),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text("Hủy")),
            TextButton(
              onPressed: () => Navigator.pop(context, true), 
              child: const Text("Nộp bài", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );
      if (confirm != true) return;
    }

    if (_isSaving && _pendingSave != null) await _pendingSave;

    setState(() => _isLoading = true);

    try {
      await QuizServerAPI.submitAttempt(attemptid: _currentAttemptId!.toString());

      final questions = _data!['questions'] as List? ?? [];
      List<Map<String, String>> dataAns = [];
      
      for (var q in questions) {
        final slot = q['slot'];
        final uniqueid = q['id'];
        final chosenIndexStr = q['chosenIndex']?.toString();
        final valueToSend = chosenIndexStr ?? (q['chosenid']?.toString() ?? "");
        
        dataAns.add({
          "name": "q$uniqueid:${slot}_answer",
          "value": valueToSend
        });
        dataAns.add({
          "name": "q$uniqueid:${slot}_:sequencecheck",
          "value": "1"
        });
      }

      await QuizAPI.submitQuiz(
        attemptId: _currentAttemptId!,
        data: dataAns,
      );

      List<Map<String, String>> flagData = [];
      for (var q in questions) {
        if (q['flagged'] == 1 || q['flagged'] == true) {
           flagData.add({
             "slot": q['slot'].toString(),
             "flagged": "1"
           });
        }
      }
      if (flagData.isNotEmpty) {
        await QuizAPI.submitFlag(flagData: flagData);
      }

      if (mounted) {
        Navigator.pop(context, true);
      }
    } catch (e) {
      logger("DEBUG: Error submitting quiz: $e");
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Lỗi khi nộp bài: $e";
        });
      }
    }
  }

  void _handleOptionTap(int slot, dynamic optionId, int optionIndex) {
    if (_data == null) return;

    final questions = _data!['questions'] as List? ?? [];
    final qIndex = questions.indexWhere((q) => q['slot'] == slot);
    
    if (qIndex != -1) {
      setState(() {
        questions[qIndex]['chosenid'] = optionId;
        questions[qIndex]['chosenIndex'] = optionIndex;
      });

      // Save immediately and track the future
      _pendingSave = _performSave(slot, optionIndex);
    }
  }

  Future<void> _performSave(int slot, dynamic value) async {
    if (_currentAttemptId == null) return;
    setState(() => _isSaving = true);
    try {
      await QuizServerAPI.saveAttempt(
        attemptid: _currentAttemptId!.toString(),
        slot: slot.toString(),
        value: value.toString(),
      );
      logger("DEBUG: Saved slot $slot with value $value");
    } catch (e) {
      logger("DEBUG: Error auto-saving answer: $e");
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _toggleFlag(int slot) async {
    if (_data == null || _currentAttemptId == null) return;
    
    final questions = _data!['questions'] as List? ?? [];
    final qIndex = questions.indexWhere((q) => q['slot'] == slot);
    
    if (qIndex != -1) {
      final bool currentFlag = questions[qIndex]['flagged'] == 1 || questions[qIndex]['flagged'] == true;
      setState(() {
        questions[qIndex]['flagged'] = currentFlag ? 0 : 1;
      });
      
      try {
        await QuizServerAPI.flagQuestion(
          attemptid: _currentAttemptId!.toString(),
          slot: slot.toString(),
        );
      } catch (e) {
        logger("DEBUG: Error flagging question: $e");
      }
    }
  }

  void _showQuestionList() {
    if (_data == null) return;
    final questions = _data!['questions'] as List? ?? [];

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF1E1E1E),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                "Danh sách câu hỏi",
                style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Flexible(
                child: GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 5,
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                  ),
                  itemCount: questions.length,
                  itemBuilder: (context, index) {
                    final q = questions[index];
                    final bool isAnswered = q['chosenid'] != null && q['chosenid'] != 0 && q['chosenid'] != "" && q['chosenid'] != "0";
                    final bool isFlagged = q['flagged'] == 1 || q['flagged'] == true;

                    return Container(
                      decoration: BoxDecoration(
                        color: isAnswered ? const Color(0xFF66BB6A) : Colors.white12,
                        borderRadius: BorderRadius.circular(8),
                        border: isFlagged ? Border.all(color: const Color(0xFFFFD600), width: 2) : null,
                      ),
                      child: Center(
                        child: Text(
                          "${q['number'] ?? (index + 1)}",
                          style: TextStyle(
                            color: isAnswered ? Colors.white : Colors.white70,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  String _formatTime(int totalSeconds) {
    if (totalSeconds <= 0) return "00:00:00";
    final hours = totalSeconds ~/ 3600;
    final minutes = (totalSeconds % 3600) ~/ 60;
    final seconds = totalSeconds % 60;
    return "${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}";
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
            onPressed: _handleExit,
          ),
        ),
        body: Center(child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, style: const TextStyle(color: Colors.white), textAlign: TextAlign.center),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isLoading = true;
                  });
                  _initializeQuiz();
                },
                child: const Text("Thử lại"),
              )
            ],
          ),
        )),
      );
    }

    final questions = _data?['questions'] as List? ?? [];
    int answeredCount = 0;
    int flaggedCount = 0;
    for (var q in questions) {
      final chosenId = q['chosenid'];
      if (chosenId != null && chosenId != 0 && chosenId != "" && chosenId != "0") {
        answeredCount++;
      }
      if (q['flagged'] == 1 || q['flagged'] == true) {
        flaggedCount++;
      }
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (didPop) return;
        _handleExit();
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF1A1A1A),
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.menu, color: Colors.white),
            onPressed: _showQuestionList,
          ),
          title: Text(
            widget.quizName,
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
          actions: [
            if (_isSaving)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white70)),
                ),
              ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.white),
              onPressed: _handleExit,
            ),
          ],
        ),
        body: Column(
          children: [
            _buildInfoBar(answeredCount, flaggedCount, questions.length),
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
        bottomNavigationBar: _buildBottomBar(),
      ),
    );
  }

  Widget _buildInfoBar(int answered, int flagged, int total) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Thời gian còn lại:",
            style: TextStyle(color: Colors.white70, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            _formatTime(_remainingSeconds),
            style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiến độ:",
                style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 15),
              ),
              Row(
                children: [
                  Text(
                    "$answered/$total",
                    style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(width: 8),
                  const Icon(Icons.bookmark, color: Color(0xFFFFD600), size: 20),
                  const SizedBox(width: 4),
                  Text("$flagged", style: const TextStyle(color: Colors.white70, fontSize: 15)),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionCard(Map<String, dynamic> q) {
    final int questionNumber = q['number'] ?? 0;
    final String questionText = HtmlUtils.stripHtml(q['questiontext'] ?? "");
    final List<dynamic> options = q['answertext'] as List? ?? [];
    final int slot = q['slot'] ?? 0;
    final bool isFlagged = q['flagged'] == 1 || q['flagged'] == true;
    final dynamic currentSelection = q['chosenid'];

    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
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
          
          ...options.asMap().entries.map((entry) => _buildOptionRow(entry.value, slot, currentSelection, entry.key)),
          
          const SizedBox(height: 20),
          
          InkWell(
            onTap: () => _toggleFlag(slot),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  isFlagged ? Icons.bookmark : Icons.bookmark_border,
                  color: isFlagged ? const Color(0xFFFFD600) : Colors.grey,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  "Gắn cờ",
                  style: TextStyle(
                    color: Colors.black.withOpacity(0.6),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionRow(Map<String, dynamic> opt, int slot, dynamic currentSelection, int optionIndex) {
    final String optionId = opt['id']?.toString() ?? "";
    final String selectedId = currentSelection?.toString() ?? "";
    final bool isSelected = optionId.isNotEmpty && optionId == selectedId;
    
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: InkWell(
        onTap: () => _handleOptionTap(slot, opt['id'], optionIndex),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? const Color(0xFF66BB6A) : Colors.grey.shade400,
                  width: 1.5,
                ),
                color: isSelected ? const Color(0xFF66BB6A) : Colors.transparent,
              ),
              child: isSelected ? const Center(child: Icon(Icons.circle, size: 10, color: Colors.white)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                HtmlUtils.stripHtml(opt['answer'] ?? ""),
                style: TextStyle(
                  fontSize: 15, 
                  color: Colors.black, 
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w400
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
      decoration: const BoxDecoration(
        color: Color(0xFF1A1A1A),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextButton(
              onPressed: _showQuestionList,
              child: const Text("Danh sách câu hỏi", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _submitQuiz(),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF03A9F4),
                minimumSize: const Size(0, 52),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text("Nộp bài", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
