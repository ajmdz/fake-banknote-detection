// https://github.com/Andrushka1012/rock_paper_scissors/blob/f786c7b8cadf73cf5893ce180776f13ea1e3843e/rock_paper_scissors_mobile/lib/clasifier.dart

import 'dart:typed_data';

import 'package:image/image.dart' as img;
import 'package:counterfeat/classes.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class Classifier {
  /// Instance of Interpreter
  late Interpreter _interpreter;

  static const String modelFile = "assets/model_vgg16.tflite";

  /// Loads interpreter from asset
  Future<void> loadModel({Interpreter? interpreter}) async {
    try {
      _interpreter = interpreter ??
          await Interpreter.fromAsset(
            modelFile,
            options: InterpreterOptions()..threads = 4,
          );

      _interpreter.allocateTensors();
    } catch (e) {
      print("Error while creating interpreter: $e");
    }
  }

  /// Gets the interpreter instance
  Interpreter get interpreter => _interpreter;

  Future<Map<String, dynamic>> predict(img.Image image) async {
    img.Image resizedImage = img.copyResize(image, width: 400, height: 300);

    // Convert the resized image to a 1D Float32List.
    Float32List inputBytes = Float32List(1 * 300 * 400 * 3);
    int pixelIndex = 0;
    for (int y = 0; y < resizedImage.height; y++) {
      for (int x = 0; x < resizedImage.width; x++) {
        img.Pixel pixel = resizedImage.getPixel(x, y);
        inputBytes[pixelIndex++] = pixel.r * 1.0;
        inputBytes[pixelIndex++] = pixel.g * 1.0; 
        inputBytes[pixelIndex++] = pixel.b * 1.0; 
      }
    }

    final output = Float32List(1 * 4).reshape([1, 4]);

    // Reshape to input format specific for model. 1 item in list with pixels 400x300 and 3 layers for RGB
    final input = inputBytes.reshape([1, 300, 400, 3]);

    interpreter.run(input, output);

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
}