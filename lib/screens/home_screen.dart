import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../screens/prediction_screen.dart';
import '../screens/skin_classification_screen.dart';
import '../screens/eye_classification_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 216, 255, 254),
              const Color.fromARGB(255, 233, 246, 255),
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
                // App Logo or Icon
                Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: kPrimaryColor,
                      borderRadius: BorderRadius.circular(50),
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
                ),
                const SizedBox(height: 30),
                // App Title
                const Text(
                  'AI Health Assistant',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kPrimaryColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                // App Description
                const Text(
                  'Choose a prediction method below',
                  style: TextStyle(
                    fontSize: 16,
                    color: kLightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 50),
                // Prediction Options
                _buildOptionButton(
                  context,
                  'Symptom-based Prediction',
                  Icons.text_fields,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const PredictionScreen())),
                ),
                const SizedBox(height: 20),
                _buildOptionButton(
                  context,
                  'Skin Disease Classification',
                  Icons.camera_alt,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const SkinClassificationScreen())),
                ),
                const SizedBox(height: 20),
                _buildOptionButton(
                  context,
                  'Eye Disease Classification',
                  Icons.remove_red_eye,
                      () => Navigator.push(context, MaterialPageRoute(builder: (context) => const EyeClassificationScreen())),
                ),
                const Spacer(),
                // Disclaimer
                const Text(
                  'Disclaimer: This app is for informational purposes only and should not replace professional medical advice.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kLightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionButton(BuildContext context, String title, IconData icon, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.white,
        foregroundColor: kPrimaryColor,
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15),
        ),
        elevation: 5,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24),
          const SizedBox(width: 10),
          Text(
            title,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
