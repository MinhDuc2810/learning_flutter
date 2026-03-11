import 'package:flutter/material.dart';
import '../data/models/course_detail.dart';
import '../data_providers/course.dart';
import '../data_providers/mission.dart';
import '../data/models/mission.dart';
import './tabs/widgets/mission_item.dart';
import '../theme/ons_color.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;

  const CourseDetailScreen({super.key, required this.courseId});

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen> {
  CourseDetail? _detail;
  List<Mission> _courseMissions = [];
  bool _isLoading = true;
  bool _isLoadingMissions = true;
  String? _error;
  bool _isDescriptionExpanded = false;

  @override
  void initState() {
    super.initState();
    _fetchDetail();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    try {
      final response =
          await MissionAPI.listCompletion(courseId: widget.courseId);
      List<dynamic> statusList = [];
      if (response is Map && response['statuses'] != null) {
        statusList = response['statuses'];
      } else if (response is List) {
        statusList = response;
      }
      if (mounted) {
        setState(() {
          _courseMissions = statusList.map((m) => Mission.fromJson(m)).toList();
          _isLoadingMissions = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingMissions = false);
      }
    }
  }

  Future<void> _fetchDetail() async {
    try {
      final response = await CourseAPI.detailCourse(courseId: widget.courseId);
      if (mounted) {
        setState(() {
          _detail = CourseDetail.fromJson(response);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = "Lỗi khi tải thông tin khóa học";
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_error != null || _detail == null) {
      return Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(_error ?? "Không có dữ liệu")),
      );
    }

    final course = _detail!.course;

    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: Colors.white,
        body: NestedScrollView(
          headerSliverBuilder: (context, innerBoxIsScrolled) {
            return [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: const Color(0xFF282A75),
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
                title: innerBoxIsScrolled
                    ? Text(course.fullname,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 18))
                    : null,
                flexibleSpace: FlexibleSpaceBar(
                  background: Stack(
                    fit: StackFit.expand,
                    children: [
                      _buildHeaderImage(course.courseimage),
                      Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [
                              Colors.black.withOpacity(0.3),
                              Colors.transparent,
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Title and Logo
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              course.fullname,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Image.asset(
                            'lib/assets/image/sci_nbg.png',
                            width: 24,
                            height: 24,
                            errorBuilder: (_, __, ___) => const SizedBox(),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Instructor
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: (_detail!.teachers.isNotEmpty &&
                                    _detail!.teachers.first.avatar != null)
                                ? NetworkImage(_detail!.teachers.first.avatar!)
                                : null,
                            child: (_detail!.teachers.isEmpty ||
                                    _detail!.teachers.first.avatar == null)
                                ? const Icon(Icons.person, size: 16)
                                : null,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Giảng viên: ${course.instructorName}',
                            style: TextStyle(
                                color: Colors.grey[700], fontSize: 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverPersistentHeader(
                pinned: true,
                delegate: _SliverAppBarDelegate(
                  TabBar(
                    labelColor: HexColor(StringColor.primary1),
                    unselectedLabelColor: Colors.grey,
                    indicatorColor: HexColor(StringColor.primary1),
                    indicatorWeight: 3,
                    tabs: const [
                      Tab(text: 'Tổng quan'),
                      Tab(text: 'Bài học'),
                      Tab(text: 'Nhiệm vụ'),
                    ],
                  ),
                ),
              ),
            ];
          },
          body: TabBarView(
            children: [
              _buildOverviewTab(),
              _buildSectionsTab(),
              _buildMissionsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMissionsTab() {
    if (_isLoadingMissions) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_courseMissions.isEmpty) {
      return const Center(child: Text("Không có nhiệm vụ học tập nào."));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _courseMissions.length,
      itemBuilder: (context, index) {
        return MissionItem(
          mission: _courseMissions[index],
          showCourse: false,
        );
      },
    );
  }

  Widget _buildHeaderImage(String? imageUrl) {
    if (imageUrl == null || imageUrl.isEmpty) {
      return Image.asset(
        'lib/assets/image/homeTabBackground.jpg',
        fit: BoxFit.cover,
      );
    }
    if (imageUrl.startsWith('data:image/svg+xml;base64,')) {
      // Basic SVG local handling or placeholder
      return Container(color: Colors.grey[300]);
    }
    return Image.network(imageUrl,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(color: Colors.grey[300]));
  }

  Widget _buildOverviewTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Kế hoạch học tập học phần',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.calendar_today_outlined, size: 18),
            label: const Text('Kế hoạch học tập'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF282A75),
              side: const BorderSide(color: Color(0xFF282A75)),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Mô tả học phần',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          Text(
            _getCourseDescription(),
            style: const TextStyle(
                fontSize: 15, color: Colors.black87, height: 1.5),
            maxLines: _isDescriptionExpanded ? null : 4,
            overflow: _isDescriptionExpanded
                ? TextOverflow.visible
                : TextOverflow.ellipsis,
          ),
          if (_getCourseDescription().length > 150)
            TextButton(
              onPressed: () {
                setState(() {
                  _isDescriptionExpanded = !_isDescriptionExpanded;
                });
              },
              child: Text(_isDescriptionExpanded ? 'Thu gọn' : 'Xem thêm',
                  style: const TextStyle(color: Color(0xFF282A75))),
            ),
          const SizedBox(height: 24),
          const Text(
            'Danh sách sinh viên trong khóa học',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStudentList(),
        ],
      ),
    );
  }

  String _getCourseDescription() {
    // 1. Try course summary
    if (_detail?.course.summary != null &&
        _stripHtml(_detail!.course.summary!).isNotEmpty) {
      return _stripHtml(_detail!.course.summary!);
    }

    // 2. Try first section (e.g., "General") summary
    if (_detail?.sections != null && _detail!.sections.isNotEmpty) {
      final section = _detail!.sections.first;
      final desc = section.summaryStripped ??
          (section.summary != null ? _stripHtml(section.summary!) : null);
      if (desc != null && desc.trim().isNotEmpty) {
        return desc.trim();
      }
    }

    return "Chưa có mô tả cho khóa học này.";
  }

  Widget _buildStudentList() {
    if (_detail!.students.isEmpty)
      return const Text("Chưa có danh sách sinh viên.");

    return SizedBox(
      height: 40,
      child: Stack(
        children: List.generate(
          _detail!.students.length > 5 ? 5 : _detail!.students.length,
          (index) {
            return Positioned(
              left: index * 25.0,
              child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.white,
                child: CircleAvatar(
                  radius: 16,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _detail!.students[index].profileimageurl !=
                          null
                      ? NetworkImage(_detail!.students[index].profileimageurl!)
                      : null,
                  child: _detail!.students[index].profileimageurl == null
                      ? const Icon(Icons.person, size: 20)
                      : null,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionsTab() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: _detail!.sections.length,
      itemBuilder: (context, index) {
        final section = _detail!.sections[index];

        // Debug print to check if data is coming through
        debugPrint(
            'Section: ${section.name}, Summary Length: ${section.summary?.length}, Stripped Length: ${section.summaryStripped?.length}');

        if (section.modules.isEmpty &&
            (section.summary == null || section.summary!.isEmpty)) {
          return const SizedBox();
        }

        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            title: Text(
              section.name,
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.black87),
            ),
            childrenPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            expandedAlignment: Alignment.topLeft,
            children: [
              if ((section.summaryStripped != null &&
                      section.summaryStripped!.trim().isNotEmpty) ||
                  (section.summary != null &&
                      section.summary!.trim().isNotEmpty))
                Padding(
                  padding:
                      const EdgeInsets.only(bottom: 12, left: 16, right: 16),
                  child: Text(
                    _stripHtml(
                        section.summaryStripped ?? section.summary ?? ""),
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ...section.modules.map((module) {
                return ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16),
                  leading: _getModuleIcon(module.modname),
                  title: Text(
                    module.name,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  onTap: () {
                    // Handle module click
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _getModuleIcon(String modname) {
    switch (modname) {
      case 'resource':
        return const Icon(Icons.description_outlined, color: Colors.orange);
      case 'quiz':
        return const Icon(Icons.help_outline, color: Colors.blue);
      case 'assign':
        return const Icon(Icons.assignment_outlined, color: Colors.green);
      default:
        return const Icon(Icons.folder_open_outlined);
    }
  }

  String _stripHtml(String html) {
    if (html.isEmpty) return "";
    // Remove HTML tags
    String result = html.replaceAll(RegExp(r'<[^>]*>'), '');
    // Replace common HTML entities
    result = result.replaceAll('&nbsp;', ' ');
    result = result.replaceAll('&amp;', '&');
    result = result.replaceAll('&quot;', '"');
    result = result.replaceAll('&#39;', "'");
    result = result.replaceAll('&lt;', '<');
    result = result.replaceAll('&gt;', '>');
    return result.trim();
  }
}

class _SliverAppBarDelegate extends SliverPersistentHeaderDelegate {
  _SliverAppBarDelegate(this._tabBar);

  final TabBar _tabBar;

  @override
  double get minExtent => _tabBar.preferredSize.height;
  @override
  double get maxExtent => _tabBar.preferredSize.height;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: Colors.white,
      child: _tabBar,
    );
  }

  @override
  bool shouldRebuild(_SliverAppBarDelegate oldDelegate) {
    return false;
  }
}
