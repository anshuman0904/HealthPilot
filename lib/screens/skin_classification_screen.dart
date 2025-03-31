import 'package:flutter/material.dart';
import '../utils/constants.dart';

class SkinClassificationScreen extends StatefulWidget {
  const SkinClassificationScreen({Key? key}) : super(key: key);

  @override
  _SkinClassificationScreenState createState() => _SkinClassificationScreenState();
}

class _SkinClassificationScreenState extends State<SkinClassificationScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Skin Disease Classification'),
        backgroundColor: kPrimaryColor,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(kDefaultPadding),
      ),
    );
  }
}
