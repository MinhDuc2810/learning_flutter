import 'package:flutter/material.dart';
import '../../../data/models/mission.dart';

class MissionItem extends StatelessWidget {
  final Mission mission;
  final VoidCallback? onTap;
  final bool showCourse;

  const MissionItem({
    super.key,
    required this.mission,
    this.onTap,
    this.showCourse = true,
  });

  @override
  Widget build(BuildContext context) {
    bool isCompleted = mission.state == 1;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon section
            _buildIcon(),
            const SizedBox(width: 16),
            // Content section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    mission.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (showCourse) ...[
                    _buildInfoRow('Học phần:', mission.courseName, Colors.black,
                        isBoldValue: true),
                    const SizedBox(height: 8),
                  ],
                  _buildInfoRow(
                    'Trạng thái:',
                    mission.stateName,
                    isCompleted ? Colors.green : Colors.orange,
                  ),
                  if (mission.formattedDeadline != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow('Deadline:', mission.formattedDeadline!,
                        const Color(0xFF282A75),
                        isBoldValue: true),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    IconData iconData;
    Color iconColor = const Color(0xFF282A75);

    switch (mission.type) {
      case 'quiz':
        iconData = Icons.edit_note_rounded;
        break;
      case 'assign':
        iconData = Icons.file_present_rounded;
        break;
      default:
        iconData = Icons.assignment_outlined;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 32,
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color valueColor,
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
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.right,
            style: TextStyle(
              color: valueColor,
              fontSize: 14,
              fontWeight: isBoldValue ? FontWeight.bold : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
