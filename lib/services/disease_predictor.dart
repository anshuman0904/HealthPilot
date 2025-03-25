import 'package:tflite_flutter/tflite_flutter.dart';
import 'model_helper.dart';

class DiseasePredictor {
  late Interpreter _interpreter;
  final ModelHelper _modelHelper = ModelHelper();
  bool _isModelLoaded = false;

  Future<void> loadModel() async {
    if (_isModelLoaded) return;

    try {
      // Load the TFLite model
      _interpreter = await Interpreter.fromAsset('assets/text_model.tflite');

      // Load the helper files
      await _modelHelper.loadFiles();

      _isModelLoaded = true;
      print('Disease prediction model loaded successfully');
    } catch (e) {
      print('Failed to load model: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> predictDisease(String symptoms) async {
    if (!_isModelLoaded) {
      await loadModel();
    }

    try {
      // Vectorize the input text
      final inputVector = _modelHelper.vectorizeText(symptoms);

      // Prepare input tensor
      var input = [inputVector];

      // Get output tensor shape
      var outputShape = _interpreter.getOutputTensor(0).shape;
      var outputSize = outputShape[1]; // Number of classes

      // Prepare output container
      var output = List<List<double>>.filled(
          1,
          List<double>.filled(outputSize, 0)
      );

      // Run inference
      _interpreter.run(input, output);

      // Find the index with highest probability
      int maxIndex = 0;
      double maxValue = output[0][0];

      for (int i = 0; i < output[0].length; i++) {
        if (output[0][i] > maxValue) {
          maxValue = output[0][i];
          maxIndex = i;
        }
      }

      // Get top 3 predictions
      List<Map<String, dynamic>> topPredictions = [];
      List<double> probabilities = List<double>.from(output[0]);

      for (int i = 0; i < 3; i++) {
        int maxIdx = probabilities.indexOf(probabilities.reduce((a, b) => a > b ? a : b));
        double confidence = probabilities[maxIdx];
        if (maxIdx < _modelHelper.labels.length && confidence > 0) {
          topPredictions.add({
            'disease': _modelHelper.labels[maxIdx],
            'confidence': confidence,
          });
          probabilities[maxIdx] = -1; // Mark as processed
        }
      }

      // Return the predicted disease name and confidence
      return {
        'disease': _modelHelper.labels[maxIndex],
        'confidence': maxValue,
        'topPredictions': topPredictions,
      };
    } catch (e) {
      print('Error during prediction: $e');
      rethrow;
    }
  }

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
    }
  }
}
