import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {

  late TextEditingController sepalLengthController;
  late TextEditingController sepalWidthController;
  late TextEditingController petalLengthController;
  late TextEditingController petalWidthController;

  late String sepalLength;
  late String sepalWidth;
  late String petalLength;
  late String petalWidth;

  late String imageName;
  String result = 'all';  //  파일 이름..?, 이미지 이름 처음 들어올 때 어떤 것이 들어와야할지 몰라서 임의로 all이라고 해놓음.


@override
  void initState() {
    // TODO: implement initState
    super.initState();
    sepalLengthController = TextEditingController();
    sepalWidthController = TextEditingController();
    petalLengthController = TextEditingController();
    petalWidthController = TextEditingController();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
          FocusScope.of(context).unfocus();
        },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('IRIS 품종예측'),
        ),
        body: Center(
          child: Column(
            children: [
              TextField(
                controller: sepalLengthController,
                decoration: const InputDecoration(
                  labelText: 'Sepal Length'
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true), //소수점 키보드에 세팅
              ),
              TextField(
                controller: sepalWidthController,
                decoration: const InputDecoration(
                  labelText: 'Sepal Width'
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true), //소수점 키보드에 세팅
              ),
              TextField(
                controller: petalLengthController,
                decoration: const InputDecoration(
                  labelText: 'Petal Length'
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true), //소수점 키보드에 세팅
              ),
              TextField(
                controller: petalWidthController,
                decoration: const InputDecoration(
                  labelText: 'Petal Width'
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true), //소수점 키보드에 세팅
              ),
              const SizedBox(
                height: 30,
              ),
              ElevatedButton(
                onPressed: () {
                  //controller 이름이 길어서 짧은 이름 변수에 넣어줌 
                  sepalLength = sepalLengthController.text;
                  sepalWidth = sepalWidthController.text;
                  petalLength = petalLengthController.text;
                  petalWidth = sepalWidthController.text;
                  //버튼 누르면 실행할 함수
                  getJSONData();
                }, 
                child: const Text('입력')),
                CircleAvatar(
                  backgroundImage: AssetImage('images/$result.jpg'),
                  radius: 100,
                )
            ],
          ),
        ),
      ),
    );
  }
  //--------function------------

  getJSONData() async {
    var url = Uri.parse(
      //5000 : python 서버
      'http://localhost:5000/iris?sepalLength=$sepalLength&sepalWidth=$sepalWidth&petalLength=$petalLength&petalWidth=$petalWidth');
    var response = await http.get(url);
    setState(() {
      var dataConvertedJSON = json.decode(utf8.decode(response.bodyBytes));
      result = dataConvertedJSON['result'];   //jsp 안에 json key값이 result인 것을 확인할 수 있다.
    });
    _showDialog(context, result);
  }//getJSONData


  _showDialog(BuildContext context, String result){
    showDialog(
      context: context, 
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('품종 예측 결과'),
          content: Text('입력하신 품종은 $result 입니다.'),
          actions: [
            TextButton(
              onPressed: () {
                setState(() {
                  imageName = result;
                });
                Navigator.of(context).pop();
              }, 
              child: const Text('OK'))
          ],
        );
      },);
  }//_showDialog

}//END