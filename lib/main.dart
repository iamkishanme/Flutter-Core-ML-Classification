import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

void main() => runApp(MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _image;
  Map<String, dynamic> _prediction;

  static const platform = const MethodChannel('caxondeviceimageclassify');

  Future getPrediction() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    print(image.path);
    Map<String, dynamic> prediction;
    try {
      Object predictionObj =
          await platform.invokeMethod('classifyFromImagePath', image.path);
      prediction = Map<String, dynamic>.from(predictionObj);
      print(prediction);
      setState(() {
        _image = image;
        _prediction = prediction;
      });
    } on PlatformException catch (e) {
      print(e.toString());
      prediction = null;
    }
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        primarySwatch: Colors.indigo,
      ),
      home: Scaffold(
        appBar: AppBar(
          title: const Text('CAX - CoreML Image Classification'),
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: getPrediction,
          label: Text('Capture Image'),
          icon: Icon(Icons.camera_alt),
        ),
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Center(
              child: _image == null
                  ? Text(
                      'Please upload an image to classify the image',
                      style: TextStyle(fontSize: 20.0),
                    )
                  : Container(
                      height: 200.0,
                      width: 200.0,
                      decoration: new BoxDecoration(
                        image: DecorationImage(
                          image: new AssetImage(_image.path),
                          fit: BoxFit.fill,
                        ),
                      ),
                    ),
            ),
            SizedBox(
              height: 30.0,
            ),
            Center(
              child: _prediction != null
                  ? Text(
                      'Category: ' +
                          _prediction['category'] +
                          ' / Confidence: ' +
                          _prediction['confidence'],
                      style: TextStyle(
                          fontSize: 20.0, fontWeight: FontWeight.bold),
                    )
                  : null,
            )
          ],
        ),
      ),
    );
  }
}
