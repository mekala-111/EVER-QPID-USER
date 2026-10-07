import 'package:everqpidapp/config/config.dart';
import 'package:everqpidapp/Settings/utils/p_colors.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:everqpidapp/Settings/helper/app_logger.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreenState();
}

class _PrivacyPolicyScreenState extends State<PrivacyPolicyScreen> {
  WebViewController? _controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    initWebView();
  }

  @override
  void dispose() {
    _controller = null;
    super.dispose();
  }

  Future<void> initWebView() async {
    if (!mounted) return;
    final controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            if (mounted) {
              setState(() => isLoading = true);
            }
          },
          onPageFinished: (String url) {
            if (mounted) {
              setState(() => isLoading = false);
            }
          },
          onWebResourceError: (WebResourceError error) {
            AppLogger.d('WebView Error: ${error.description}');
          },
        ),
      )
      ..loadRequest(
        Uri.parse(AppConfig.privacyPolicyUrl),
      );

    if (mounted) {
      setState(() => _controller = controller);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: PColors.color000000,
        body: Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Row(
                  children: [
                    Icon(Icons.arrow_back,
                        size: 16, color: PColors.colorFFFFFF),
                    const SizedBox(width: 10),
                    Text(
                      "Go back",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: PColors.colorFFFFFF,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Stack(
                  children: [
                    if (_controller != null)
                      WebViewWidget(controller: _controller!)
                    else
                      const Center(child: CircularProgressIndicator()),
                    if (isLoading && _controller != null)
                      const Center(child: CircularProgressIndicator()),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
