import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:counterfeat/components/button_with_icon.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  File? _selectedFile;
  bool _inProcess = false;

  Widget getImageWidget() {
    if (_selectedFile != null) {
      return Image.file(
        _selectedFile!, // null-aware operator to assert non-null before passing
        width: 360,
        height: 150,
        fit: BoxFit.cover,
      );
    } else {
      return Image.asset(
        "assets/placeholder.jpg",
        width: 360,
        height: 150,
        fit: BoxFit.cover,
      );
    }
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
        maxWidth: 2560,
        maxHeight: 1440,
        compressFormat: ImageCompressFormat.jpg,
        uiSettings: [
          AndroidUiSettings(
            toolbarColor: Colors.deepOrange,
            toolbarTitle: "Crop Image",
            statusBarColor: Colors.deepOrange.shade900,
            backgroundColor: Colors.white,
          )
        ],
      );

      if (cropped != null) {
        setState(() {
          _selectedFile = File(cropped.path);
          _inProcess = false;
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
