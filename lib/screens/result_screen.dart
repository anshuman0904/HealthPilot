import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String symptoms;
  final Map<String, dynamic> recommendations;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.symptoms,
    required this.recommendations,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String disease = result['disease'] ?? 'Unknown';
    final double confidence = result['confidence'] ?? 0.0;
    final List<Map<String, dynamic>> topPredictions =
        List<Map<String, dynamic>>.from(result['topPredictions'] ?? []);

    return Scaffold(
        appBar: AppBar(
            title: const Text('Prediction Results'),
            backgroundColor: const Color.fromARGB(255, 191, 228, 254)),
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 217, 239, 244),
                const Color.fromARGB(255, 230, 239, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildPredictionCard(disease, confidence),
                if (topPredictions.length > 1)
                  _buildOtherConditions(topPredictions),
                _buildSection(
                    'Your Symptoms', symptoms), // Single string section
                _buildListSection(
                  'Recommended Medicines',
                  recommendations['Medicines'] ??
                      ['No recommendations available'],
                ),
                _buildListSection(
                  'Precautions',
                  recommendations['Precautions'] ??
                      ['No precautions available'],
                ),
                _buildListSection(
                  'Diet Plan',
                  recommendations['Diet'] ?? ['No diet plan available'],
                ),
                _buildListSection(
                  'Workout Suggestions',
                  recommendations['Workout'] ??
                      ['No workout suggestions available'],
                ),
                _buildDisclaimer(),
                _buildActionButtons(context),
              ],
            ),
          ),
        ));
  }

  Widget _buildPredictionCard(String disease, double confidence) {
    return Card(
      elevation: 3,
      color: const Color.fromARGB(
          255, 250, 254, 255), // Set the background color to white
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            const Text(
              'Predicted Condition',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: kLightTextColor,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              disease,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: confidence,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation<Color>(
                  Color.lerp(Colors.red, Colors.green, confidence) ??
                      Colors.green),
            ),
            const SizedBox(height: 8),
            Text(
              'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
              style: const TextStyle(fontSize: 16, color: kLightTextColor),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOtherConditions(List<Map<String, dynamic>> predictions) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Other Possible Conditions', style: kSubheadingTextStyle),
        const SizedBox(height: 12),
        ...predictions.skip(1).map((prediction) => Card(
              elevation: 1.5,
              color: const Color.fromARGB(
                  255, 250, 254, 255), // Set the background color to white
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16)),
              child: ListTile(
                title: Text(prediction['disease'] ?? 'Unknown',
                    style: const TextStyle(fontWeight: FontWeight.w500)),
                trailing: Text(
                    '${(prediction['confidence'] * 100).toStringAsFixed(1)}%',
                    style: const TextStyle(color: kLightTextColor)),
              ),
            )),
      ],
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kSubheadingTextStyle),
        const SizedBox(height: 8),
        Card(
          elevation: 1.5,
          color: const Color.fromARGB(
              255, 250, 254, 255), // Set the background color to white

          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              content.isNotEmpty ? content : 'No information available.',
              style: const TextStyle(fontSize: 16, color: kTextColor),
            ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildListSection(String title, dynamic content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: kSubheadingTextStyle),
        const SizedBox(height: 8),
        Card(
          elevation: 1.5,
          color: const Color.fromARGB(
              255, 250, 254, 255), // Set the background color to white

          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: content is List && content.isNotEmpty
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: content
                        .map((item) => Text(
                              '• $item',
                              style: const TextStyle(
                                  fontSize: 16, color: kTextColor),
                            ))
                        .toList(),
                  )
                : Text(
                    'No information available.',
                    style: const TextStyle(fontSize: 16, color: kTextColor),
                  ),
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.amber[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber),
      ),
      child: Column(
        children: const [
          Icon(Icons.info_outline, color: Colors.amber, size: 24),
          SizedBox(height: 8),
          Text(
            'Medical Disclaimer',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 8),
          Text(
            'This prediction is based on the symptoms you provided and should not be considered as a professional medical diagnosis. Please consult with a healthcare professional for proper evaluation and treatment.',
            style: TextStyle(fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: kPrimaryColor),
            ),
            child:
                const Text('Try Again', style: TextStyle(color: kPrimaryColor)),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: ElevatedButton(
            onPressed: () =>
                Navigator.of(context).popUntil((route) => route.isFirst),
            style: ElevatedButton.styleFrom(backgroundColor: kPrimaryColor),
            child: const Text('Home',
                style: TextStyle(color: Color.fromARGB(255, 233, 239, 241))),
          ),
        ),
      ],
    );
  }
}
