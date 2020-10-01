import 'dart:math';
import 'dart:typed_data';

import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:image_circles/models/database.dart';
import 'package:rxdart/rxdart.dart';

import 'circle.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  img.Image image;

  final _pointerEvent = PublishSubject<Offset>();
  Stream<Offset> get _pointerEventStream => _pointerEvent.stream;
  // String url = "https://source.unsplash.com/1024x1024/?colors,nature,scifi,water,fruit";
  Uint8List bytes;
  bool _showPicture = false;
  bool _circleShape = true;
  List<CircleModel> circles;
  int count = 3000;
  Database database;
  @override
  void initState() {
    super.initState();
    // rootBundle.load('assets/yiyliyo.png').then((value) {
    FirebaseDatabase.instance.reference().child('data').once().then((value) {
      database = Database.fromJson(value.value);

      circles = [];
      _downloadImage(database.logos.levels[Random().nextInt(2)].questions[0].url).then((value) {
        bytes = value.buffer.asUint8List();
        image = img.decodeImage(bytes);
        print(image);
        circles.add(CircleModel(
          x: image.width / 2,
          y: image.height / 2,
          size: image.width.toDouble(),
        ));
        setState(() {});
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.black,
        body: Column(
          children: <Widget>[
            Spacer(),
            if (image != null)
              Stack(
                children: <Widget>[
                  Listener(
                      child: Opacity(
                    opacity: _showPicture ? 1 : 0,
                    child: Image.memory(bytes),
                  )),
                  Positioned.fill(
                    child: GestureDetector(
                      onPanUpdate: (e) {
                        var ratio = image.width / MediaQuery.of(context).size.width;
                        if (count > 0) {
                          count--;
                          _pointerEvent.add(e.localPosition * ratio);
                        }
                      },
                      child: Circle(image,
                          shape: _circleShape,
                          pointerStream: _pointerEventStream,
                          power: 2,
                          recurse: true,
                          size: image.width.toDouble()),
                    ),
                  ),
                ],
              )
            else
              CircularProgressIndicator(),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                      icon: Icon(Icons.refresh),
                      color: Colors.blue,
                      onPressed: () {
                        Navigator.of(context).pushReplacement(
                          MaterialPageRoute(
                            builder: (e) => MyHomePage(),
                          ),
                        );
                      }),
                  IconButton(
                      icon: Icon(_circleShape ? Icons.radio_button_unchecked : Icons.crop_16_9),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          _circleShape = !_circleShape;
                        });
                      }),
                  IconButton(
                      icon: Icon(_showPicture ? Icons.image : Icons.not_interested),
                      color: Colors.blue,
                      onPressed: () {
                        setState(() {
                          _showPicture = !_showPicture;
                        });
                      })
                ],
              ),
            ),
            StreamBuilder<Object>(
                stream: _pointerEventStream,
                builder: (context, snapshot) {
                  return Text("$count", style: TextStyle(color: Colors.white, fontSize: 30));
                }),
          ],
        ));
  }

  Future<Uint8List> _downloadImage(String url) async {
    http.Response response = await http.get(url);
    return response.bodyBytes;
  }
}

class CircleModel {
  double x;
  double y;
  double size;
  CircleModel({this.x, this.y, this.size});
}
