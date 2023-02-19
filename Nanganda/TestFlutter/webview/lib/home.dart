import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher_string.dart';
import 'package:webview_flutter/webview_flutter.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late bool isLoading; //for indicator

  late CameraUpdate cameraUpdate;

  late bool serviceEnabled;
  late LocationPermission permission;

// python 에 넘겨주는 데이터 변수 이름
  late double latitude;
  late double longitude;
  String result = 'all';

  //late Future<String> _htmlContent;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    isLoading = true;

    latitude = 0;
    longitude = 0;

    //String _htmlContent = '<html><body><a href="tel:1234567890">Call me</a></body></html>';
    _loadHtmlFromUrl();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 100,
          title: Center(
            child: Column(children: [
              const Text(
                "WebView",
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(padding: const EdgeInsets.all(8.0), child: gpsbtn()),
                ],
              ),
            ]),
          ),
        ),
        body: Stack(
          children: [
            WebView(
              initialUrl: '',
              navigationDelegate: (NavigationRequest request) {
                print('Request: ${request.url}');
                if (request.url.startsWith('tel:')) {
                  print('Opening phone dialer');
                  launchUrlString(request.url);
                  SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                  return NavigationDecision.prevent;
                }
                print('Loading page');
                return NavigationDecision.navigate;
              },
              javascriptMode: JavascriptMode.unrestricted,
           
              onWebViewCreated: (WebViewController webViewController) async {
                String fileHtml =
                    await rootBundle.loadString('datafiles/seoul_hos.html');
                webViewController.loadUrl(Uri.dataFromString(fileHtml,
                        mimeType: 'text/html',
                        encoding: Encoding.getByName('utf-8'))
                    .toString());
              },
            )
          ],
        ));
  }

// for GPS
  Future<Position> getCurrentLocation() async {
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);

    return position;
  } //getCurrentLocation

//gps
  Widget gpsbtn() {
    return ElevatedButton(
        onPressed: () async {
          var gps = await getCurrentLocation();

          latitude = gps.latitude;
          longitude = gps.longitude;

          await _loadHtmlFromUrl();
        },
        child: const Text('주소찾기'));
  } // gps기반 위치 확인 후 위치 기준 지도에 산부인과 마커 표시 button

  _loadHtmlFromUrl() async {
    var url = Uri.parse(
        'http://172.20.10.5:5000/vieweb?latitude=$latitude&longitude=$longitude');

    await http.get(url);
    // setState(() {
    //  _htmlContent = Future.value(response.body);

    // });
  } //route
} // end
