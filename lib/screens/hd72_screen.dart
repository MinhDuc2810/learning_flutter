import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:base_flutter/data_providers/hd72.dart';
import 'package:base_flutter/theme/ons_color.dart';
import 'package:base_flutter/utils/html_utils.dart';
import 'package:base_flutter/utils/logger.dart';
import 'package:base_flutter/utils/ons_clients.dart';
import 'dart:convert';

class Hd72Screen extends StatefulWidget {
  final String courseId;
  final String courseName;

  const Hd72Screen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<Hd72Screen> createState() => _Hd72ScreenState();
}

class _Hd72ScreenState extends State<Hd72Screen> {
  bool _isLoading = true;
  bool _isMineOnly = true;
  int _userId = 0;

  Map<String, dynamic> _summary = {
    'answered': 0,
    'waiting': 0,
    'closed': 0,
  };

  List<dynamic> _threads = [];

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    setState(() => _isLoading = true);
    try {
      // Get user info first
      final siteInfoResponse = await OnsClient.post(
          '${baseUrl}/webservice/rest/server.php?wsfunction=core_webservice_get_site_info&moodlewsrestformat=json');
      if (siteInfoResponse is http.Response) {
        final siteInfo = jsonDecode(siteInfoResponse.body);
        _userId = siteInfo['userid'] ?? 0;
      }

      await _fetchData();
    } catch (e) {
      logger("Hd72Screen:initData error: $e");
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _fetchData() async {
    try {
      // Fetch summary
      final summaryRes = await Hd72API.countStatus(courseId: widget.courseId);
      if (summaryRes is Map && summaryRes['data_count'] != null) {
        final dataCount = summaryRes['data_count'];
        _summary['answered'] = dataCount['answered'] ?? 0;
        _summary['waiting'] = dataCount['waiting'] ?? 0;
        _summary['closed'] = dataCount['closed'] ?? 0;
      }

      // Fetch threads
      final threadsRes = await Hd72API.list(
        courseId: widget.courseId,
        createdBy: _isMineOnly ? _userId.toString() : "",
      );

      if (threadsRes is Map &&
          threadsRes['data'] != null &&
          threadsRes['data']['data_tblthread'] != null) {
        _threads = threadsRes['data']['data_tblthread'];
      } else if (threadsRes is Map && threadsRes['threads'] != null) {
        _threads = threadsRes['threads'];
      } else if (threadsRes is List) {
        _threads = threadsRes;
      }
    } catch (e) {
      logger("Hd72Screen:fetchData error: $e");
    }
  }

  void _onToggleTab(bool mineOnly) {
    if (_isMineOnly == mineOnly) return;
    setState(() {
      _isMineOnly = mineOnly;
      _isLoading = true;
    });
    _fetchData().then((_) {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : RefreshIndicator(
                    onRefresh: _fetchData,
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _buildSummaryRow(),
                          const SizedBox(height: 20),
                          if (_threads.isEmpty)
                            const Padding(
                              padding: EdgeInsets.only(top: 50),
                              child: Text("Không có câu hỏi nào"),
                            )
                          else
                            ListView.separated(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: _threads.length,
                              separatorBuilder: (_, __) =>
                                  const SizedBox(height: 12),
                              itemBuilder: (context, index) {
                                return Hd72QuestionItem(
                                  thread: _threads[index],
                                  courseName: widget.courseName,
                                );
                              },
                            ),
                          const SizedBox(
                              height: 80), // Space for FAB-like button
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomSheet: _buildBottomButton(),
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 50, bottom: 20, left: 16, right: 16),
      decoration: BoxDecoration(
        color: HexColor(StringColor.primary1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.only(left: 12),
            child: Text(
              widget.courseName,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 25),
          Row(
            children: [
              _buildTabButton("Câu hỏi của tôi", _isMineOnly),
              const SizedBox(width: 12),
              _buildTabButton("Tất cả câu hỏi", !_isMineOnly),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, bool active) {
    return GestureDetector(
      onTap: () => _onToggleTab(text == "Câu hỏi của tôi"),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color:
              active ? const Color(0xFF1E2055) : Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryCard(
              "Đã trả lời",
              _summary['answered'].toString(),
              const Color(0xFF4CAF50),
              Icons.assignment_turned_in_outlined),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard(
              "Chờ trả lời",
              _summary['waiting'].toString(),
              const Color(0xFF2196F3),
              Icons.access_time),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildSummaryCard("Đã đóng", _summary['closed'].toString(),
              const Color(0xFFF44336), Icons.assignment_late_outlined),
        ),
      ],
    );
  }

  Widget _buildSummaryCard(
      String label, String count, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 36),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(fontSize: 13, color: Colors.black54),
          ),
          const SizedBox(height: 4),
          Text(
            "$count câu",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: color),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButton() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFEEEEEE))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton(
          onPressed: () {
            // Handle Add Question
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: HexColor(StringColor.primary1),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
          child: const Text(
            "Đặt câu hỏi",
            style: TextStyle(
                color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}

class Hd72QuestionItem extends StatelessWidget {
  final dynamic thread;
  final String courseName;

  const Hd72QuestionItem({
    super.key,
    required this.thread,
    required this.courseName,
  });

  String _formatDateTime(dynamic timestamp) {
    if (timestamp == null || timestamp == 0) return "";
    try {
      int ts = 0;
      if (timestamp is String) {
        ts = int.tryParse(timestamp) ?? 0;
      } else if (timestamp is int) {
        ts = timestamp;
      }
      if (ts == 0) return "";

      final date = DateTime.fromMillisecondsSinceEpoch(ts * 1000);
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      final day = date.day.toString().padLeft(2, '0');
      final month = date.month.toString().padLeft(2, '0');
      final year = date.year;
      return "$hour:$minute - $day/$month/$year";
    } catch (e) {
      return "";
    }
  }

  @override
  Widget build(BuildContext context) {
    final String subject =
        thread['answername'] ?? thread['subject'] ?? "No Subject";
    final String timeStr = _formatDateTime(thread['time']);

    // User info
    final userInfo = thread['info_user'] ?? {};
    final String firstName = userInfo['firstname'] ?? "";
    final String lastName = userInfo['lastname'] ?? "";
    String creatorName = "$lastName $firstName".trim();
    if (creatorName.isEmpty) creatorName = "Anonymous";
    final String userAvatar = userInfo['avatar'];

    final String threadId = thread['id']?.toString() ?? "0";
    final String status = thread['status'] ?? "waiting";

    // Last reply / Info user reply
    final replyInfo = thread['info_user_reply'];

    // Status color/text
    Color statusColor = const Color(0xFF2196F3);
    String statusText = "Chờ trả lời";
    if (status == 'answered' || status == 'waiting' && replyInfo != null) {
      statusColor = const Color(0xFF4CAF50);
      statusText = "Đã trả lời";
    } else if (status == 'closed') {
      statusColor = const Color(0xFFF44336);
      statusText = "Đã đóng";
    } else if (status == 'open') {
      statusColor = const Color(0xFF2196F3);
      statusText = "Chủ đề mở";
    }

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            subject,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            timeStr,
            style: const TextStyle(color: Colors.grey, fontSize: 13),
          ),
          const SizedBox(height: 12),
          if (thread['message'] != null &&
              thread['message'].toString().isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Text(
                HtmlUtils.stripHtml(thread['message']),
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.black.withOpacity(0.7),
                  height: 1.5,
                ),
              ),
            ),
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: Colors.grey[200],
                backgroundImage: userAvatar != null && userAvatar.isNotEmpty
                    ? NetworkImage(userAvatar)
                    : null,
                child: (userAvatar == null || userAvatar.isEmpty)
                    ? const Icon(Icons.person, size: 16)
                    : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  creatorName,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "ID chủ đề #$threadId",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              "Học phần: ${thread['coursename'] ?? courseName}",
              style: const TextStyle(fontSize: 13, color: Colors.black54),
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBadge(statusText, statusColor),
          if (replyInfo != null) ...[
            const SizedBox(height: 12),
            _buildLastReply(
              replyInfo,
              thread['last_reply_time'] ?? thread['time'],
              thread['last_reply_message'], // Pass message if available
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLastReply(dynamic reply, dynamic replyTimeRaw,
      [dynamic replyMessage]) {
    final String firstName = reply['firstname'] ?? "";
    final String lastName = reply['lastname'] ?? "";
    final String replierName = "$lastName $firstName".trim();
    final String userAvatar = reply['avatar'];
    final String replyTime = _formatDateTime(replyTimeRaw);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            CircleAvatar(
              radius: 12,
              backgroundColor: Colors.grey[200],
              backgroundImage: userAvatar != null && userAvatar.isNotEmpty
                  ? NetworkImage(userAvatar)
                  : null,
              child: (userAvatar == null || userAvatar.isEmpty)
                  ? const Icon(Icons.person, size: 14)
                  : null,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: RichText(
                text: TextSpan(
                  style: const TextStyle(color: Colors.black87, fontSize: 13),
                  children: [
                    TextSpan(
                        text: replierName,
                        style: const TextStyle(fontWeight: FontWeight.bold)),
                    const TextSpan(text: " đã trả lời lúc "),
                    TextSpan(
                        text: replyTime,
                        style: const TextStyle(color: Color(0xFF282A75))),
                  ],
                ),
              ),
            ),
          ],
        ),
        if (replyMessage != null && replyMessage.toString().isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 32),
            child: Text(
              HtmlUtils.stripHtml(replyMessage.toString()),
              style: TextStyle(
                fontSize: 13,
                color: Colors.black.withOpacity(0.6),
                fontStyle: FontStyle.italic,
                height: 1.4,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildStatusBadge(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        text,
        style:
            TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}
