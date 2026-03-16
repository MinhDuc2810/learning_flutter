import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/storage_key.dart';
import '../utils/local_storage.dart';
import '../utils/logger.dart';
import '../utils/ons_clients.dart';
import '../data_providers/moodle_autologin.dart';
import '../screens/pdf_view_screen.dart';

class OnsWebview extends StatefulWidget {
  final String url;
  final String? title;

  const OnsWebview({super.key, required this.url, this.title});

  @override
  State<OnsWebview> createState() => _OnsWebviewState();
}

class _OnsWebviewState extends State<OnsWebview> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isControllerInitialized = false;
  String? _token;

  @override
  void initState() {
    super.initState();
    _initPermissions();
    _initController();
  }

  Future<void> _initPermissions() async {
    await [
      Permission.camera,
      Permission.microphone,
    ].request();
  }

  // Kiểm tra URL có phải là file PDF không
  bool _isPdfUrl(String url) {
    final lower = url.toLowerCase();
    // Một URL PDF hợp lệ để xem trực tiếp (không qua WebView) thường chứa 'pluginfile.php'
    // và kết thúc bằng .pdf (hoặc có .pdf trước dấu ?)
    return (lower.contains('pluginfile.php') ||
            lower.contains('/webservice/pluginfile.php')) &&
        lower.contains('.pdf') &&
        (lower.split('?').first.endsWith('.pdf') || lower.contains('.pdf?'));
  }

  // Phương thức hiển thị PDF cục bộ thông qua PDFViewScreen

  Future<void> _initController() async {
    try {
      _token = await LocalStorage.getString(StorageKey.token);
      String initialUrl = widget.url;
      String finalUrl;

      if (_isPdfUrl(initialUrl)) {
        // Nếu là PDF, sử dụng PDFViewScreen để hiển thị cục bộ
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => PDFViewScreen(
              url: OnsClient.buildAuthUrl(initialUrl, _token ?? ""),
              title: widget.title ?? "Tài liệu PDF",
            ),
          ),
        );
        return;
      } else {
        // Nếu là nội dung Web (H5P, Forum, SCORM), dùng Autologin để có Session
        finalUrl = await MoodleAutologinAPI.getAutologinUrl(initialUrl);
      }

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent(
            "Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/114.0.0.0 Mobile Safari/537.36")
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              logger('WebView Error: ${error.description}');
            },
            onNavigationRequest: (NavigationRequest request) {
              final url = request.url;
              // Chặn URL PDF và chuyển sang PDFViewScreen
              if (_isPdfUrl(url)) {
                logger(
                    'Phát hiện PDF trong navigation, mở PDFViewScreen: $url');
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PDFViewScreen(
                      url: OnsClient.buildAuthUrl(url, _token ?? ""),
                      title: widget.title ?? "Tài liệu PDF",
                    ),
                  ),
                );
                return NavigationDecision.prevent;
              }
              return NavigationDecision.navigate;
            },
          ),
        )
        ..loadRequest(Uri.parse(finalUrl));

      logger('WebView Loading Request: $finalUrl');

      if (mounted) {
        setState(() {
          _isControllerInitialized = true;
        });
      }
    } catch (e) {
      logger('Init Controller Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        centerTitle: true,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1.0),
          child: Container(
            color: Colors.grey[200],
            height: 1.0,
          ),
        ),
      ),
      body: Stack(
        children: [
          if (_isControllerInitialized)
            WebViewWidget(controller: _controller)
          else
            const SizedBox.shrink(),
          if (_isLoading || !_isControllerInitialized)
            const Center(
              child: CircularProgressIndicator(),
            ),
        ],
      ),
    );
  }
}
