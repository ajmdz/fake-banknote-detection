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
  late IconData icon;
  late Color iconColor;
  late String message = "";
  late double confidence;
  late String label;

  @override
  void initState() {
    super.initState();
    _receivedData = widget.data;
    updateResultDisplay();
  }

  void updateResultDisplay() {
    double confidenceThreshold = 50.0;
    if (_receivedData['label'].startsWith('fake')) {
      icon = Icons.error_outline;
      iconColor = Colors.red;
      label = 'FAKE';
    } else if (_receivedData['label'].startsWith('real')){
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      label = 'GENUINE';
    }
    if (_receivedData['confidence'] < confidenceThreshold) {
      icon = Icons.warning_amber_outlined;
      iconColor = Colors.yellow.shade400;
      message = 'Result may be inaccurate.\nTry a clearer image.';
    }
    confidence = _receivedData['confidence'];
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
              color: const Color(0xFF6A3AD0).withOpacity(.7),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 150,
                      color: iconColor,
                    ),
                    // const SizedBox(height: 10),
                    Text(
                      "${confidence.toStringAsFixed(0)}% ${label}", // ignore: unnecessary_brace_in_string_interps
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        fontSize: 55,
                      ),
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        fontSize: 25,
                      ),
                      maxLines: null,
                      softWrap: true,
                    ),
                  ],
                ),
              ),
            )
          ],
        )
      ),
    );
  }
}