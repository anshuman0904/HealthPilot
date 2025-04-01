import 'dart:convert';
import 'package:flutter/services.dart';

class ModelHelper {
  late Map<String, int> tfidfVocab;  // Mapping words to indices
  late List<String> labels;
  bool _isInitialized = false;

  Future<void> loadFiles() async {
    if (_isInitialized) return;

    try {
      // Load TF-IDF vocabulary
      final String vocabString = await rootBundle.loadString('assets/tfidf_vocab.json');
      final dynamic vocabData = json.decode(vocabString);

      // Ensure vocabData is a Map of strings to integers (word -> index)
      if (vocabData is Map<String, dynamic>) {
        tfidfVocab = Map<String, int>.from(vocabData);
      } else {
        throw Exception("TF-IDF vocab data is not in expected format (Map).");
      }

      // Load disease labels
      final String labelsString = await rootBundle.loadString('assets/labels.json');
      final dynamic labelsData = json.decode(labelsString);

      // Ensure labelsData is a Map with integer keys (as strings) and string values
      if (labelsData is Map<String, dynamic>) {
        // Convert the map values to a list of strings
        labels = labelsData.values.cast<String>().toList();
      } else {
        throw Exception("Labels data is not in expected format (Map).");
      }

      _isInitialized = true;
    } catch (e) {
      print('Error loading model files: $e');
      rethrow;
    }
  }

  List<double> vectorizeText(String text) {
    if (!_isInitialized) {
      throw Exception('Model files not loaded. Call loadFiles() first.');
    }

    // Preprocess text (lowercase, remove punctuation)
    text = text.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '');
    final words = text.split(' ');

    // Create a vector of zeros with the same length as vocabulary
    final int vocabSize = tfidfVocab.length;
    final vector = List<double>.filled(vocabSize, 0.0);

    // Fill the vector based on words in the input text
    for (var word in words) {
      if (tfidfVocab.containsKey(word)) {
        final index = tfidfVocab[word]!;
        // Increment the value at the corresponding index
        if (index < vector.length) {
          vector[index] += 1.0;  // Simple count-based vectorization (TF)
        }
      }
    }

    return vector;
  }
}
