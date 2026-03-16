import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import '../utils/logger.dart';

class PDFViewScreen extends StatefulWidget {
  final String url;
  final String title;

  const PDFViewScreen({super.key, required this.url, required this.title});

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  String? _localPath;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _downloadFile();
  }

  Future<void> _downloadFile() async {
    try {
      logger('PDF Downloading from: ${widget.url}');
      final response = await http.get(Uri.parse(widget.url));

      logger('PDF Response Code: ${response.statusCode}');
      logger('PDF Content-Type: ${response.headers['content-type']}');

      if (response.statusCode == 200) {
        final bytes = response.bodyBytes;

        // Kiểm tra xem có phải file PDF thực sự không (PDF bắt đầu bằng %PDF)
        if (bytes.length > 4 &&
            bytes[0] == 0x25 &&
            bytes[1] == 0x50 &&
            bytes[2] == 0x44 &&
            bytes[3] == 0x46) {
          final dir = await getTemporaryDirectory();
          final file = File(
              '${dir.path}/pdf_${DateTime.now().millisecondsSinceEpoch}.pdf');
          await file.writeAsBytes(bytes);
          if (mounted) {
            setState(() {
              _localPath = file.path;
              _isLoading = false;
            });
          }
        } else {
          // Log nội dung nếu không phải PDF để debug
          final contentSample = response.body.length > 200
              ? response.body.substring(0, 200)
              : response.body;
          logger(
              'Nội dung nhận được không phải PDF (có thể là HTML lỗi): $contentSample');
          throw Exception('File nhận được không đúng định dạng PDF.');
        }
      } else {
        throw Exception('Lỗi mạng: ${response.statusCode}');
      }
    } catch (e) {
      logger('PDF Download Error: $e');
      if (mounted) {
        setState(() {
          _errorMessage =
              'Không thể hiển thị PDF (Lỗi định dạng hoặc quyền truy cập).';
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: _isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Đang tải tài liệu...'),
                ],
              ),
            )
          : _errorMessage != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.error_outline,
                            size: 64, color: Colors.red),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Quay lại'),
                        ),
                      ],
                    ),
                  ),
                )
              : PDFView(
                  filePath: _localPath,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: false,
                  pageFling: false,
                  onError: (error) {
                    logger('PDFView Error: $error');
                  },
                  onPageError: (page, error) {
                    logger('PDFView Page Error: $page: $error');
                  },
                ),
    );
  }
}
