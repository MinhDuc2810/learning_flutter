class ForumDiscussion {
  final int id;
  final int forumid;
  final int courseid;
  final String name;
  final String intro;
  final int totalpost;
  final String usercreated;
  final dynamic createdtime;
  final String userlastpost;
  final dynamic lastposttime;
  final bool starred;
  final bool subscribed;
  final int totallike;

  ForumDiscussion({
    required this.id,
    this.forumid = 0,
    this.courseid = 0,
    required this.name,
    required this.intro,
    required this.totalpost,
    required this.usercreated,
    required this.createdtime,
    required this.userlastpost,
    required this.lastposttime,
    this.starred = false,
    this.subscribed = false,
    this.totallike = 0,
  });

  factory ForumDiscussion.fromJson(Map<String, dynamic> json) {
    bool parseBool(dynamic value) {
      if (value is bool) return value;
      if (value is String) return value.toLowerCase() == "true" || value == "1";
      return false;
    }

    return ForumDiscussion(
      id: int.tryParse(json['id']?.toString() ??
              json['discussionid']?.toString() ??
              json['discussion']?.toString() ??
              '0') ??
          0,
      forumid: int.tryParse(json['forumid']?.toString() ?? '0') ?? 0,
      courseid: int.tryParse(json['courseid']?.toString() ?? '0') ?? 0,
      name: json['name'] ?? '',
      intro: json['intro'] ?? '',
      totalpost: int.tryParse(json['totalpost']?.toString() ?? '0') ?? 0,
      usercreated: json['usercreated'] ?? '',
      createdtime: json['createdtime'],
      userlastpost: json['userlastpost'] ?? '',
      lastposttime: json['lastposttime'],
      starred: parseBool(json['starred'] ?? json['sci']),
      subscribed: parseBool(json['sub'] ?? json['subscribed']),
      totallike: int.tryParse(json['totallike']?.toString() ?? '0') ?? 0,
    );
  }
}

class ForumDetailData {
  final int forumId;
  final String coursename;
  final String courseimage;
  final int totalDiscussion;
  final String checkJoin;
  final List<ForumDiscussion> discussions;

  ForumDetailData({
    required this.forumId,
    required this.coursename,
    required this.courseimage,
    required this.totalDiscussion,
    required this.checkJoin,
    required this.discussions,
  });

  factory ForumDetailData.fromJson(Map<String, dynamic> json) {
    var list = json['discussion'] as List? ?? [];
    List<ForumDiscussion> discussionsList =
        list.map((i) => ForumDiscussion.fromJson(i)).toList();

    return ForumDetailData(
      forumId: int.tryParse(json['forumid']?.toString() ?? '0') ?? 0,
      coursename: json['coursename'] ?? '',
      courseimage: json['courseimage'] ?? '',
      totalDiscussion:
          int.tryParse(json['total_discussion']?.toString() ?? '0') ?? 0,
      checkJoin: json['check_join']?.toString() ?? '',
      discussions: discussionsList,
    );
  }
}
