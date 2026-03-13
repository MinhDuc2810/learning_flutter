import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../constants/storage_key.dart';
import '../utils/local_storage.dart';
import '../utils/logger.dart';

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

  Future<void> _initController() async {
    try {
      String? token = await LocalStorage.getString(StorageKey.token);
      String finalUrl = widget.url;

      if (token != null && token.isNotEmpty) {
        if (finalUrl.contains('?')) {
          finalUrl = '$finalUrl&wstoken=$token';
        } else {
          finalUrl = '$finalUrl?wstoken=$token';
        }
      }

      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
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
