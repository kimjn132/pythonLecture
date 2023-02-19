import 'dart:async';
import 'dart:convert';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;

class Gps extends StatefulWidget {
  const Gps({super.key});

  @override
  State<Gps> createState() => _GpsState();
}

class _GpsState extends State<Gps> {
  late Completer<GoogleMapController> googleController = Completer();
  late GoogleMapController mapController;
  late CameraUpdate cameraUpdate;

  late bool serviceEnabled;
  late LocationPermission permission;

// python 에 넘겨주는 데이터 변수 이름
  late double latitude;
  late double longitude;
  String result = 'all';

  // 초기 카메라 위치
  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );


  // 지도 클릭 시 표시할 장소에 대한 마커 목록
  final List<Marker> markers = [];
  addMarker(cordinate) {
    int id = Random().nextInt(100);

    setState(() {
      markers
          .add(Marker(position: cordinate, markerId: MarkerId(id.toString())));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPS 위도 경도 받기'),
      ),
      body: 
      GoogleMap(
        mapType: MapType.normal,
        // myLocationButtonEnabled: true,
        initialCameraPosition: _kGooglePlex, // 초기 카메라 위치
        onMapCreated: (GoogleMapController controller) {
          // _controller.complete(controller);
          setState(() {
            mapController = controller;
          });
        },
        markers: markers.toSet(),

        // 클릭한 위치가 중앙에 표시
        onTap: (argument) {
          mapController.animateCamera(CameraUpdate.newLatLng(argument));
          addMarker(argument);
        },
      ),

      floatingActionButton: 
      Stack(
  children: <Widget>[
    Align(
      alignment: Alignment.bottomLeft,
      child: gps(),
    ),
    Align(
      alignment: Alignment.bottomRight,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          zoomin(),
          zoomout()
        ],
      )
    ),
  
  ],
)
      

    );
  }

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

  //-----widget for floating buttong---------

  Widget gps() {
    return // floatingActionButton을 누르게 되면 _goToTheLake 실행된다.
        FloatingActionButton(
      onPressed: () async {
        var gps = await getCurrentLocation();

        mapController.animateCamera(
          CameraUpdate.newLatLng(
            LatLng(gps.latitude, gps.longitude),
          ),
        );
        print("경도${gps.latitude}");
        print("위도${gps.longitude}");

        longitude = gps.longitude;
        latitude = gps.latitude;
        //버튼 누르면 실행할 함수
        getJSONData();

      },
      child: Icon(
        Icons.my_location,
        color: Colors.black,
      ),
      backgroundColor: Colors.white,
    );
  }// gps floating button

  Widget zoomout(){
    return FloatingActionButton(
          onPressed: () {
            mapController.animateCamera(CameraUpdate.zoomOut());
          },
          child: Icon(Icons.zoom_out),
        );
  }//zoomout

  Widget zoomin(){
    return FloatingActionButton(
          onPressed: () {
            mapController.animateCamera(CameraUpdate.zoomIn());
          },
          child: Icon(Icons.zoom_in),
        );
  }//zoomin

getJSONData() async {
    var url = Uri.parse(
      //5000 : python 서버
      'http://localhost:5000/gps?latitude=$latitude&longitude=$longitude');
    var response = await http.get(url);
    setState(() {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      result = dataConvertedJSON['result'];   //jsp 안에 json key값이 result인 것을 확인할 수 있다.
    });
    
  }//getJSONData



}//End
