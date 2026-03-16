import 'package:flutter/material.dart';
import '../data_providers/result.dart';
import '../utils/logger.dart';
import 'dart:convert';
import 'package:flutter_svg/flutter_svg.dart';

class ResultDetailScreen extends StatefulWidget {
  final int courseId;
  final String courseName;

  const ResultDetailScreen({
    super.key,
    required this.courseId,
    required this.courseName,
  });

  @override
  State<ResultDetailScreen> createState() => _ResultDetailScreenState();
}

class _ResultDetailScreenState extends State<ResultDetailScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _detailData;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
  }

  Future<void> _fetchDetail() async {
    try {
      final data = await ResultAPI.detail(courseId: widget.courseId.toString());
      if (mounted) {
        setState(() {
          _detailData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger("Error fetching result detail: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(dynamic ts) {
    if (ts == null || ts == 0 || ts == "") return "---";
    int timestamp = 0;
    if (ts is int) {
      timestamp = ts;
    } else if (ts is String) {
      timestamp = int.tryParse(ts) ?? 0;
    }
    if (timestamp == 0) return "---";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF282A75),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                widget.courseName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Start/End Date Header
                Container(
                  color: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Ngày bắt đầu",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate((_detailData?['data_calendar']
                                  as List?)?[0]?['start_date']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          children: [
                            const Text(
                              "Ngày chốt ĐCC",
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _formatDate(
                                  _detailData?['date_attendance_grade']),
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Container(height: 8, color: Colors.grey[100]),
                // Weeks List
                Expanded(
                  child: ListView.builder(
                    itemCount:
                        (_detailData?['data_calendar'] as List?)?.length ?? 0,
                    itemBuilder: (context, index) {
                      final week = _detailData?['data_calendar'][index];
                      return InkWell(
                        onTap: () => _showWeekDetail(week),
                        child: _buildWeekItem(week),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }

  void _showWeekDetail(Map<String, dynamic> week) {
    final start = _formatDate(week['start_date']);
    final end = _formatDate(week['end_date']);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFB300),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: SvgPicture.asset(
                      'lib/assets/svg/mod_assign.svg',
                      // color: Colors.blue[900],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          week['week_name'] ?? "Tuần",
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          "$start - $end",
                          style:
                              TextStyle(color: Colors.grey[600], fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildDialogRow("Số bài gửi diễn đàn",
                        "${_detailData?['count_forum'] ?? 0}"),
                    _buildDialogRow("Số bài LTTN",
                        "${_detailData?['count_quiz_done'] ?? 0}"),
                    _buildDialogRow("Điểm Bài kiểm tra thường xuyên 1",
                        "${_detailData?['tx1'] ?? 0}"),
                    _buildDialogRow("Điểm Bài kiểm tra thường xuyên 2",
                        "${_detailData?['tx2'] ?? 0}"),
                    _buildDialogRow("Điểm chuyên cần",
                        "${_detailData?['diem_chuyen_can_original'] ?? 0}"),
                  ],
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDialogRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Colors.black),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekItem(Map<String, dynamic> week) {
    final start = _formatDate(week['start_date']);
    final end = _formatDate(week['end_date']);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[100]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  week['week_name'] ?? "Tuần",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "$start-$end",
                  style: TextStyle(color: Colors.grey[600], fontSize: 13),
                ),
              ],
            ),
          ),
          Column(
            children: [
              Text(
                "${week['forum'] ?? 0}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Bài diễn đàn",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 20),
          Column(
            children: [
              Text(
                "${week['practice'] ?? 0}",
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                "Bài LTTN",
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
          const SizedBox(width: 12),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
