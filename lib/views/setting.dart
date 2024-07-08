import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final picker = ImagePicker();
  File? _image1;
  File? _image2;
  File? _image3;
  final TextEditingController _pinController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text('Settings'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Text('Change PIN',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              TextField(
                controller: _pinController,
                decoration: InputDecoration(labelText: 'New PIN'),
                keyboardType: TextInputType.number,
                obscureText: true,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _changePin,
                child: Text('Change PIN'),
              ),
              Divider(),
            ],
          ),
        ));
  }

  Future<void> _changePin() async {
    final newPin = _pinController.text;
    if (newPin.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('PIN cannot be empty'),
      ));
      return;
    }

    // Save the new PIN securely
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPin', newPin);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text('PIN changed successfully'),
    ));
  }
}
