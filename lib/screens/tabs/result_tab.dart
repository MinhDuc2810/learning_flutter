import 'package:flutter/material.dart';
import '../../theme/ons_color.dart';
import '../../data_providers/result.dart';
import '../../data/models/academic_result.dart';
import './widgets/result_item.dart';

class ResultTab extends StatefulWidget {
  final String username;
  const ResultTab({super.key, required this.username});

  @override
  State<ResultTab> createState() => _ResultTabState();
}

class _ResultTabState extends State<ResultTab> {
  int _selectedTab = 0; // 0: Kết quả, 1: Điểm TK, 2: DS miễn môn
  final List<String> _tabs = ['Kết quả', 'Điểm TK', 'DS miễn môn'];

  String _searchKey = '';
  String? _selectedStatus;
  String? _selectedCondition;

  List<AcademicResult>? _results;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _fetchResults();
  }

  Future<void> _fetchResults() async {
    try {
      if (mounted) setState(() => _isLoading = true);
      final response = await ResultAPI.list();

      List<dynamic> data = [];
      if (response is List) {
        data = response;
      } else if (response is Map && response['results'] != null) {
        data = response['results'];
      }

      if (mounted) {
        setState(() {
          _results = data.map((item) => AcademicResult.fromJson(item)).toList();
          _isLoading = false;
          _error = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _error = "Lỗi khi tải kết quả học tập";
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Kết quả học tập',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 24,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Tab Switcher
          _buildTabSwitcher(),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  // Search
                  _buildInputLabel('Tìm kiếm'),
                  _buildSearchBox(),

                  const SizedBox(height: 16),
                  // Dropdowns
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Trạng thái'),
                            _buildDropdown(
                              _selectedStatus,
                              _uniqueStatuses,
                              'Tất cả',
                              (val) => setState(() => _selectedStatus = val),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInputLabel('Điều kiện dự thi'),
                            _buildDropdown(
                              _selectedCondition,
                              _uniqueConditions,
                              'Tất cả',
                              (val) => setState(() => _selectedCondition = val),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  // List Header
                  _buildListHeader(),

                  // Results List
                  _buildResultsList(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSwitcher() {
    return Container(
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: List.generate(_tabs.length, (index) {
          bool isSelected = _selectedTab == index;
          return Expanded(
            child: InkWell(
              onTap: () => setState(() => _selectedTab = index),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: isSelected
                          ? const Color(0xFF282A75)
                          : Colors.transparent,
                      width: 3,
                    ),
                  ),
                ),
                child: Text(
                  _tabs[index],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        isSelected ? const Color(0xFF282A75) : Colors.black54,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildInputLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        label,
        style: TextStyle(color: Colors.grey[600], fontSize: 14),
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: TextField(
        onChanged: (val) => setState(() => _searchKey = val),
        decoration: InputDecoration(
          hintText: 'Nhập từ khóa',
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown(String? value, List<String> items, String hint,
      Function(String?) onChanged) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint,
              style: TextStyle(color: Colors.grey[500], fontSize: 14)),
          isExpanded: true,
          items: [
            DropdownMenuItem<String>(
              value: null,
              child: Text(hint, style: const TextStyle(fontSize: 14)),
            ),
            ...items.map((String item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item, style: const TextStyle(fontSize: 14)),
              );
            }),
          ],
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down, size: 24),
        ),
      ),
    );
  }

  Widget _buildListHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
      ),
      child: const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'Học phần',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
          Text(
            'Trạng thái',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
          ),
        ],
      ),
    );
  }

  Widget _buildResultsList() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.only(top: 50),
        child: Center(
            child: Text(_error!, style: const TextStyle(color: Colors.grey))),
      );
    }

    var filtered = _results ?? [];
    if (_searchKey.isNotEmpty) {
      filtered = filtered
          .where((r) =>
              r.courseName.toLowerCase().contains(_searchKey.toLowerCase()))
          .toList();
    }
    if (_selectedStatus != null) {
      filtered = filtered.where((r) => r.status == _selectedStatus).toList();
    }
    if (_selectedCondition != null) {
      filtered =
          filtered.where((r) => r.examCondition == _selectedCondition).toList();
    }

    if (filtered.isEmpty) {
      return const Padding(
        padding: EdgeInsets.only(top: 50),
        child: Center(child: Text("Không có dữ liệu")),
      );
    }

    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filtered.length,
      separatorBuilder: (context, index) =>
          Divider(height: 1, color: Colors.grey[200]),
      itemBuilder: (context, index) {
        return ResultItem(result: filtered[index]);
      },
    );
  }

  List<String> get _uniqueStatuses {
    if (_results == null) return [];
    return _results!
        .map((r) => r.status)
        .where((s) => s.isNotEmpty)
        .toSet()
        .toList();
  }

  List<String> get _uniqueConditions {
    if (_results == null) return [];
    return _results!
        .map((r) => r.examCondition)
        .where((c) => c.isNotEmpty)
        .toSet()
        .toList();
  }
}
