import 'dart:convert';
import 'package:flutter/services.dart';

class ModelHelper {
  late Map<String, dynamic> tfidfVocab;
  late List<String> labels;
  bool _isInitialized = false;

  Future<void> loadFiles() async {
    if (_isInitialized) return;

    try {
      // Load TF-IDF vocabulary
      final String vocabString = await rootBundle.loadString('assets/tfidf_vocab.json');
      final dynamic vocabData = json.decode(vocabString);

      // Convert to the expected format
      tfidfVocab = {};
      if (vocabData is Map) {
        vocabData.forEach((key, value) {
          if (value is Map) {
            tfidfVocab[key] = value;
          } else {
            // Handle case where value might be just an index
            tfidfVocab[key] = {'index': value, 'idf': 1.0};
          }
        });
      }

      // Load disease labels
      final String labelsString = await rootBundle.loadString('assets/labels.json');
      labels = List<String>.from(json.decode(labelsString));

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
        final index = tfidfVocab[word]['index'] as int;
        final idfValue = tfidfVocab[word]['idf'] as double? ?? 1.0;

        if (index < vector.length) {
          vector[index] += 1.0 * idfValue; // TF * IDF
        }
      }
    }

    return vector;
  }
}
