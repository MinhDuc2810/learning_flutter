import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../data/models/course.dart';
import '../../../theme/ons_color.dart';
import '../../../utils/html_utils.dart';

class CourseItem extends StatelessWidget {
  final Course course;
  final VoidCallback? onTap;

  const CourseItem({
    super.key,
    required this.course,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 20),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Course Image (SVG Base64)
            ClipRRect(
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              child: AspectRatio(
                aspectRatio: 16 / 7,
                child: _buildCourseImage(),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Logo
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          HtmlUtils.stripHtml(course.fullname),
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Image.asset(
                        'lib/assets/image/sci_nbg.png',
                        width: 20,
                        height: 20,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  // Instructor
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: const Color(0xFFE0E0E0),
                        backgroundImage: (course.teachers.isNotEmpty &&
                                course.teachers.first.avatar != null &&
                                course.teachers.first.avatar!.isNotEmpty)
                            ? NetworkImage(course.teachers.first.avatar!)
                            : null,
                        child: (course.teachers.isEmpty ||
                                course.teachers.first.avatar == null ||
                                course.teachers.first.avatar!.isEmpty)
                            ? const Icon(Icons.person,
                                size: 16, color: Colors.white)
                            : null,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Giảng viên: ${HtmlUtils.stripHtml(course.instructorName)}',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Dates
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Thời gian học',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              course.formattedStartDate,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Ngày thi dự kiến:',
                              style:
                                  TextStyle(color: Colors.grey, fontSize: 12),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              (course.ngayThi != null &&
                                      course.ngayThi!.isNotEmpty)
                                  ? course.ngayThi!
                                  : "Chưa có",
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Progress
                  Text(
                    'Hoàn thành ${course.progress.toInt()}%',
                    style: const TextStyle(
                      color: Colors.grey,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: course.progress / 100,
                      backgroundColor: Colors.grey[200],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        HexColor(StringColor.primary1),
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseImage() {
    final imageUrl = course.courseimage;
    if (imageUrl == null || imageUrl.isEmpty) {
      return _buildPlaceholder();
    }

    // Case 1: Handle Data URLs (data:image/...)
    if (imageUrl.startsWith('data:image/')) {
      try {
        final commaIndex = imageUrl.indexOf(',');
        if (commaIndex == -1) return _buildPlaceholder();

        final header = imageUrl.substring(0, commaIndex);
        final base64Data =
            imageUrl.substring(commaIndex + 1).replaceAll(RegExp(r'\s+'), '');
        final bytes = base64Decode(base64Data);

        if (header.contains('svg')) {
          return SvgPicture.memory(
            bytes,
            fit: BoxFit.cover,
            placeholderBuilder: (context) =>
                const Center(child: CircularProgressIndicator()),
            errorBuilder: (context, error, stackTrace) {
              debugPrint('Error loading SVG base64: $error');
              return _buildPlaceholder();
            },
          );
        } else {
          return Image.memory(
            bytes,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
          );
        }
      } catch (e) {
        debugPrint('Error decoding base64 image: $e');
        return _buildPlaceholder();
      }
    }

    // Case 2: Handle regular URLs
    if (imageUrl.startsWith('http')) {
      if (imageUrl.toLowerCase().contains('.svg')) {
        return SvgPicture.network(
          imageUrl,
          fit: BoxFit.cover,
          placeholderBuilder: (context) =>
              const Center(child: CircularProgressIndicator()),
          errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
        );
      }
      return Image.network(
        imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => _buildPlaceholder(),
      );
    }

    return _buildPlaceholder();
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: Center(
        child: Opacity(
          opacity: 0.3,
          child: Image.asset(
            'lib/assets/image/homeTabBackground.jpg',
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
          ),
        ),
      ),
    );
  }
}
