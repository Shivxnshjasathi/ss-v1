import 'package:flutter/material.dart';

class SavedPropertiesScreen extends StatelessWidget {
  const SavedPropertiesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Properties')),
      body: const Center(
        child: Text('You have no saved properties yet.', style: TextStyle(color: Colors.grey)),
      ),
    );
  }
}
