import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../data_providers/moodle_autologin.dart';
import '../utils/logger.dart';

class H5PScreen extends StatefulWidget {
  final String url;
  final String? title;

  const H5PScreen({super.key, required this.url, this.title});

  @override
  State<H5PScreen> createState() => _H5PScreenState();
}

class _H5PScreenState extends State<H5PScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isControllerInitialized = false;

  @override
  void initState() {
    super.initState();
    // Cho phép hiển thị dọc đứng và nằm ngang linh hoạt
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    _initController();
  }

  @override
  void dispose() {
    // Trả lại hướng đứng mặc định khi thoát
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  Future<void> _initController() async {
    try {
      // 1. Tự động đăng nhập ngầm vào Moodle Web
      String finalUrl = await MoodleAutologinAPI.getAutologinUrl(widget.url);

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageStarted: (String url) {
              if (mounted) setState(() => _isLoading = true);
            },
            onPageFinished: (String url) {
              _injectAutoPlayJS();
              if (mounted) setState(() => _isLoading = false);
            },
            onWebResourceError: (WebResourceError error) {
              logger('H5P WebView Error: ${error.description}');
            },
          ),
        )
        ..loadRequest(Uri.parse(finalUrl));

      if (mounted) {
        setState(() {
          _isControllerInitialized = true;
        });
      }
    } catch (e) {
      logger('Init Controller Error: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _injectAutoPlayJS() {
    // 2. JS Thuận tuý: Giữ nguyên giao diện Web, chỉ can thiệp bấm Play video tự động theo yêu cầu cũ
    _controller.runJavaScript("""
      function playH5PVideo() {
          var h5pIframe = document.querySelector('.h5p-iframe');
          if (h5pIframe) {
              try {
                  var innerDoc = h5pIframe.contentDocument || h5pIframe.contentWindow.document;
                  if (innerDoc) {
                      var playBtn = innerDoc.querySelector('.h5p-play-button') 
                                 || innerDoc.querySelector('.h5p-video-play-button');
                      if (playBtn) playBtn.click();
                      
                      var video = innerDoc.querySelector('video');
                      if (video) video.play();
                  }
              } catch (e) {
                  // Lỗi Cross-Origin hoặc Iframe chưa tải xong
              }
          }
          setTimeout(playH5PVideo, 2000);
      }
      playH5PVideo();
    """);
  }

  @override
  Widget build(BuildContext context) {
    // Tự động kiểm tra: Nếu quay ngang thiết bị -> Tắt thanh thông báo (Fulllscreen Phone)
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    if (isLandscape) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: isLandscape
          ? null // Ẩn thanh AppBar nếu người dùng xoay ngang điện thoại để xem web full màn
          : AppBar(
              backgroundColor: Colors.white,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.black),
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
      body: SafeArea(
        top: !isLandscape,
        bottom: false,
        child: Stack(
          children: [
            if (_isControllerInitialized)
              WebViewWidget(controller: _controller)
            else
              const SizedBox.shrink(),

            if (_isLoading || !_isControllerInitialized)
              const Center(
                child: CircularProgressIndicator(),
              ),

            // Thêm một nút nổi Quay Lại "Mờ" nếu người dùng bị kẹt ở chế độ màn hình ngang (không có AppBar)
            if (isLandscape)
              Positioned(
                top: 16,
                left: 16,
                child: Container(
                  decoration: const BoxDecoration(
                    color: Colors.black38,
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
