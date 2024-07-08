import 'package:flutter/material.dart';
import 'package:myapp/views/Home.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:local_auth/local_auth.dart';
import 'package:pinput/pinput.dart';

class SetPinPage extends StatefulWidget {
  @override
  _SetPinPageState createState() => _SetPinPageState();
}

class _SetPinPageState extends State<SetPinPage> {
  final LocalAuthentication auth = LocalAuthentication();
  final _formKey = GlobalKey<FormState>();
  final _pinController = TextEditingController();
  final _confirmPinController = TextEditingController();
  bool _isBiometricAvailable = false;
  bool _isBiometricEnabled = false;

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

  Future<void> _setPinAndBiometric() async {
    if (_formKey.currentState!.validate()) {
      String pin = _pinController.text;
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('userPin', pin);

      if (_isBiometricEnabled && _isBiometricAvailable) {
        bool authenticated = await auth.authenticate(
          localizedReason: 'Please authenticate to enable biometric login',
          options: AuthenticationOptions(biometricOnly: true),
        );
        if (authenticated) {
          await prefs.setBool('biometricEnabled', true);
        }
      }

      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => HomePage()));
      prefs.setBool('isFirstTime', false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Set PIN and Biometric'),
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Pinput(
                  controller: _pinController,
                  length: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a PIN';
                    }
                    if (value.length < 4) {
                      return 'PIN must be 4 digits';
                    }
                    return null;
                  },
                  obscureText: true,
                  obscuringCharacter: '*',
                ),
                SizedBox(height: 20),
                Pinput(
                  controller: _confirmPinController,
                  length: 4,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please confirm your PIN';
                    }
                    if (value != _pinController.text) {
                      return 'PINs do not match';
                    }
                    return null;
                  },
                  obscureText: true,
                  obscuringCharacter: '*',
                ),
                SizedBox(height: 20),
                if (_isBiometricAvailable)
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Checkbox(
                        value: _isBiometricEnabled,
                        onChanged: (bool? value) {
                          setState(() {
                            _isBiometricEnabled = value!;
                          });
                        },
                      ),
                      Text('Enable Biometric Authentication'),
                    ],
                  ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _setPinAndBiometric,
                  child: Text('Save'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

