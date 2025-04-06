import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'diabetes_result.dart';

class DiabetesRiskAssessmentScreen extends StatefulWidget {
  const DiabetesRiskAssessmentScreen({Key? key}) : super(key: key);

  @override
  _DiabetesRiskAssessmentScreenState createState() =>
      _DiabetesRiskAssessmentScreenState();
}

class _DiabetesRiskAssessmentScreenState
    extends State<DiabetesRiskAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _baseUrl;

  // Form values
  int _age = 25;
  int _gender = 1; // 1 for Male, 0 for Female
  final Map<String, int> _symptoms = {
    'Polyuria': 0, // Excessive urination
    'Polydipsia': 0, // Excessive thirst
    'Sudden_weight_loss': 0,
    'Weakness': 0,
    'Polyphagia': 0, // Excessive hunger
    'Genital_thrush': 0, // Yeast infection
    'Visual_blurring': 0,
    'Itching': 0,
    'Irritability': 0,
    'Delayed_healing': 0,
    'Partial_paresis': 0, // Partial weakness
    'Muscle_stiffness': 0,
    'Alopecia': 0, // Hair loss
    'Obesity': 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchBaseUrl();
  }

  Future<void> _fetchBaseUrl() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse("https://anshumansinha.pythonanywhere.com/fetch"));

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        print("URL: ${data["stored_string"]}");
        setState(() {
          _baseUrl = data["stored_string"];
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load base URL');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        if (_baseUrl == null) {
          throw Exception('Base URL not loaded');
        }

        final Map<String, String> formData = {
          'Age': _age.toString(),
          'Gender': _gender.toString(),
        };

        // Add all symptoms to form data
        _symptoms.forEach((key, value) {
          formData[key] = value.toString();
        });

        final response = await http.post(
          Uri.parse('$_baseUrl/predict_diabetes'),
          body: formData,
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);

          // Navigate to result screen with the prediction
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DiabetesResultScreen(
                prediction: result['prediction'],
                age: _age,
                gender: _gender == 1 ? 'Male' : 'Female',
                symptoms: _symptoms,
              ),
            ),
          );
        } else {
          throw Exception('Failed to submit form');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Widget _buildSymptomTile(String title, String description) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title.replaceAll('_', ' '),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: kPrimaryColor,
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
                Switch(
                  value: _symptoms[title] == 1,
                  activeColor: kPrimaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      _symptoms[title] = value ? 1 : 0;
                    });
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getSymptomDescription(String symptom) {
    final Map<String, String> descriptions = {
      'Polyuria': 'Excessive or frequent urination',
      'Polydipsia': 'Excessive thirst or drinking a lot of fluids',
      'Sudden_weight_loss': 'Unexplained weight loss in a short period',
      'Weakness': 'General feeling of tiredness or lack of energy',
      'Polyphagia': 'Excessive hunger or increased appetite',
      'Genital_thrush': 'Yeast infection in genital area',
      'Visual_blurring': 'Blurred vision or difficulty focusing',
      'Itching': 'Persistent itching on skin or genital area',
      'Irritability': 'Being easily annoyed or agitated',
      'Delayed_healing': 'Wounds or cuts take longer to heal',
      'Partial_paresis': 'Partial weakness or mild paralysis',
      'Muscle_stiffness': 'Rigid or inflexible muscles',
      'Alopecia': 'Hair loss or thinning of hair',
      'Obesity': 'Being significantly overweight (BMI > 30)',
    };

    return descriptions[symptom] ?? 'Do you experience this symptom?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Diabetes Risk Assessment',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: kPrimaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(kPrimaryColor),
        ),
      )
          : Container(
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
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Personal Information',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Age Slider
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Age',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        '$_age years',
                                        style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Slider(
                                    value: _age.toDouble(),
                                    min: 18,
                                    max: 100,
                                    divisions: 82,
                                    activeColor: kPrimaryColor,
                                    inactiveColor: Colors.orange.shade100,
                                    label: _age.toString(),
                                    onChanged: (double value) {
                                      setState(() {
                                        _age = value.round();
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ),
                          ),

                          const SizedBox(height: 16),

                          // Gender Selection
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Gender',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: kPrimaryColor,
                                    ),
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _gender = 1; // Male
                                            });
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: _gender == 1
                                                  ? Colors.blue.shade100
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _gender == 1
                                                    ? Colors.blue.shade400
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              boxShadow: _gender == 1
                                                  ? [
                                                BoxShadow(
                                                  color: Colors.blue.shade200.withOpacity(0.5),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                )
                                              ]
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.male,
                                                  color: _gender == 1
                                                      ? Colors.blue.shade700
                                                      : Colors.grey.shade600,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Male',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: _gender == 1
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: _gender == 1
                                                        ? Colors.blue.shade700
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _gender = 0; // Female
                                            });
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: _gender == 0
                                                  ? Colors.pink.shade100
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _gender == 0
                                                    ? Colors.pink.shade400
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              boxShadow: _gender == 0
                                                  ? [
                                                BoxShadow(
                                                  color: Colors.pink.shade200.withOpacity(0.5),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 3),
                                                )
                                              ]
                                                  : null,
                                            ),
                                            child: Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Icon(
                                                  Icons.female,
                                                  color: _gender == 0
                                                      ? Colors.pink.shade700
                                                      : Colors.grey.shade600,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Female',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: _gender == 0
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: _gender == 0
                                                        ? Colors.pink.shade700
                                                        : Colors.grey.shade600,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          const Text(
                            'Symptoms',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please indicate if you experience any of the following symptoms:',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                          const SizedBox(height: 16),

                          // Symptoms List
                          ..._symptoms.keys.map((symptom) {
                            return _buildSymptomTile(
                              symptom,
                              _getSymptomDescription(symptom),
                            );
                          }).toList(),

                          const SizedBox(height: 24),
                        ],
                      ),
                    ),
                  ),

                  // Submit Button
                  ElevatedButton(
                    onPressed: _isLoading ? null : _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        strokeWidth: 2,
                      ),
                    )
                        : const Text(
                      'Assess My Risk',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Disclaimer
                  const Text(
                    'Disclaimer: This assessment is for informational purposes only and should not replace professional medical advice.',
                    style: TextStyle(
                      fontSize: 12,
                      fontStyle: FontStyle.italic,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}