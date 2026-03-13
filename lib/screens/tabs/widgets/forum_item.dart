import 'package:flutter/material.dart';
import '../../../data/models/forum_discussion.dart';
import '../../../utils/html_utils.dart';
import '../../../theme/ons_color.dart';

class ForumItem extends StatelessWidget {
  final ForumDiscussion discussion;
  final VoidCallback? onTap;
  final VoidCallback? onSubscribeToggle;

  const ForumItem({
    super.key,
    required this.discussion,
    this.onTap,
    this.onSubscribeToggle,
  });

  String _formatDate(dynamic value) {
    if (value == null || value == "" || value == 0) return "";
    if (value is String) return value; // API trả về chuỗi đã format sẵn

    // Nếu là số, format từ timestamp
    try {
      final timestamp = int.tryParse(value.toString()) ?? 0;
      if (timestamp == 0) return "";
      final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
      return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}";
    } catch (e) {
      return value.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              HtmlUtils.stripHtml(discussion.name),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _formatDate(discussion.createdtime),
              style: TextStyle(color: Colors.grey[600], fontSize: 13),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                CircleAvatar(
                  radius: 12,
                  backgroundColor: Colors.grey[200],
                  child: const Icon(Icons.person, size: 16),
                ),
                const SizedBox(width: 8),
                Text(
                  discussion.usercreated,
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              HtmlUtils.stripHtml(discussion.intro),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            if (discussion.userlastpost.isNotEmpty) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey[50],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.reply, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        "Phản hồi cuối: ${discussion.userlastpost} • ${_formatDate(discussion.lastposttime)}",
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    _buildStatusBadge("${discussion.totalpost} câu trả lời"),
                    const SizedBox(width: 8),
                    if (discussion.totalpost > 0)
                      _buildStatusBadge("Đã trả lời"),
                  ],
                ),
                ElevatedButton(
                  onPressed: onSubscribeToggle,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: HexColor(StringColor.primary1),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  child:
                      Text(discussion.subscribed ? "Huỷ theo dõi" : "Theo dõi"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F6F9),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: Colors.grey[800],
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
