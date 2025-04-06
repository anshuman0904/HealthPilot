import 'package:flutter/material.dart';
import '../utils/constants.dart';

class DiabetesResultScreen extends StatelessWidget {
  final String prediction;
  final int age;
  final String gender;
  final Map<String, int> symptoms;

  const DiabetesResultScreen({
    Key? key,
    required this.prediction,
    required this.age,
    required this.gender,
    required this.symptoms,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bool isPositive = prediction == 'Positive';
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
              Colors.orange.shade50,
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
                ? [Colors.orange.shade100, Colors.orange.shade200]
                : [Colors.green.shade100, Colors.green.shade200],
          ),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Icon(
              isPositive ? Icons.warning_rounded : Icons.check_circle_outline,
              size: 64,
              color: isPositive ? Colors.orange.shade800 : Colors.green.shade800,
            ),
            const SizedBox(height: 16),
            Text(
              isPositive ? 'Elevated Risk Detected' : 'Low Risk Detected',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isPositive ? Colors.orange.shade800 : Colors.green.shade800,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              isPositive
                  ? 'Our assessment indicates you may have an elevated risk for diabetes.'
                  : 'Our assessment indicates you currently have a lower risk for diabetes.',
              style: TextStyle(
                fontSize: 16,
                color: isPositive ? Colors.orange.shade900 : Colors.green.shade900,
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
                '${symptoms.values.where((v) => v == 1).length} out of ${symptoms.length}'
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
        'Consult a healthcare provider',
        'Schedule an appointment with your doctor for proper diagnosis and testing.',
      ),
      _buildRecommendationItem(
        Icons.science,
        'Get tested',
        'Ask your doctor about getting a fasting blood glucose test or an A1C test.',
      ),
      _buildRecommendationItem(
        Icons.restaurant,
        'Monitor your diet',
        'Reduce sugar and refined carbohydrate intake, focus on whole foods.',
      ),
      _buildRecommendationItem(
        Icons.directions_run,
        'Increase physical activity',
        'Aim for at least 150 minutes of moderate exercise per week.',
      ),
      _buildRecommendationItem(
        Icons.monitor_weight,
        'Maintain a healthy weight',
        'If overweight, even a 5-10% weight loss can significantly reduce diabetes risk.',
      ),
    ];
  }

  List<Widget> _getNegativeRecommendations() {
    return [
      _buildRecommendationItem(
        Icons.restaurant,
        'Maintain a healthy diet',
        'Continue eating a balanced diet rich in vegetables, fruits, and whole grains.',
      ),
      _buildRecommendationItem(
        Icons.directions_run,
        'Stay active',
        'Regular physical activity helps maintain insulin sensitivity.',
      ),
      _buildRecommendationItem(
        Icons.monitor_weight,
        'Maintain a healthy weight',
        'Keep your BMI within the recommended range for your height.',
      ),
      _buildRecommendationItem(
        Icons.medical_services,
        'Regular check-ups',
        'Continue with regular health screenings, especially if you have a family history of diabetes.',
      ),
      _buildRecommendationItem(
        Icons.smoke_free,
        'Avoid smoking',
        'Smoking increases the risk of diabetes and its complications.',
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
