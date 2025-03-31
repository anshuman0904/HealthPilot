import 'dart:convert';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:http/http.dart' as http;
import 'model_helper.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter/foundation.dart';

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
      var output =
          List<List<double>>.filled(1, List<double>.filled(outputSize, 0));

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
        int maxIdx = probabilities
            .indexOf(probabilities.reduce((a, b) => a > b ? a : b));
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

  Future<Map<String, dynamic>> getAdditionalDetails(
      String disease, String symptoms) async {
    const String apiKey = 'AIzaSyA4ZZBSycwHtvnHMviFXapRLTLg9sG4GyA';

    try {
      final model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
      final content = [
        Content.text("""
        You are a medical assistant. Provide structured information about "$disease" having symptoms "$symptoms".:

        "\n\nInclude:"
        "\n1. Recommended Medicine"
        "\n2. Precautions"
        "\n3. Diet plan"
        "\n4. Workout recommendations"
        "\n\nFormat output as:"
        "\nRecommended Medicine: [list]"
        "\nPrecautions: [list]"
        "\nDiet: [list]"
        "\nWorkout: [list]"
        1. output should be in the format of list of items in square brackets.
        2. in Recommended Medicine give name of medicines to be taken along with recommended schedule , like two times a day etc.
        3. Respond ONLY in this format with short sentences strictly without introductions and disclaimers.
        4. do not forget to add newline character '\n' at end of each list item except the last one , do not use comma to seperate list items.
      """)
      ];

      final response = await model.generateContent(content);

      debugPrint("✅ Raw Response from Gemini: ${response.text}",
          wrapWidth: 10000);

      if (response.text != null && response.text!.isNotEmpty) {
        // Parse the response into a structured map
        return _parseResponse(response.text!);
      } else {
        return {"error": "No recommendations available."};
      }
    } catch (e) {
      debugPrint("✅ Raw Response from Gemini: ${e.toString()}",
          wrapWidth: 10000);

      return {"error": "Network error: ${e.toString()}"};
    }
  }

  Map<String, dynamic> _parseResponse(String rawResponse) {
    final Map<String, dynamic> parsedResponse = {};

    // Extract sections using regular expressions
    final medicineMatch =
        RegExp(r'Recommended Medicine:\s*\[(.*?)\]', dotAll: true)
            .firstMatch(rawResponse);
    final precautionsMatch = RegExp(r'Precautions:\s*\[(.*?)\]', dotAll: true)
        .firstMatch(rawResponse);
    final dietMatch =
        RegExp(r'Diet:\s*\[(.*?)\]', dotAll: true).firstMatch(rawResponse);
    final workoutMatch =
        RegExp(r'Workout:\s*\[(.*?)\]', dotAll: true).firstMatch(rawResponse);

    // Split extracted sections into lists of items
    parsedResponse['Medicines'] = medicineMatch != null
        ? medicineMatch.group(1)?.split('\n').map((e) => e.trim()).toList()
        : ['No data available'];
    parsedResponse['Precautions'] = precautionsMatch != null
        ? precautionsMatch.group(1)?.split('\n').map((e) => e.trim()).toList()
        : ['No data available'];
    parsedResponse['Diet'] = dietMatch != null
        ? dietMatch.group(1)?.split('\n').map((e) => e.trim()).toList()
        : ['No data available'];
    parsedResponse['Workout'] = workoutMatch != null
        ? workoutMatch.group(1)?.split('\n').map((e) => e.trim()).toList()
        : ['No data available'];

    return parsedResponse;
  }

  void dispose() {
    if (_isModelLoaded) {
      _interpreter.close();
      _isModelLoaded = false;
    }
  }
}
