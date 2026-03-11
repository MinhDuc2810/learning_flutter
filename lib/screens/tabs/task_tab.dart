import 'package:flutter/material.dart';
import '../../theme/ons_color.dart';
import '../../data/models/mission.dart';
import '../../data_providers/mission.dart';
import './widgets/mission_item.dart';

class TaskTab extends StatefulWidget {
  final String username;
  const TaskTab({super.key, required this.username});

  @override
  State<TaskTab> createState() => _TaskTabState();
}

class _TaskTabState extends State<TaskTab> {
  int _selectedTimeline = 2; // 0: Sắp tới, 1: Tuần này, 2: Tất cả
  final List<String> _timelines = ['Sắp tới', 'Tuần này', 'Tất cả'];

  String? _selectedCourse;
  String? _selectedStatus;

  List<Mission>? _missions;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchMissions();
  }

  Future<void> _fetchMissions() async {
    try {
      if (mounted) setState(() => _isLoading = true);

      // Map index to timeline string if needed, currently using 'all'
      String timelineStr = 'all';
      if (_selectedTimeline == 0) timelineStr = 'upcoming';

      final response = await MissionAPI.listCompletion(
        timeline: timelineStr,
      );

      // Assuming Moodle returns a list of statuses or similar
      // For now, let's look for 'statuses' or similar key
      List<dynamic> statusList = [];
      if (response is Map && response['statuses'] != null) {
        statusList = response['statuses'];
      } else if (response is List) {
        statusList = response;
      }

      if (mounted) {
        setState(() {
          _missions = statusList.map((m) => Mission.fromJson(m)).toList();
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Lỗi khi tải danh sách nhiệm vụ";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F5),
      appBar: AppBar(
        title: const Text(
          'Nhiệm vụ học tập',
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
      body: Column(
        children: [
          // Filters and Selection section
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              children: [
                // Timeline Filters
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: List.generate(_timelines.length, (index) {
                      bool isSelected = _selectedTimeline == index;
                      return Padding(
                        padding: const EdgeInsets.only(right: 12),
                        child: InkWell(
                          onTap: () {
                            setState(() => _selectedTimeline = index);
                            _fetchMissions();
                          },
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
                              _timelines[index],
                              style: TextStyle(
                                color:
                                    isSelected ? Colors.white : Colors.black87,
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
                const SizedBox(height: 16),
                // Dropdowns
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(
                        child: _buildDropdown(
                          'Học phần',
                          _selectedCourse,
                          _uniqueCourses,
                          (val) => setState(() => _selectedCourse = val),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildDropdown(
                          'Trạng thái',
                          _selectedStatus,
                          _uniqueStatuses,
                          (val) => setState(() => _selectedStatus = val),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // List section
          Expanded(
            child: _buildMissionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildDropdown(String hint, String? value, List<String> items,
      Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey[500], fontSize: 13)),
          isExpanded: true,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(hint,
                  style: const TextStyle(fontSize: 13, color: Colors.grey)),
            ),
            ...items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item,
                    style: const TextStyle(fontSize: 13),
                    overflow: TextOverflow.ellipsis),
              );
            }),
          ],
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 20),
        ),
      ),
    );
  }

  Widget _buildMissionList() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_error != null) {
      return Center(
          child: Text(_error!, style: const TextStyle(color: Colors.grey)));
    }

    // Filter missions based on selection
    var filteredMissions = _missions ?? [];
    if (_selectedCourse != null) {
      filteredMissions = filteredMissions
          .where((m) => m.courseName == _selectedCourse)
          .toList();
    }
    if (_selectedStatus != null) {
      filteredMissions = filteredMissions
          .where((m) => m.stateName == _selectedStatus)
          .toList();
    }

    if (filteredMissions.isEmpty) {
      return const Center(child: Text("Không có nhiệm vụ nào"));
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: filteredMissions.length,
      itemBuilder: (context, index) {
        return MissionItem(
          mission: filteredMissions[index],
          onTap: () {
            // Navigate to detail
          },
        );
      },
    );
  }

  // Helper to get unique values for dropdowns
  List<String> get _uniqueCourses {
    if (_missions == null) return [];
    return _missions!.map((m) => m.courseName).toSet().toList();
  }

  List<String> get _uniqueStatuses {
    if (_missions == null) return [];
    return _missions!.map((m) => m.stateName).toSet().toList();
  }
}
