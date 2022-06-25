import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share/share.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final GlobalKey _globalKey = GlobalKey();
  final TextEditingController _textController1 = TextEditingController();
  final TextEditingController _textController2 = TextEditingController();

  Future<void> _generateImage() async {
    final RenderBox box = context.findRenderObject() as RenderBox;
    RenderRepaintBoundary? boundary = _globalKey.currentContext!.findRenderObject() as RenderRepaintBoundary?;
    ui.Image image = await boundary!.toImage(pixelRatio: 3.0);
    final directory = (await getApplicationDocumentsDirectory()).path;
    ByteData? byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    Uint8List pngBytes = byteData!.buffer.asUint8List();

    List<String> imagePaths = [];
    File imgFile = File('$directory/screenshot.png');
    imagePaths.add(imgFile.path);
    imgFile.writeAsBytes(pngBytes).then((value) async {
      await Share.shareFiles(imagePaths,
          subject: 'Share',
          text: 'Check this Out!',
          sharePositionOrigin: box.localToGlobal(Offset.zero) & box.size);
    }).catchError((onError) {
      print(onError);
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    _textController1.text = "Text 1";
    _textController2.text = "Text 2";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Test')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(15.0),
        child: Center(
          child: Column(
            children: [
              Container(
                decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey)
                ),
                child: RepaintBoundary(
                  key: _globalKey,
                  child: Container(
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Stack(
                          children: [
                            Image.asset('assets/one_direction.jpg', height: 200.0, width: double.infinity, fit: BoxFit.cover),
                            SizedBox(
                              height: 200.0,
                              child: Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: const EdgeInsets.all(10.0),
                                  child: Text(_textController1.text, style: const TextStyle(color: Colors.white, fontSize: 18.0)),
                                )
                              ),
                            )
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Text(_textController2.text, style: const TextStyle(fontSize: 18.0)),
                        )
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30.0),
              TextFormField(
                controller: _textController1,
                onChanged: (v) => setState(() {}),
                decoration: const InputDecoration(label: Text('Text 1')),
              ),
              const SizedBox(height: 10.0),
              TextFormField(
                controller: _textController2,
                onChanged: (v) => setState(() {}),
                decoration: const InputDecoration(label: Text('Text 2')),
              ),
              const SizedBox(height: 30.0),
              ElevatedButton(
                onPressed: _generateImage,
                child: const Text('Save'),
                style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 40.0)),
              )
            ],
          ),
        ),
      ),
    );
  }
}