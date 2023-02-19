import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

class WebviewPage extends StatefulWidget {
  const WebviewPage({super.key});

  @override
  State<WebviewPage> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<WebviewPage> {

  late WebViewController _controller;
  late bool isLoading; //for indicator
  late String siteName; //sitename

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;
    siteName = "www.daum.net";
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('web'),
      ),
      body: 
      Stack(
        children: [
          WebView(
        initialUrl: 'about:blank',
        onWebViewCreated: (WebViewController webViewController) {
          _controller = webViewController;
          _loadHtmlFromAssets();
        },
      ),
        ],
      ),

    );
  }

  _loadHtmlFromAssets() async {
    String fileText = await rootBundle.loadString('asset/seoul_hos.html');
    _controller.loadUrl( Uri.dataFromString(
        fileText,
        mimeType: 'text/html',
        encoding: Encoding.getByName('utf-8')
    ).toString());
  }
}