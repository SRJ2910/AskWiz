import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dio/dio.dart';
import 'package:dopanet/page/info.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:image_picker/image_picker.dart';

class home extends StatefulWidget {
  home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {
  File? image;
  String extractedText = "";
  final _textController = TextEditingController();
  List<String> result = [];

  Future pickImage_gallery() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.gallery);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      extractText();
    } on PlatformException catch (e) {
      print('Failed to pick image: $e');
    }
  }

  Future pickImage_camera() async {
    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);
      if (image == null) return;
      final imageTemp = File(image.path);
      setState(() => this.image = imageTemp);
      extractText();
    } on PlatformException catch (e) {
      print('Failed to open camera: $e');
    }
  }

  extractText() async {
    final inputImage = InputImage.fromFilePath(image!.path);
    final textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);

    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = recognizedText.text;
    setState(() {
      extractedText = text;
    });
    print(text);
  }

  /// get link from firebase -> ngrok link
  Future<String> getLink() async {
    String link = "";
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    link = await firestore
        .collection("id")
        .get()
        .then((value) => value.docs[0]["link"]);

    return link;
  }

  /// Extract data from server Roberta model
  Future<List<String>> extractDatafromserver(
      String context, String question) async {
    final dio = Dio();

    String link = await getLink();
    print(link);

    final response = await dio.post(link + "/predict",
        data: {"context": context, "question": question});

    print('predt: ${response.data["prediction"]}');
    print('score: ${response.data["score"]}');
    return [response.data["prediction"], response.data["score"].toString()];
  }

  dialog() {
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Choose an option"),
          actions: [
            SimpleDialogOption(
              onPressed: () {
                pickImage_camera();
                Navigator.pop(context, true);
              },
              child: Row(
                children: const [
                  Icon(Icons.camera),
                  SizedBox(width: 5.0),
                  Text('Camera'),
                ],
              ),
            ),
            SizedBox(height: 10.0),
            SimpleDialogOption(
              onPressed: () {
                pickImage_gallery();
                Navigator.pop(context, true);
              },
              child: Row(
                children: [
                  Icon(Icons.file_open),
                  SizedBox(width: 5.0),
                  Text('Choose from gallery'),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  loadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        // return object of type Dialog
        return Dialog(
          elevation: 0.0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Container(
            height: 150.0,
            padding: EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                CircularProgressIndicator(),
                Text('Please wait...'),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text("AskWiz"),
          actions: [
            IconButton(
                onPressed: () {
                  dialog();
                },
                icon: Icon(Icons.add_a_photo_outlined)),
            IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => info()),
                  );
                },
                icon: Icon(Icons.info_outline)),
          ],
        ),
        body: Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Container(
                        height: 300,
                        width: MediaQuery.of(context).size.width,
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.black45),
                        ),
                        child: image == null
                            ? Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  IconButton(
                                      onPressed: () {
                                        dialog();
                                      },
                                      icon: Icon(Icons.camera_enhance_rounded)),
                                  Text("Add Image"),
                                ],
                              )
                            : Image.file(image!)),
                  ),
                  SizedBox(height: 20.0),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10.0),
                    child: Column(
                      children: [
                        TextField(
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Question',
                          ),
                          controller: _textController,
                        ),
                        SizedBox(height: 20.0),
                        Container(
                          height: 100,
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.black45),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Text(
                                result.isEmpty ? "Answer" : "${result[0]}"),
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 20.0),
                  ElevatedButton(
                      onPressed: () async {
                        loadingDialog();
                        List<String> temp_res = await extractDatafromserver(
                            extractedText, _textController.text);
                        Navigator.pop(context, true);
                        setState(() {
                          result = temp_res;
                        });
                      },
                      child: Text("Submit")),
                ],
              ),
            ),
          ),
        ));
  }
}
