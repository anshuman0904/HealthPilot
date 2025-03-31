import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:HealthPilot/screens/eye_prediction_result.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import '../utils/constants.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:lottie/lottie.dart';

class EyePredictionScreen extends StatefulWidget {
  const EyePredictionScreen({super.key});

  @override
  _EyePredictionScreenState createState() => _EyePredictionScreenState();
}

class _EyePredictionScreenState extends State<EyePredictionScreen> {
  final ImagePicker _picker = ImagePicker();
  XFile? _image;
  bool _isLoading = false;
  bool _showImageSourceOptions = false;

  Future<void> _pickImage(ImageSource source) async {
    setState(() {
      _showImageSourceOptions = false;
    });

    final pickedFile = await _picker.pickImage(
      source: source,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _image = pickedFile;
      });
    }
  }

  void _handlePredictionResult(Map<String, dynamic> result) {
    final mainDisease = result['topPredictions'][0]['disease'];
    final mainConfidence = result['topPredictions'][0]['confidence'];
    final topPredictions =
        List<Map<String, dynamic>>.from(result['topPredictions']);

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EyePredResultScreen(
          mainDisease: mainDisease,
          mainConfidence: mainConfidence,
          topPredictions: topPredictions,
        ),
      ),
    );
  }

  Future<void> _uploadImage() async {
    if (_image == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select an image first'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    var request = http.MultipartRequest(
      'POST',
      Uri.parse('https://2125-103-237-156-11.ngrok-free.app/predict_eye'),
    );

    request.files.add(await http.MultipartFile.fromPath(
      'image',
      _image!.path,
    ));

    try {
      var response = await request.send();

      if (response.statusCode == 200) {
        var responseData = await http.Response.fromStream(response);
        var result = jsonDecode(responseData.body);
        setState(() {
          _isLoading = false;
        });
        _handlePredictionResult(result);
      } else {
        setState(() {
          _isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Failed to upload image. Status code: ${response.statusCode}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(73, 189, 255, 235),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: kPrimaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Eye Analysis',
          style: TextStyle(
            color: kPrimaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color.fromARGB(255, 216, 255, 254),
              Color.fromARGB(255, 233, 246, 255),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header section
                const Text(
                  'Upload a clear image of the Eye Retina',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Color.fromARGB(255, 23, 68, 145),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'For accurate results, ensure good lighting and focus',
                  style: TextStyle(
                    fontSize: 14,
                    color: kLightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),

                // Image preview section
                Expanded(
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        _showImageSourceOptions = true;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: _image != null
                            ? Stack(
                                fit: StackFit.expand,
                                children: [
                                  Image.file(
                                    File(_image!.path),
                                    fit: BoxFit.cover,
                                  ),
                                  Positioned(
                                    right: 10,
                                    top: 10,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        shape: BoxShape.circle,
                                      ),
                                      child: IconButton(
                                        icon: const Icon(
                                          Icons.refresh,
                                          color: kPrimaryColor,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            _showImageSourceOptions = true;
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              )
                            : DottedBorder(
                                borderType: BorderType.RRect,
                                radius: const Radius.circular(20),
                                dashPattern: const [8, 4],
                                color: kPrimaryColor.withOpacity(0.5),
                                strokeWidth: 2,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(20),
                                        decoration: BoxDecoration(
                                          color: kPrimaryColor.withOpacity(0.1),
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(
                                          Icons.add_photo_alternate_outlined,
                                          size: 50,
                                          color: kPrimaryColor,
                                        ),
                                      ),
                                      const SizedBox(height: 16),
                                      const Text(
                                        'Tap to select an image',
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: kPrimaryColor,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 30),

                // Info card
                if (_image != null)
                  Container(
                    padding: const EdgeInsets.all(15),
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF1F8E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: const Color(0xFFAED581),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle_outline,
                          color: Color(0xFF558B2F),
                        ),
                        const SizedBox(width: 10),
                        const Expanded(
                          child: Text(
                            "Image ready for analysis. Tap 'Analyze' to continue.",
                            style: TextStyle(
                              color: Color(0xFF558B2F),
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Action button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _uploadImage,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: kPrimaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: kPrimaryColor.withOpacity(0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: _isLoading
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                "Analyzing...",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            "Analyze Eye",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 16),

                // Disclaimer
                const Text(
                  'This analysis is for informational purposes only and should not replace professional medical advice.',
                  style: TextStyle(
                    fontSize: 12,
                    color: kLightTextColor,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),

      // Image source selection bottom sheet
      bottomSheet: _showImageSourceOptions
          ? Container(
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(20),
                  topRight: Radius.circular(20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, -5),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Select Image Source',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color.fromARGB(255, 23, 68, 145),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildSourceOption(
                            icon: Icons.camera_alt,
                            title: 'Camera',
                            onTap: () => _pickImage(ImageSource.camera),
                          ),
                          _buildSourceOption(
                            icon: Icons.photo_library,
                            title: 'Gallery',
                            onTap: () => _pickImage(ImageSource.gallery),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showImageSourceOptions = false;
                          });
                        },
                        child: const Text(
                          'Cancel',
                          style: TextStyle(
                            color: kLightTextColor,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildSourceOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: kPrimaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              size: 30,
              color: kPrimaryColor,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
