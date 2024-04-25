// https://github.com/Andrushka1012/rock_paper_scissors/blob/f786c7b8cadf73cf5893ce180776f13ea1e3843e/rock_paper_scissors_mobile/lib/clasifier.dart

import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image/image.dart' as img;
import 'package:counterfeat/classes.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:logger/logger.dart';

class Classifier {
  late Interpreter _interpreter;
  final Logger _logger = Logger(printer: SimplePrinter() ,output: null);

  static const String modelFile = "assets/mobnetV2(2).tflite";

  Future<void> loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFile,
            options: InterpreterOptions()..threads = 4,
          );

      _interpreter.allocateTensors();
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error while creating interpreter: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
        textColor: Colors.white
      );
    }
  }

  Interpreter get interpreter => _interpreter;

  Float32List imgToFloat32List(img.Image image) {
    Float32List convertedBytes = Float32List(1 * 300 * 400 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        img.Pixel pixel = image.getPixel(x, y);
        buffer[pixelIndex++] = pixel.r / 255.0;
        buffer[pixelIndex++] = pixel.g / 255.0; 
        buffer[pixelIndex++] = pixel.b / 255.0; 
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  Future<Map<String, dynamic>> predict(img.Image image) async {
    final resize = _measureExecutionTime(() {
      img.Image resizedImage = img.copyResize(image, width: 400, height: 300);
      return resizedImage;
    }, 'Resizing');

    final conversion = _measureExecutionTime(() {
      return imgToFloat32List(resize.result);
    }, 'Conversion');

    final input = conversion.result.reshape([1, 300, 400, 3]);
    _logger.i(input.join(' '));
    final output = Float32List(1 * 4).reshape([1, 4]);

    final inference = _measureExecutionTime(() {
      interpreter.run(input, output);
    }, 'Inference');

    _logger.i('Resizing took ${resize.time}ms to execute.');
    _logger.i('Conversion took ${conversion.time}ms to execute.');
    _logger.i('Inference took ${inference.time}ms to execute.');

    final predictionResult = output[0] as List<double>;
    double maxElement = predictionResult.reduce(
      (double maxElement, double element) =>
          element > maxElement ? element : maxElement,
    );
    return {
      'label': CategoricalClasses.values[predictionResult.indexOf(maxElement)].label,
      'confidence': maxElement
    };
  }

  ExecutionTimeResult<T> _measureExecutionTime<T>(T Function() action, String actionName) {
    final startTime = DateTime.now();
    final result = action();
    final endTime = DateTime.now();
    final duration = endTime.difference(startTime);
    return ExecutionTimeResult<T>(result, duration.inMilliseconds);
  }
}

class ExecutionTimeResult<T> {
  final T result;
  final int time;

  ExecutionTimeResult(this.result, this.time);
}