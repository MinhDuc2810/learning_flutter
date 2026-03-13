import 'package:flutter/material.dart';
import '../data_providers/forum.dart';
import '../data/models/forum_discussion.dart';
import './tabs/widgets/forum_item.dart';
import 'dart:convert';
import '../theme/ons_color.dart';
import '../utils/logger.dart';

class ForumDetailScreen extends StatefulWidget {
  final int forumId;
  final String forumName;

  const ForumDetailScreen({
    super.key,
    required this.forumId,
    required this.forumName,
  });

  @override
  State<ForumDetailScreen> createState() => _ForumDetailScreenState();
}

class _ForumDetailScreenState extends State<ForumDetailScreen> {
  ForumDetailData? _forumData;
  List<ForumDiscussion> _followedDiscussions = [];
  List<ForumDiscussion> _popularDiscussions = [];
  bool _isLoadingAll = true;
  bool _isLoadingFollowed = false;
  bool _isLoadingPopular = false;

  String? _errorAll;
  String? _errorFollowed;
  String? _errorPopular;
  int _selectedFilterIndex = 0; // 0: Tất cả, 1: Đang theo dõi

  @override
  void initState() {
    super.initState();
    _fetchDiscussions();
  }

  Future<void> _fetchDiscussions() async {
    try {
      final response = await ForumAPI.detailForum(id: widget.forumId);
      if (mounted) {
        setState(() {
          if (response is Map &&
              response['success'] == true &&
              response['data'] != null) {
            _forumData = ForumDetailData.fromJson(response['data']);
          } else {
            _errorAll = response['message'] ?? "Lỗi khi tải dữ liệu diễn đàn";
          }
          _isLoadingAll = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorAll = "Lỗi khi tải dữ liệu diễn đàn: $e";
          _isLoadingAll = false;
        });
      }
    }
  }

