import 'package:flutter/material.dart';
import '../utils/constants.dart';

class ResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String symptoms;

  const ResultScreen({
    Key? key,
    required this.result,
    required this.symptoms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String disease = result['disease'] ?? 'Unknown';
    final double confidence = result['confidence'] ?? 0.0;
    final List<Map<String, dynamic>> topPredictions =
    List<Map<String, dynamic>>.from(result['topPredictions'] ?? []);

    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: AppBar(
        title: const Text('Prediction Results'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Main prediction result card
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Predicted Condition',
                      style: TextStyle(
                        fontSize: 18,
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
                      valueColor: const AlwaysStoppedAnimation<Color>(kPrimaryColor),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Confidence: ${(confidence * 100).toStringAsFixed(1)}%',
                      style: const TextStyle(
                        fontSize: 16,
                        color: kLightTextColor,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Other possible conditions
            if (topPredictions.length > 1) ...[
              const Text(
                'Other Possible Conditions',
                style: kSubheadingTextStyle,
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: topPredictions.length - 1, // Skip the first one as it's the main prediction
                itemBuilder: (context, index) {
                  final prediction = topPredictions[index + 1]; // Start from the second prediction
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text(
                        prediction['disease'] ?? 'Unknown',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                      trailing: Text(
                        '${(prediction['confidence'] * 100).toStringAsFixed(1)}%',
                        style: const TextStyle(color: kLightTextColor),
                      ),
                    ),
                  );
                },
              ),
            ],

            const SizedBox(height: 24),

            // Symptoms section
            const Text(
              'Your Symptoms',
              style: kSubheadingTextStyle,
            ),
            const SizedBox(height: 12),
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  symptoms,
                  style: const TextStyle(
                    fontSize: 16,
                    color: kTextColor,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Disclaimer
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber),
              ),
              child: Column(
                children: const [
                  Icon(
                    Icons.info_outline,
                    color: Colors.amber,
                    size: 24,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Medical Disclaimer',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'This prediction is based on the symptoms you provided and should not be considered as a professional medical diagnosis. Please consult with a healthcare professional for proper evaluation and treatment.',
                    style: TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: kPrimaryColor),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Try Again',
                      style: TextStyle(color: kPrimaryColor),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).popUntil((route) => route.isFirst);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Home',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
