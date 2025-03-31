import 'package:HealthPilot/screens/skin_prediction_result.dart';
import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'disease_prediction.dart';
import 'skin_prediction.dart';
import 'eye_prediction.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xFFE0F7FA),
              Color(0xFFB2EBF2),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(kDefaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                _buildLogo(),
                const SizedBox(height: 30),
                _buildTitle(),
                const SizedBox(height: 16),
                _buildDescription(),
                const SizedBox(height: 40),
                _buildPredictionSections(context),
                const Spacer(),
                _buildDisclaimer(),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: kPrimaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: kPrimaryColor.withOpacity(0.3),
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.medical_services_outlined,
          size: 50,
          color: Colors.white,
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'HealthPilot',
      style: TextStyle(
        fontSize: 36,
        fontWeight: FontWeight.bold,
        color: kPrimaryColor,
        letterSpacing: 1.2,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildDescription() {
    return const Text(
      'AI-powered disease prediction at your fingertips',
      style: TextStyle(
        fontSize: 16,
        color: kLightTextColor,
        fontWeight: FontWeight.w500,
      ),
      textAlign: TextAlign.center,
    );
  }

  Widget _buildPredictionSections(BuildContext context) {
    return Column(
      children: [
        _buildPredictionCard(
          context,
          'Predict by Symptoms',
          Icons.list_alt,
          'Analyze symptoms to identify possible conditions',
          Colors.blue.shade100,
          const DiseasePredictionScreen(),
        ),
        const SizedBox(height: 16),
        _buildPredictionCard(
          context,
          'Skin Disease Prediction',
          Icons.face,
          'Upload skin photos for AI analysis',
          Colors.green.shade100,
          const SkinPredictionScreen(),
        ),
        const SizedBox(height: 16),
        _buildPredictionCard(
          context,
          'Eye Disease Prediction',
          Icons.remove_red_eye,
          'Detect eye conditions with image analysis',
          Colors.purple.shade100,
          const EyePredictionScreen(),
        ),
      ],
    );
  }

  Widget _buildPredictionCard(BuildContext context, String title, IconData icon,
      String description, Color cardColor, Widget screen) {
    return Card(
      elevation: 8,
      shadowColor: kPrimaryColor.withOpacity(0.3),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: () => Navigator.push(
            context, MaterialPageRoute(builder: (context) => screen)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [
                cardColor.withValues(alpha: 0.8),
                cardColor.withValues(alpha: 0.2)
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.9),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: Colors.white, size: 30),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        description,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kPrimaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.arrow_forward,
                    color: kPrimaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDisclaimer() {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.8),
        borderRadius: BorderRadius.circular(10),
      ),
      child: const Text(
        'Disclaimer: This app is for informational purposes only and should not replace professional medical advice.',
        style: TextStyle(
          fontSize: 12,
          color: kLightTextColor,
          fontStyle: FontStyle.italic,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}
