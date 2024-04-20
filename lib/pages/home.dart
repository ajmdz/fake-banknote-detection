import 'dart:io';
import 'package:counterfeat/pages/result.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:counterfeat/components/button_with_icon.dart';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:fluttertoast/fluttertoast.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedFile;
  bool _inProcess = false;
  
  @override
  void initState() {
    super.initState();
    _tfliteInit();
  }

  @override
  void dispose() {
    super.dispose();
    Tflite.close();
  }

  Future<void> _tfliteInit() async {
    String? res = await Tflite.loadModel(
      model: "assets/model_unquant.tflite",
      labels: "assets/labels.txt",
      numThreads: 1, // defaults to 1
      isAsset: true, // defaults to true, set to false to load resources outside assets
      useGpuDelegate: false // defaults to false, set to true to use GPU delegate
    );
  }

  navigateResult(Map<String,dynamic> data) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ResultPage(data: data))
    );
  }

  getImage(ImageSource source) async {
    setState(() {
      _inProcess = true;
    });
    XFile? image = await ImagePicker().pickImage(source: source);
    if (image != null) {
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
        // aspectRatio: const CropAspectRatio(ratioX: 4, ratioY: 3),
        compressQuality: 100,
        // maxWidth: 2560,
        maxWidth: 1920,
        maxHeight: 1440,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.grey.shade300,
            toolbarTitle: "Crop Image",
            statusBarColor: Colors.grey.shade900,
            backgroundColor: Colors.white,
          )
        ],
      );

      if (cropped != null) {
        setState(() {
          _selectedFile = File(cropped.path);
          _inProcess = false;
        });

        // INFERENCE
        var result = await Tflite.runModelOnImage(
          path: image.path,
          imageMean: 0.0,
          imageStd: 255.0,
          numResults: 2,
          threshold: 0.2,
          asynch: true
        );

        if (result != null) {
          navigateResult({
            'file': _selectedFile,
            'label':  result[0]['label'].toString(),
            'confidence': result[0]['confidence'] * 100,
          });
        } else {
          Fluttertoast.showToast(
            msg: "Error: model output is null",
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            textColor: Colors.white
          );
        }

      } else {
        setState(() {
          _inProcess = false;
        });
      }
    } else {
      setState(() {
        _inProcess = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  "assets/logo.png",
                  width: 250,
                  height: 250,
                  fit: BoxFit.cover,
                ),
              ]),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("CounterFeat",
                    style: TextStyle(fontWeight: FontWeight.w600, fontSize: 40))
              ]),
              const Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Text("Fake Peso banknote detector",
                    style: TextStyle(fontWeight: FontWeight.w100, fontSize: 20))
              ]),
              const SizedBox(height: 50),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ButtonWithIcon(
                      icon: const Icon(Icons.photo_camera, color: Colors.white),
                      label: "Camera",
                      onPressed: () {
                        getImage(ImageSource.camera);
                      })
                ],
              ),
              const SizedBox(height: 30),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  ButtonWithIcon(
                      icon: const Icon(Icons.collections, color: Colors.white),
                      label: "Choose from Gallery",
                      onPressed: () {
                        getImage(ImageSource.gallery);
                      })
                ],
              )
            ],
          ),
          (_inProcess)
              ? Container(
                  color: Colors.white,
                  height: MediaQuery.of(context).size.height * 0.95,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
              : const Center()
        ],
    ));
  }
}
