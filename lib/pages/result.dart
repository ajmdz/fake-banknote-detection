import 'package:flutter/material.dart';

/// TODO: separate bottomsheets for positive and negative results
/// HomePage passes the data to ResultPage (inference, image)
/// ResultPage displays the image and modelbottomsheet
class ResultPage extends StatefulWidget {
  final Map<String, dynamic> data;

  const ResultPage({super.key, required this.data});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  late Map<String, dynamic> _receivedData;
  late bool isCounterfeit;
  late IconData icon;
  late Color iconColor;
  late String message;

  @override
  void initState() {
    super.initState();
    _receivedData = widget.data;
    isCounterfeit = _receivedData['isCounterfeit'];
    updateResultDisplay();
  }

  void updateResultDisplay() {
    if (_receivedData['isCounterfeit']) {
      icon = Icons.error_outline;
      iconColor = Colors.red;
      message = "LIKELY COUNTERFEIT";
    } else {
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      message = "LIKELY GENUINE";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: [
            Center(
              child: RotatedBox(
                quarterTurns: 1,
                child: Image.file(
                  _receivedData['file'],
                  fit: BoxFit.cover,
                ),
              )
            ),
            Container(
              color: Colors.indigo.shade800.withOpacity(0.5),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 150,
                      color: iconColor,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.w600
                      ),
                    )
                  ],
                ),
              ),
            )
          ],
        )
        // child: RotatedBox(
        //   quarterTurns: 1,
        //   child: Image.file(
        //       _receivedData['file'],
        //       fit: BoxFit.cover,
        //   )
        // )
      ),
    );
  }
}

// Future _displayBottomSheet(BuildContext context) {
  //   return showModalBottomSheet(
  //     context: context,
  //     builder: (context) => Container(
  //       height: 200,
  //       width: MediaQuery.of(context).size.width,
  //       child: Center(
  //         child: Text(
  //         "Hello",
  //         style: const TextStyle(
  //           fontSize: 24,
  //         ),
  //       )),
  //     ));
  // }