import 'package:flutter/material.dart';
import '../utils/constants.dart';
import 'prediction_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // App Logo or Icon
              Center(
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: kPrimaryColor,
                    borderRadius: BorderRadius.circular(60),
                  ),
                  child: const Icon(
                    Icons.medical_services_outlined,
                    size: 60,
                    color: Colors.white,
                  ),
                ),
              ),
              const SizedBox(height: 40),
              // App Title
              const Text(
                'Disease Prediction',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: kPrimaryColor,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              // App Description
              const Text(
                'Predict possible diseases based on your symptoms using AI technology',
                style: TextStyle(
                  fontSize: 16,
                  color: kLightTextColor,
                ),
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              // Get Started Button
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const PredictionScreen(),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: kPrimaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: kButtonTextStyle,
                ),
              ),
              const SizedBox(height: 20),
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
    );
  }
}
