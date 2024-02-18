import 'package:flutter/material.dart';

import '../Enitities/OTPData.dart';

class DisplayQRDataScreen extends StatefulWidget {
  final String qrData;

  const DisplayQRDataScreen({Key? key, required this.qrData}) : super(key: key);

  @override
  _DisplayQRDataScreenState createState() => _DisplayQRDataScreenState();
}

class _DisplayQRDataScreenState extends State<DisplayQRDataScreen> {
  late TextEditingController _issuerController;
  late TextEditingController _usernameController;
  late String? _secret;

  @override
  void initState() {
    super.initState();
    final parsedData = parseQRData(widget.qrData);
    _issuerController = TextEditingController(text: parsedData['issuer']);
    _usernameController = TextEditingController(text: parsedData['username']);
    _secret = parsedData['secret'];
  }

  @override
  void dispose() {
    _issuerController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  Map<String, String> parseQRData(String qrData) {
    final RegExp regExp = RegExp(r'^otpauth:\/\/totp\/(?:([^:]+):)?([^?]+)\?secret=([^&]+)&issuer=(.+)$');
    final match = regExp.firstMatch(qrData);

    if (match != null) {
      return {
        'issuer': match.group(1) ?? match.group(4)!,
        'username': match.group(2)!,
        'secret': match.group(3)!,
      };
    }
    return {'issuer': '', 'username': '', 'secret': ''};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Code Data'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Issuer:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _issuerController,
              decoration: const InputDecoration(
                hintText: "Issuer",
              ),
            ),
            const SizedBox(height: 20),
            const Text('Username:', style: TextStyle(fontSize: 18)),
            TextField(
              controller: _usernameController,
              decoration: const InputDecoration(
                hintText: "Username",
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                final otpData = OTPData(
                  issuer: _issuerController.text.trim(),
                  username: _usernameController.text.trim(),
                  secret: _secret ?? '',
                );
                await OTPDataStorage.addOTPData(otpData).then((_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('OTP saved successfully!')),
                  );
                  Navigator.pop(context);
                }).catchError((error) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Failed to save OTP: $error')),
                  );
                });
              },
              child: const Text('Save Changes'),
            ),
          ],
        ),
      ),
    );
  }
}
