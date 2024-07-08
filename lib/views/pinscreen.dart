import 'package:flutter/material.dart';
import 'package:myapp/views/Home.dart';
import 'package:myapp/views/setpin.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';

class AuthenticationPage extends StatefulWidget {
  @override
  _AuthenticationPageState createState() => _AuthenticationPageState();
}

class _AuthenticationPageState extends State<AuthenticationPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final _pinController = TextEditingController();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;
  bool _useBiometric = false;

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
  }

  Future<void> _checkBiometricAvailability() async {
    bool canCheckBiometrics = await auth.canCheckBiometrics;
    List<BiometricType> availableBiometrics = await auth.getAvailableBiometrics();
    setState(() {
      _isBiometricAvailable = canCheckBiometrics && availableBiometrics.isNotEmpty;
    });
  }

  Future<void> _authenticate() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPin = prefs.getString('userPin');

    if (storedPin == null) {
      // Handle case where PIN is not set
      _showSnackBar('PIN not set. Please set your PIN first.');
      return;
    }

    if (_useBiometric && _isBiometricAvailable) {
      bool authenticated = await auth.authenticate(
        localizedReason: 'Please authenticate to proceed',
       
      );
      if (authenticated) {
        _navigateToHomePage();
      } else {
        _showSnackBar('Biometric authentication failed');
      }
    } else {
      String enteredPin = _pinController.text;
      if (enteredPin == storedPin) {
        _navigateToHomePage();
      } else {
        _showSnackBar('Incorrect PIN');
      }
    }
  }

  void _navigateToHomePage() {
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Authentication'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (_isBiometricAvailable)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Checkbox(
                      value: _useBiometric,
                      onChanged: (bool? value) {
                        setState(() {
                          _useBiometric = value ?? false;
                        });
                      },
                    ),
                    Text('Use Biometric Authentication'),
                  ],
                ),
              if (!_isBiometricAvailable || !_useBiometric)
                Pinput(
                  controller: _pinController,
                  length: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your PIN';
                    }
                    return null;
                  },
                  obscureText: true,
                  obscuringCharacter: '*',
                ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _authenticate,
                child: Text('Authenticate'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

