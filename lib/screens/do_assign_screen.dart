import 'package:flutter/material.dart';
import '../data_providers/assign.dart';
import '../utils/logger.dart';
import '../utils/local_storage.dart';
import '../constants/storage_key.dart';
import 'dart:convert';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import '../data_providers/moodle_autologin.dart';

class DoAssignScreen extends StatefulWidget {
  final int assignId;
  final String assignName;

  const DoAssignScreen({
    super.key,
    required this.assignId,
    required this.assignName,
  });

  @override
  State<DoAssignScreen> createState() => _DoAssignScreenState();
}

class _DoAssignScreenState extends State<DoAssignScreen> {
  bool _isLoading = true;
  bool _isSubmitting = false;
  PlatformFile? _selectedFile;

  // Data từ getGrade API
  Map<String, dynamic>? _gradeData;
  // Data từ submissionStatus API (lấy duedate, allowsubmissionsfromdate)
  Map<String, dynamic>? _statusData;

  @override
  void initState() {
    super.initState();
    _fetchAssignData();
  }

  Future<void> _fetchAssignData() async {
    try {
      // Gọi song song cả 2 API
      final results = await Future.wait([
        AssignAPI.getGrade(assignId: widget.assignId),
        AssignAPI.submissionStatus(assignId: widget.assignId),
      ]);

      final grade = results[0];
      final status = results[1];
      logger("getGrade response: ${jsonEncode(grade)}");

      if (mounted) {
        setState(() {
          _gradeData = grade is Map<String, dynamic> ? grade : null;
          _statusData = status is Map<String, dynamic> ? status : null;
          _isLoading = false;
        });
      }
    } catch (e) {
      logger("Error fetching assign data: $e");
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatTs(dynamic ts) {
    if (ts == null || ts == 0) return "---";
    int timestamp = 0;
    if (ts is int)
      timestamp = ts;
    else if (ts is String) timestamp = int.tryParse(ts) ?? 0;

    if (timestamp == 0) return "---";
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp * 1000);
    return "${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')} - ${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }

  // Danh sách file từ getGrade -> lastattempt -> files
  List<dynamic> _getFileList() {
    final files = _gradeData?['lastattempt']?['files'];
    if (files is List) return files;
    return [];
  }

  // Tìm itemid của vùng nháp từ submissionStatus API
  dynamic _getFileAreaItemId() {
    // 1. Kiểm tra trong submissionStatus (_statusData)
    // Moodle thường trả về ở: lastattempt -> submission -> plugins -> [type=file] -> fileareas -> itemid
    if (_statusData != null) {
      try {
        final lastAttempt = _statusData!['lastattempt'];
        if (lastAttempt != null) {
          final submission = lastAttempt['submission'];
          if (submission != null) {
            final plugins = submission['plugins'];
            if (plugins is List) {
              for (var plugin in plugins) {
                if (plugin['type'] == 'file') {
                  final fileareas = plugin['fileareas'];
                  if (fileareas is List && fileareas.isNotEmpty) {
                    final itemid = fileareas[0]['itemid'];
                    if (itemid != null && itemid != 0) {
                      return itemid;
                    }
                  }
                }
              }
            }
          }
        }
      } catch (e) {
        logger("Lỗi khi tìm itemid trong _statusData: $e");
      }
    }

    // 2. Fallback về timegraded nếu không tìm thấy (giữ logic cũ của hệ thống)
    return _gradeData?['timegraded'];
  }

  String _formatFileSize(int bytes) {
    if (bytes <= 0) return "0 B";
    const suffixes = ["B", "KB", "MB", "GB", "TB"];
    int i = (bytes > 0 ? (bytes.toString().length - 1) : 0) ~/ 3;
    return "${(bytes / (1 << (i * 10))).toStringAsFixed(2)} ${suffixes[i]}";
  }

  @override
  Widget build(BuildContext context) {
    final grade = _gradeData;
    final lastAttempt = grade?['lastattempt'];
    final info = _statusData?['info'];

    bool isOverdue = false;
    if (info != null && info['duedate'] != null) {
      int dueDateSeconds = 0;
      if (info['duedate'] is int) {
        dueDateSeconds = info['duedate'];
      } else if (info['duedate'] is String) {
        dueDateSeconds = int.tryParse(info['duedate']) ?? 0;
      }
      if (dueDateSeconds > 0) {
        final dueDate = DateTime.fromMillisecondsSinceEpoch(dueDateSeconds * 1000);
        if (DateTime.now().isAfter(dueDate)) {
          isOverdue = true;
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1A1A1A),
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {},
        ),
        title: Text(
          widget.assignName,
          style: const TextStyle(color: Colors.white, fontSize: 18),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.assignName,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Thông tin bài tập từ submissionStatus
                  if (info != null) ...[
                    _buildInfoRow(
                      "Bắt đầu nộp bài:",
                      _formatTs(info['allowsubmissionsfromdate']),
                    ),
                    _buildInfoRow(
                      "Hạn chót nộp bài:",
                      _formatTs(info['duedate']),
                    ),
                  ],
                  const SizedBox(height: 8),
                  // Thông tin chấm điểm từ getGrade
                  _buildInfoRow(
                    "Số lượng file:",
                    [
                      grade?['numfiles']?.toString() ??
                          _getFileList().length.toString(),
                      if (grade?['maxfile'] != null) "/${grade!['maxfile']}",
                    ].join(),
                  ),
                  _buildInfoRow(
                    "Điểm:",
                    grade?['grade'] != null
                        ? [
                            grade!['grade'].toString(),
                            if (grade['maxgrade'] != null)
                              "/${grade['maxgrade']}",
                          ].join()
                        : "Chưa có điểm",
                    valueColor: grade?['grade'] != null && grade!['grade'] > 0
                        ? Colors.green
                        : Colors.grey,
                  ),
                  _buildInfoRow(
                    "Trạng thái:",
                    grade?['status'] ?? lastAttempt?['status'] ?? "---",
                    valueColor: Colors.grey,
                  ),
                  _buildInfoRow(
                    "L\u1ea7n cu\u1ed1i s\u1eeda:",
                    _formatTs(grade?['lastupdate']),
                    valueColor: Colors.grey,
                  ),
                  _buildInfoRow(
                    "Ng\u00e0y ch\u1ea5m:",
                    lastAttempt?['timegraded'] != null &&
                            lastAttempt!['timegraded'] != 0
                        ? _formatTs(lastAttempt['timegraded'])
                        : "---",
                    valueColor: Colors.grey,
                  ),
                  _buildInfoRow(
                    "Người chấm:",
                    (lastAttempt?['grader'] != null &&
                            lastAttempt!['grader'].toString().isNotEmpty)
                        ? lastAttempt['grader']
                        : (grade?['grader'] != null &&
                                grade!['grader'].toString().isNotEmpty
                            ? grade['grader']
                            : "---"),
                    valueColor: Colors.grey,
                  ),
                  if (lastAttempt?['feedback'] != null) ...[
                    const SizedBox(height: 8),
                    _buildInfoRow(
                      "Nhận xét:",
                      lastAttempt!['feedback'].toString(),
                      valueColor: Colors.black87,
                    ),
                  ],
                  const SizedBox(height: 24),
                  const Text(
                    "File nộp bài:",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  ..._getFileList().map((file) => Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: _buildFileItem(
                          fileName: file['filename'] ?? "Unknown file",
                          fileSize: _formatFileSize(file['filesize'] ?? 0),
                          onDownload: () =>
                              _handleOpenDownload(file['fileurl'] ?? ""),
                          onDelete: isOverdue ? null : () => _handleDeleteFile(
                            filename: file['filename'] ?? "",
                            // fileid có trong lastattempt.files!
                            fileId: file['fileid'] ?? 0,
                          ),
                          onReplace: isOverdue ? null : () => _handleUpload(
                            fileIdToReplace: file['fileid'] is int
                                ? file['fileid']
                                : int.tryParse(file['fileid'].toString()),
                          ),
                        ),
                      )),
                  if (_getFileList().isEmpty && _selectedFile == null)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8.0),
                      child: Text("Chưa có file nào được nộp.",
                          style: TextStyle(color: Colors.grey)),
                    ),
                  if (_selectedFile != null) ...[
                    const SizedBox(height: 12),
                    const Text(
                      "File đã chọn (chưa nộp):",
                      style:
                          TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    _buildFileItem(
                      fileName: _selectedFile!.name,
                      fileSize: _formatFileSize(_selectedFile!.size),
                      onDelete: isOverdue ? null : () => setState(() => _selectedFile = null),
                    ),
                  ],
                  const SizedBox(height: 24),
                  SizedBox(
                    width: 160,
                    child: ElevatedButton.icon(
                      onPressed: isOverdue ? null : _handleUpload,
                      icon: const Icon(Icons.upload, size: 20),
                      label: const Text("Tải file lên"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF5F5F5),
                        foregroundColor: isOverdue ? Colors.grey : Colors.black,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton(
          onPressed: (_isSubmitting || isOverdue) ? null : _handleSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor:
                (_isSubmitting || isOverdue) ? Colors.grey : const Color(0xFF282A75),
            minimumSize: const Size(double.infinity, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: _isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2),
                )
              : Text(
                  isOverdue ? "Đã quá hạn nộp bài" : "Nộp bài",
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(fontSize: 15, color: Colors.black),
          children: [
            TextSpan(text: "$label "),
            TextSpan(
              text: value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: valueColor ?? Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleOpenDownload(String fileurl) async {
    if (fileurl.isEmpty) return;

    // Sử dụng MoodleAutologinAPI để chuyển hướng tự động đăng nhập
    String autologinUrl = await MoodleAutologinAPI.getAutologinUrl(fileurl);
    final uri = Uri.parse(autologinUrl);

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      logger("Could not launch $autologinUrl");
    }
  }

  Future<void> _handleDeleteFile({
    required String filename,
    required dynamic fileId,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận xóa"),
        content: Text("Bạn có chắc chắn muốn xóa file '$filename' không?"),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Xóa", style: TextStyle(color: Colors.red))),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Đang xóa file...")),
        );

        final parsedFileId =
            fileId is int ? fileId : int.tryParse(fileId.toString()) ?? 0;
        logger("Deleting '$filename' with fileid=$parsedFileId");

        final deleteResult = await AssignAPI.delete(
          fileId: parsedFileId,
          confirm: 1,
        );
        logger("Delete API response: ${jsonEncode(deleteResult)}");

        if (deleteResult is Map &&
            (deleteResult['exception'] != null ||
                deleteResult['errorcode'] != null)) {
          final errMsg = deleteResult['message'] ??
              deleteResult['error'] ??
              'Xóa thất bại';
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content: Text("Lỗi: $errMsg"), backgroundColor: Colors.red),
            );
          }
          return;
        }

        if (mounted) {
          await _fetchAssignData();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Đã xóa file thành công.")),
          );
        }
      } catch (e) {
        logger("Error deleting file: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text("Xóa file thất bại. Vui lòng thử lại.")),
          );
        }
      }
    }
  }

  Future<void> _handleUpload({int? fileIdToReplace}) async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles();
      if (result != null) {
        setState(() {
          _selectedFile = result.files.first;
        });
        logger("Picked file: ${_selectedFile!.name}");
      }
    } catch (e) {
      logger("Error picking file: $e");
    }
  }

  void _showError(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi: $message"), backgroundColor: Colors.red),
      );
    }
  }

  Future<void> _handleSubmit() async {
    if (_selectedFile == null && _getFileList().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text(
                "Vui lòng tải lên hoặc chọn ít nhất một file trước khi nộp bài.")),
      );
      return;
    }

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Xác nhận nộp bài"),
        content: const Text(
            "Bạn có chắc chắn muốn nộp bài không? Hành động này không thể hoàn tác."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text("Hủy")),
          TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text("Nộp bài",
                  style: TextStyle(color: Color(0xFF282A75)))),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _isSubmitting = true);
    try {
      dynamic itemId;

      // Nếu có file mới được chọn, upload nó trước
      if (_selectedFile != null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Đang tải lên: ${_selectedFile!.name}...")),
          );
        }

        final token = await LocalStorage.getString(StorageKey.token) ?? "";
        final uploadResult = await AssignAPI.uploadFile(
          token: token,
          filePath: _selectedFile!.path!,
          itemid: "0", // Fresh draft area
        );

        logger("Upload result: ${jsonEncode(uploadResult)}");

        if (uploadResult is List && uploadResult.isNotEmpty) {
          final firstResult = uploadResult[0];
          if (firstResult['error'] != null) {
            _showError(firstResult['error']);
            return;
          }
          itemId = firstResult['itemid'];
        } else if (uploadResult is Map && uploadResult['itemid'] != null) {
          itemId = uploadResult['itemid'];
        }

        if (itemId == null) {
          _showError("Không thể tải file lên. Vui lòng thử lại.");
          return;
        }
      } else {
        // Nếu không có file mới, lấy itemId từ các file hiện có
        itemId = _getFileAreaItemId();
      }

      if (itemId == null || itemId == 0) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Không tìm thấy thông tin file để nộp.")),
        );
        return;
      }

      final result = await AssignAPI.submit(
        assignId: widget.assignId,
        fileItemId: itemId,
      );
      logger("Submit result: $result");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nộp bài thành công!"),
            backgroundColor: Colors.green,
          ),
        );
        setState(() {
          _selectedFile = null;
        });
        _fetchAssignData();
      }
    } catch (e) {
      logger("Error submitting: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Nộp bài thất bại. Vui lòng thử lại."),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  Widget _buildFileItem({
    required String fileName,
    required String fileSize,
    VoidCallback? onDownload,
    VoidCallback? onDelete,
    VoidCallback? onReplace,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2D3277),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.description,
                    color: Colors.white, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      fileName,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      fileSize,
                      style:
                          TextStyle(color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildFileAction(
                  Icons.download_outlined, "Tải xuống", onDownload),
              _buildFileAction(Icons.refresh, "Thay thế", onReplace),
              _buildFileAction(Icons.delete_outline, "Xóa", onDelete),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFileAction(IconData icon, String label, VoidCallback? onTap) {
    final color = onTap == null ? Colors.grey.shade400 : Colors.grey.shade700;
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Icon(icon, size: 20, color: color),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(color: color, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
