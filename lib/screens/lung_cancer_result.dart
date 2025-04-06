import 'package:flutter/material.dart';
import '../utils/constants.dart';

class LungCancerResultScreen extends StatelessWidget {
  final String prediction;
  final int age;
  final String gender;
  final Map<String, int> symptoms;

  const LungCancerResultScreen({
    Key? key,
    required this.prediction,
    required this.age,
    required this.gender,
    required this.symptoms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = prediction == 'YES';
    final int symptomsCount = symptoms.values.where((value) => value == 1).length;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Assessment Results',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.blue.shade50,
              Colors.white,
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildResultCard(isPositive),
                        const SizedBox(height: 24),
                        _buildPersonalInfoCard(),
                        const SizedBox(height: 24),
                        _buildRecommendationsCard(isPositive),
                        const SizedBox(height: 24),
                        _buildSymptomsReviewCard(),
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
                _buildDisclaimerAndActions(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultCard(bool isPositive) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isPositive
                ? [Colors.red.shade100, Colors.red.shade200]
                : [Colors.green.shade100, Colors.green.shade200],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPositive ? Icons.warning_rounded : Icons.check_circle_outline,
              size: 64,
              color: isPositive ? Colors.red.shade800 : Colors.green.shade800,
            ),
            const SizedBox(height: 16),
            Text(
              isPositive ? 'Elevated Risk Detected' : 'Low Risk Detected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.red.shade800 : Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPositive
                  ? 'Our assessment indicates you may have an elevated risk for lung cancer.'
                  : 'Our assessment indicates you currently have a lower risk for lung cancer.',
              style: TextStyle(
                fontSize: 16,
                color: isPositive ? Colors.red.shade900 : Colors.green.shade900,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPersonalInfoCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Assessment Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Divider(),
            const SizedBox(height: 8),
            _buildInfoRow('Age', '$age years'),
            const SizedBox(height: 8),
            _buildInfoRow('Gender', gender),
            const SizedBox(height: 8),
            _buildInfoRow(
                'Symptoms Reported',
                '${symptoms.values.where((v) => v == 2).length} out of ${symptoms.length}'
            ),
            const SizedBox(height: 8),
            _buildInfoRow('Assessment Date', _getCurrentDate()),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsCard(bool isPositive) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            ...isPositive
                ? _getPositiveRecommendations()
                : _getNegativeRecommendations(),
          ],
        ),
      ),
    );
  }

  List<Widget> _getPositiveRecommendations() {
    return [
      _buildRecommendationItem(
        Icons.local_hospital,
        'Consult a pulmonologist',
        'Schedule an appointment with a lung specialist for proper evaluation and diagnostic testing.',
      ),
      _buildRecommendationItem(
        Icons.medical_services,
        'Get a chest X-ray or CT scan',
        'Ask your doctor about appropriate imaging tests to check for abnormalities in your lungs.',
      ),
      _buildRecommendationItem(
        Icons.smoke_free,
        'Quit smoking immediately',
        'If you smoke, quitting is the most important step you can take to reduce your risk.',
      ),
      _buildRecommendationItem(
        Icons.air,
        'Avoid secondhand smoke',
        'Stay away from environments where others are smoking to protect your lungs.',
      ),
      _buildRecommendationItem(
        Icons.home,
        'Test your home for radon',
        'Radon is the second leading cause of lung cancer and can be present in homes without detection.',
      ),
    ];
  }

  List<Widget> _getNegativeRecommendations() {
    return [
      _buildRecommendationItem(
        Icons.smoke_free,
        'Stay tobacco-free',
        "If you don't smoke, don't start. If you do smoke, consider quitting to maintain your lower risk.",
      ),
      _buildRecommendationItem(
        Icons.air,
        'Maintain clean air quality',
        'Use air purifiers at home and avoid prolonged exposure to air pollution or irritants.',
      ),
      _buildRecommendationItem(
        Icons.fitness_center,
        'Exercise regularly',
        'Regular physical activity helps maintain healthy lung function and overall health.',
      ),
      _buildRecommendationItem(
        Icons.restaurant,
        'Eat a healthy diet',
        'A diet rich in fruits and vegetables may help reduce lung cancer risk.',
      ),
      _buildRecommendationItem(
        Icons.health_and_safety,
        'Regular check-ups',
        'Continue with regular health screenings, especially if you have a family history of lung cancer.',
      ),
    ];
  }

  Widget _buildRecommendationItem(IconData icon, String title, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: kPrimaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomsReviewCard() {
    final List<String> presentSymptoms = symptoms.entries
        .where((entry) => entry.value == 1)
        .map((entry) => entry.key.replaceAll('_', ' '))
        .toList();

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Symptoms Review',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: kPrimaryColor,
              ),
            ),
            const Divider(),
            const SizedBox(height: 12),
            presentSymptoms.isEmpty
                ? const Text(
              'No symptoms were reported.',
              style: TextStyle(
                fontSize: 15,
                fontStyle: FontStyle.italic,
                color: Colors.grey,
              ),
            )
                : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'You reported the following symptoms:',
                  style: TextStyle(
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 8),
                ...presentSymptoms.map((symptom) => Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.circle,
                        size: 8,
                        color: kPrimaryColor,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _capitalizeEachWord(symptom),
                        style: const TextStyle(
                          fontSize: 15,
                        ),
                      ),
                    ],
                  ),
                )),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDisclaimerAndActions(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: const Text(
            'DISCLAIMER: This assessment provides an estimate based on your reported symptoms and is not a medical diagnosis. Always consult with a healthcare professional for proper evaluation and advice.',
            style: TextStyle(
              fontSize: 12,
              fontStyle: FontStyle.italic,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                    side: const BorderSide(color: kPrimaryColor),
                  ),
                ),
                child: const Text('Return to Assessment'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: ElevatedButton(
                onPressed: () {
                  // Navigate to home or save results
                  Navigator.popUntil(context, (route) => route.isFirst);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Back to Home',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day}/${now.month}/${now.year}';
  }

  String _capitalizeEachWord(String text) {
    return text.split(' ').map((word) =>
    word.isNotEmpty ? '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}' : ''
    ).join(' ');
  }
}
