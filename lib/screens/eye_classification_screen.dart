import 'package:flutter/material.dart';
import '../utils/constants.dart';

class EyeClassificationScreen extends StatefulWidget {
  const EyeClassificationScreen({Key? key}) : super(key: key);

  @override
  _EyeClassificationScreenState createState() => _EyeClassificationScreenState();
}

class _EyeClassificationScreenState extends State<EyeClassificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Eye Disease Classification'),
        backgroundColor: kPrimaryColor,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Upload a retina image for classification',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // TODO: Implement image upload and classification logic
              },
              child: Text('Upload Image'),
            ),
          ],
        ),
      ),
    );
  }
}
