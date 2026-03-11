import 'package:flutter/material.dart';
import '../../../data/models/academic_result.dart';

class ResultItem extends StatefulWidget {
  final AcademicResult result;

  const ResultItem({super.key, required this.result});

  @override
  State<ResultItem> createState() => _ResultItemState();
}

class _ResultItemState extends State<ResultItem> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        InkWell(
          onTap: () => setState(() => _isExpanded = !_isExpanded),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Text(
                    widget.result.courseName,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: Colors.black87,
                    ),
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        widget.result.status,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        _isExpanded
                            ? Icons.keyboard_arrow_down
                            : Icons.arrow_right,
                        color: Colors.black54,
                        size: 20,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
        if (_isExpanded)
          Container(
            padding: const EdgeInsets.fromLTRB(32, 0, 16, 20),
            child: Column(
              children: [
                _buildDetailRow('Ngày bắt đầu', widget.result.startDate ?? ''),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Ngày chốt điểm chuyên cần', widget.result.examDate ?? ''),
                const SizedBox(height: 12),
                _buildDetailRow(
                    'Điểm chuyên cần', widget.result.attendanceGrade,
                    isBoldValue: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    InkWell(
                      onTap: () {
                        // Navigate to detail
                      },
                      child: const Text(
                        'Xem chi tiết',
                        style: TextStyle(
                          color: Color(0xFF26A8E0),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Icon(
                      Icons.keyboard_arrow_right,
                      color: Color(0xFF26A8E0),
                      size: 20,
                    ),
                  ],
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value,
      {bool isBoldValue = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: isBoldValue ? FontWeight.bold : FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }
}
