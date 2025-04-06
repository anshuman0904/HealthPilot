import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../utils/constants.dart';
import 'lung_cancer_result.dart';

class LungCancerRiskAssessmentScreen extends StatefulWidget {
  const LungCancerRiskAssessmentScreen({Key? key}) : super(key: key);

  @override
  _LungCancerRiskAssessmentScreenState createState() =>
      _LungCancerRiskAssessmentScreenState();
}

class _LungCancerRiskAssessmentScreenState
    extends State<LungCancerRiskAssessmentScreen> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  String? _baseUrl;

  // Form values
  int _age = 25;
  int _gender = 0; // 0 for Male, 1 for Female (inverted)
  final Map<String, int> _symptoms = {
    'smoking': 1,
    'yellow_fingers': 1,
    'anxiety': 1,
    'peer_pressure': 1,
    'chronic_disease': 1,
    'fatigue': 1,
    'allergy': 1,
    'wheezing': 1,
    'alcohol_consuming': 1,
    'coughing': 1,
    'shortness_of_breath': 1,
    'swallowing_difficulty': 1,
    'chest_pain': 1,
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

        final Map<String, dynamic> formData = {
          'age': _age,
          'gender': _gender,
        };

        // Add all symptoms to form data
        _symptoms.forEach((key, value) {
          formData[key] = value;
        });

        final response = await http.post(
          Uri.parse('$_baseUrl/predict_lungs'),
          headers: {'Content-Type': 'application/json'},
          body: json.encode(formData),
        );

        if (response.statusCode == 200) {
          final result = json.decode(response.body);

          // Navigate to result screen with the prediction
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LungCancerResultScreen(
                prediction: result['prediction'],
                age: _age,
                gender: _gender == 0 ? 'Male' : 'Female',
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
                  value: _symptoms[title] == 2,
                  activeColor: kPrimaryColor,
                  onChanged: (bool value) {
                    setState(() {
                      _symptoms[title] = value ? 2 : 1;
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
      'smoking': 'Current or past smoking habit',
      'yellow_fingers': 'Discoloration of fingers due to smoking',
      'anxiety': 'Feeling of worry, nervousness, or unease',
      'peer_pressure': 'Influence from peers to smoke or use substances',
      'chronic_disease': 'Long-term health condition',
      'fatigue': 'Extreme tiredness or lack of energy',
      'allergy': 'Allergic reactions to substances',
      'wheezing': 'Breathing with a whistling or rattling sound',
      'alcohol_consuming': 'Regular consumption of alcoholic beverages',
      'coughing': 'Persistent or frequent coughing',
      'shortness_of_breath': 'Difficulty breathing or feeling breathless',
      'swallowing_difficulty': 'Problems or pain when swallowing',
      'chest_pain': 'Pain or discomfort in the chest area',
    };

    return descriptions[symptom] ?? 'Do you experience this symptom?';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Lung Cancer Risk Assessment',
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
              Colors.blue.shade50,
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
                                    inactiveColor: Colors.blue.shade100,
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
                                              _gender = 0; // Male (inverted)
                                            });
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: _gender == 0
                                                  ? Colors.blue.shade100
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _gender == 0
                                                    ? Colors.blue.shade400
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              boxShadow: _gender == 0
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
                                                  color: _gender == 0
                                                      ? Colors.blue.shade700
                                                      : Colors.grey.shade600,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Male',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: _gender == 0
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: _gender == 0
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
                                              _gender = 1; // Female (inverted)
                                            });
                                          },
                                          child: Container(
                                            height: 60,
                                            decoration: BoxDecoration(
                                              color: _gender == 1
                                                  ? Colors.pink.shade100
                                                  : Colors.grey.shade100,
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: _gender == 1
                                                    ? Colors.pink.shade400
                                                    : Colors.grey.shade300,
                                                width: 2,
                                              ),
                                              boxShadow: _gender == 1
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
                                                  color: _gender == 1
                                                      ? Colors.pink.shade700
                                                      : Colors.grey.shade600,
                                                  size: 24,
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  'Female',
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: _gender == 1
                                                        ? FontWeight.bold
                                                        : FontWeight.normal,
                                                    color: _gender == 1
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
                            'Risk Factors & Symptoms',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: kPrimaryColor,
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Please indicate if you have any of the following:',
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
