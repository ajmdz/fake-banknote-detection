// import 'dart:html' as darthtml;
import 'dart:io';
// https://pub.dev/packages/permission_handler
import 'package:counterfeat/components/loading.dart';
import 'package:counterfeat/pages/result.dart';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:counterfeat/components/button_with_icon.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:counterfeat/classifier.dart';
import 'package:image/image.dart' as img;

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // File? _selectedFile;
  bool _inProcess = false;
  bool initialized = false;
  final classifier = Classifier();
  img.Image? inputImage;
  late Interpreter interpreter;
  
  
  @override
  void initState() {
    super.initState();
    initialize();
  }

  @override
  void dispose() {
    super.dispose();
    interpreter.close();
  }

  Future<void> initialize() async {
    await classifier.loadModel();

    setState(() {
      initialized = true;
    });
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
        aspectRatio: const CropAspectRatio(ratioX: 16, ratioY: 6.6),
        compressQuality: 100,
        // maxWidth: 400,
        // maxHeight: 300,
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
        final selectedFile = File(cropped.path);
        // final bytes = await selectedFile.readAsBytes();
        final decodedImage = await img.decodeJpgFile(cropped.path);

        // INFERENCE
        setState(() {
          _inProcess = true;
        });

        classifier.predict(decodedImage!).then((result) {
          setState(() {
            _inProcess = false;
          });
          navigateResult({
            'file': selectedFile,
            'label':  result['label'],
            'confidence': result['confidence'] * 100.0,
          });
        });



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
    final messenger = ScaffoldMessenger.of(context);
    return Scaffold(
      body: Stack(
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Image.asset(
                  "assets/logo.png",
                  width: 300,
                  height: 300,
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
                      onPressed: () async {
                        PermissionStatus status = await Permission.camera.request();
                        if (status == PermissionStatus.granted) {
                          getImage(ImageSource.camera);
                        } else if (status == PermissionStatus.denied) {
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Camera access is denied'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        } else if (status == PermissionStatus.limited){
                          debugPrint('Permission is limited');
                        } else if (status == PermissionStatus.restricted) {
                          debugPrint('Permission is Restricted');
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Allow app to use camera'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          debugPrint('Permission is Permanently Denied');
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Allow app to use camera'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        }
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
                      onPressed: () async {
                        PermissionStatus status = await Permission.storage.request();
                        if (status == PermissionStatus.granted) {
                          getImage(ImageSource.gallery);
                        } else if (status == PermissionStatus.denied) {
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Storage access is denied'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        } else if (status == PermissionStatus.limited){
                          debugPrint('Permission is limited');
                        } else if (status == PermissionStatus.restricted) {
                          debugPrint('Permission is Restricted');
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Allow app to access gallery'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        } else if (status == PermissionStatus.permanentlyDenied) {
                          debugPrint('Permission is Permanently Denied');
                          messenger.showSnackBar(SnackBar(
                            content: const Text('Allow app to use gallery'),
                            action: SnackBarAction(
                              label: 'Open app settings', 
                              onPressed: () {
                                openAppSettings();
                              } 
                            ),
                          ));
                        }
                      }
                  )
                ],
              )
            ],
          ),
          (_inProcess)
              ? const Loading() 
              : const Center()
        ],
    ));
  }
}
