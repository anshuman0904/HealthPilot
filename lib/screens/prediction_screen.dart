import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import '../services/disease_predictor.dart';
import '../utils/constants.dart';
import 'result_screen.dart';

class PredictionScreen extends StatefulWidget {
  const PredictionScreen({Key? key}) : super(key: key);

  @override
  State<PredictionScreen> createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  final TextEditingController _symptomsController = TextEditingController();
  final DiseasePredictor _predictor = DiseasePredictor();
  bool _isLoading = true;
  bool _isPredicting = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      await _predictor.loadModel();
      setState(() => _isLoading = false);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage =
            'Failed to load prediction model. Please restart the app.';
      });
    }
  }

  Future<void> _predictDisease() async {
    String symptoms = _symptomsController.text.trim();
    if (symptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter your symptoms'),
            backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => _isPredicting = true);

    try {
      final result = await _predictor.predictDisease(symptoms);
      final additionalDetails =
          await _predictor.getAdditionalDetails(result['disease'], symptoms);
      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ResultScreen(
            result: result,
            symptoms: symptoms,
            recommendations: additionalDetails,
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _isPredicting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: kBackgroundColor,
        appBar: AppBar(
            title: const Text('Describe Your Symptoms'),
            backgroundColor: Colors.blue.shade50),
        body: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                Color.fromARGB(255, 216, 255, 254),
                const Color.fromARGB(255, 233, 246, 255),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: _isLoading
              ? const Center(
                  child: SpinKitDoubleBounce(color: kPrimaryColor, size: 50.0))
              : _errorMessage.isNotEmpty
                  ? _buildErrorMessage()
                  : _buildInputForm(),
        ));
  }

  Widget _buildErrorMessage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: LinearGradient(
          colors: [
            Color.fromARGB(255, 212, 255, 254),
            const Color.fromARGB(255, 224, 239, 255),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(kDefaultPadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 16),
              Text(_errorMessage,
                  style: const TextStyle(color: Colors.red),
                  textAlign: TextAlign.center),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputForm() {
    return Padding(
      padding: const EdgeInsets.all(kDefaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('Please describe your symptoms in detail:',
              style: kSubheadingTextStyle),
          const SizedBox(height: 12),
          Flexible(
            child: TextField(
              controller: _symptomsController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: const TextStyle(fontSize: 16),
              decoration: InputDecoration(
                hintText:
                    'Example: I have been experiencing fever, headache, and sore throat...',
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () => _symptomsController.clear(),
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _isPredicting ? null : _predictDisease,
            style: ElevatedButton.styleFrom(
              backgroundColor: kPrimaryColor,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: _isPredicting
                ? const SpinKitThreeBounce(color: Colors.white, size: 24)
                : const Text('Analyze Symptoms', style: kButtonTextStyle),
          ),
          const SizedBox(height: 16),
          const Text(
            'Note: This prediction is not a medical diagnosis. Always consult with a healthcare professional.',
            style: TextStyle(
                fontSize: 12,
                color: kLightTextColor,
                fontStyle: FontStyle.italic),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _predictor.dispose();
    super.dispose();
  }
}
