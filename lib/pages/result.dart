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
  late String message;
  late double confidence;

  @override
  void initState() {
    super.initState();
    _receivedData = widget.data;
    updateResultDisplay();
  }

  void updateResultDisplay() {
    if (_receivedData['label'].startsWith('fake')) {
      icon = Icons.error_outline;
      iconColor = Colors.red;
      // message = "COUNTERFEIT";
      message = _receivedData['label'];
    } else if (_receivedData['label'].startsWith('real')){
      icon = Icons.check_circle_outline;
      iconColor = Colors.green;
      // message = "GENUINE";
      message = _receivedData['label'];
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
                    // const SizedBox(height: 10),
                    Text(
                      "${confidence.toStringAsFixed(0)}%",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 70,
                        fontWeight: FontWeight.w900
                      )
                    ),
                    Text(
                      message,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 45,
                        fontWeight: FontWeight.w900
                      ),
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