  Future<void> _fetchFollowing() async {
    setState(() {
      _isLoadingFollowed = true;
      _errorFollowed = null;
    });
    try {
      final response = await ForumAPI.listFollow();
      logger('ForumAPI:listFollow response: ${jsonEncode(response)}');
      if (mounted) {
        setState(() {
          if (response is Map && response['data'] != null) {
            final rawList = response['data'] as List;
            logger('RAW DATA COUNT: ${rawList.length}');

            final allFollowed =
                rawList.map((d) => ForumDiscussion.fromJson(d)).toList();

            _followedDiscussions =
                allFollowed; // Hiển thị tất cả 5 mục để kiểm tra

            // Nếu bạn muốn lọc lại sau khi đã kiểm tra xong, hãy dùng code dưới:
            // _followedDiscussions = allFollowed.where((d) => d.forumid == widget.forumId || d.forumid == 0).toList();

            logger(
                'FILTERED DATA COUNT: ${_followedDiscussions.length} (Target forumId: ${widget.forumId})');
            if (rawList.isNotEmpty) {
              logger('Sample item raw data: ${jsonEncode(rawList[0])}');
            }
          } else {
            _followedDiscussions = [];
          }
          _isLoadingFollowed = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching followed discussions: $e');
      if (mounted) {
        setState(() {
          _errorFollowed = "Lỗi khi tải danh sách theo dõi: $e";
          _isLoadingFollowed = false;
        });
      }
    }
  }

  Future<void> _fetchPopular() async {
    setState(() {
      _isLoadingPopular = true;
      _errorPopular = null;
    });
    try {
      final response = await ForumAPI.listPopular();
      logger('ForumAPI:listPopular RAW response: ${jsonEncode(response)}');
      if (mounted) {
        setState(() {
          if (response is Map && response['data'] != null) {
            final rawList = response['data'] as List;
            logger('POPULAR RAW DATA COUNT: ${rawList.length}');
            _popularDiscussions =
                rawList.map((d) => ForumDiscussion.fromJson(d)).toList();
            logger('POPULAR MAPPED COUNT: ${_popularDiscussions.length}');
            if (_popularDiscussions.isNotEmpty) {
              logger('Popular item 0 name: ${_popularDiscussions[0].name}');
            }
          } else {
            _popularDiscussions = [];
            _errorPopular = response != null && response is Map
                ? response['message']
                : "Không có dữ liệu nổi bật";
            logger('Popular API issue: $response');
          }
          _isLoadingPopular = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching popular discussions: $e');
      if (mounted) {
        setState(() {
          _errorPopular = "Lỗi khi tải danh sách nổi bật: $e";
          _isLoadingPopular = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    List<ForumDiscussion> displayList = [];
    bool currentLoading = false;
    String? currentError;

    if (_selectedFilterIndex == 0) {
      // Tất cả
      displayList = _forumData?.discussions ?? [];
      currentLoading = _isLoadingAll;
      currentError = _errorAll;
    } else if (_selectedFilterIndex == 1) {
      // Đang theo dõi
      displayList = _followedDiscussions;
      currentLoading = _isLoadingFollowed;
      currentError = _errorFollowed;
    } else if (_selectedFilterIndex == 2) {
      // Nổi bật
      displayList = _popularDiscussions;
      currentLoading = _isLoadingPopular;
      currentError = _errorPopular;
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F9),
      body: Column(
        children: [
          _buildHeader(),
          _buildFilterBar(),
          Expanded(
            child: currentLoading
                ? const Center(child: CircularProgressIndicator())
                : currentError != null
                    ? Center(child: Text(currentError))
                    : displayList.isEmpty
                        ? const Center(child: Text("Chưa có chủ đề nào."))
                        : RefreshIndicator(
                            onRefresh: () async {
                              if (_selectedFilterIndex == 0) {
                                setState(() {
                                  _isLoadingAll = true;
                                  _errorAll = null;
                                });
                                await _fetchDiscussions();
                              } else if (_selectedFilterIndex == 1) {
                                await _fetchFollowing();
                              } else {
                                await _fetchPopular();
                              }
                            },
                            child: ListView.builder(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 16),
                              itemCount: displayList.length,
                              itemBuilder: (context, index) {
                                return ForumItem(
                                  discussion: displayList[index],
                                  onTap: () {
                                    // Xử lý khi nhấn vào chi tiết thảo luận
                                  },
                                  onSubscribeToggle: () {
                                    // Xử lý khi nhấn theo dõi
                                  },
                                );
                              },
                            ),
                          ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    int count = 0;
    if (_selectedFilterIndex == 0) {
      count = _forumData?.totalDiscussion ?? 0;
    } else if (_selectedFilterIndex == 1) {
      count = _followedDiscussions.length;
    } else if (_selectedFilterIndex == 2) {
      count = _popularDiscussions.length;
    }

    return Container(
      padding: const EdgeInsets.only(top: 50, left: 16, right: 16, bottom: 24),
      decoration: BoxDecoration(
        color: HexColor(StringColor.primary1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 16),
          Text(
            _forumData?.coursename ?? widget.forumName,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildBadge("$count chủ đề", Colors.white, Colors.black),
              const SizedBox(width: 12),
              if (_forumData?.checkJoin != null &&
                  _forumData!.checkJoin.isNotEmpty)
                _buildBadge(
                    (_forumData!.checkJoin == "true" ||
                            _forumData!.checkJoin == "1")
                        ? "Đã tham gia"
                        : _forumData!.checkJoin,
                    const Color(0xFFCEF0D4),
                    const Color(0xFF3E824A)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(String text, Color bgColor, Color textColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(color: textColor, fontWeight: FontWeight.w500),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ["Tất cả chủ đề", "Đang theo dõi", "Nổi bật"];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: Row(
        children: List.generate(filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: InkWell(
              onTap: () {
                setState(() => _selectedFilterIndex = index);
                if (index == 1) {
                  _fetchFollowing();
                } else if (index == 2) {
                  _fetchPopular();
                }
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? HexColor(StringColor.primary1)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border:
                      isSelected ? null : Border.all(color: Colors.grey[200]!),
                ),
                child: Text(
                  filters[index],
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
