import 'package:flutter/material.dart';
import '../../theme/ons_color.dart';
import '../../data/models/course.dart';
import '../../data_providers/course.dart';
import './widgets/course_item.dart';

class CourseTab extends StatefulWidget {
  final String username;
  const CourseTab({super.key, required this.username});

  @override
  State<CourseTab> createState() => _CourseTabState();
}

class _CourseTabState extends State<CourseTab> {
  int _selectedFilter = 0; // 0: Tất cả, 1: Đang học, 2: Đã hoàn thành
  final List<String> _filters = ['Tất cả', 'Đang học', 'Đã hoàn thành'];

  List<Course>? _allCourses;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  Future<void> _fetchCourses() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final response = await CourseAPI.getCourseList();
      if (response['courses'] != null) {
        final List<dynamic> courseList = response['courses'];
        if (mounted) {
          setState(() {
            _allCourses = courseList.map((c) => Course.fromJson(c)).toList();
            _error = null;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _error = "Không tìm thấy dữ liệu khóa học";
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Lỗi khi tải danh sách khóa học";
          _isLoading = false;
        });
      }
    }
  }

  List<Course> get _filteredCourses {
    if (_allCourses == null) return [];

    List<Course> courses = _allCourses!;
    if (_selectedFilter == 1) {
      courses = courses.where((c) => c.progress < 100).toList();
    } else if (_selectedFilter == 2) {
      courses = courses.where((c) => c.progress == 100).toList();
    }
    return courses;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Khóa học của tôi',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.black54, size: 28),
            onPressed: () {},
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _fetchCourses,
        color: HexColor(StringColor.primary1),
        child: Column(
          children: [
            // Filters
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: List.generate(_filters.length, (index) {
                    bool isSelected = _selectedFilter == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 12),
                      child: InkWell(
                        onTap: () => setState(() => _selectedFilter = index),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? HexColor(StringColor.primary1)
                                : Colors.grey[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            _filters[index],
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black87,
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
            ),
            // Course List
            Expanded(
              child: _buildBody(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.redAccent),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchCourses,
              style: ElevatedButton.styleFrom(
                backgroundColor: HexColor(StringColor.primary1),
                foregroundColor: Colors.white,
              ),
              child: const Text("Thử lại"),
            ),
          ],
        ),
      );
    }

    final courses = _filteredCourses;
    if (courses.isEmpty) {
      return ListView(
        // Wrap in ListView to enable RefreshIndicator even when empty
        physics: const AlwaysScrollableScrollPhysics(),
        children: [
          SizedBox(height: MediaQuery.of(context).size.height * 0.3),
          const Center(child: Text("Không có khóa học nào")),
        ],
      );
    }

    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: courses.length,
      itemBuilder: (context, index) {
        return CourseItem(
          course: courses[index],
          onTap: () {
            Navigator.pushNamed(
              context,
              '/course_detail',
              arguments: {'courseId': courses[index].id},
            );
          },
        );
      },
    );
  }
}
