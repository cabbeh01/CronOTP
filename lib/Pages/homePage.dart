import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:otp/otp.dart';

import 'package:timezone/data/latest.dart' as timezone;
import 'package:timezone/timezone.dart' as timezone;
import 'package:totp_flutter/Pages/settingsPage.dart';
import '../Components/clickableIcons.dart';
import '../Components/totpcard.dart';
import '../Enitities/OTPData.dart';
import 'otpScanning.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  String _otpCode = '';
  Timer? _timer;
  double _progress = 1.0;
  final int _otpValidityDuration = 30; //Time OTP validity in seconds
  OTPData? selectedOtpData;
  late DateTime _nextOtpUpdateTime;
  List<OTPData> otpDataList = [];

  void _generateOtpFromSelectedData(OTPData selectedData) {
    final now = DateTime.now();
    final pacificTimeZone = timezone.getLocation('Europe/Stockholm');
    final date = timezone.TZDateTime.from(now, pacificTimeZone);

    if (kDebugMode) {
      print(selectedData.secret);
    }

    setState(() {
      selectedOtpData = selectedData;
      _otpCode = OTP.generateTOTPCodeString(
        selectedData.secret,
        date.millisecondsSinceEpoch,
        interval: _otpValidityDuration,
        algorithm: Algorithm.SHA1, // What algorithm to use?
      );
    });
  }

  @override
  void initState() {
    super.initState();
    timezone.initializeTimeZones();
    _loadOtpData();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _loadOtpData() async {
    var loadedDataList = await OTPDataStorage.loadOTPDataList();
    setState(() {
      otpDataList = loadedDataList;
    });
    if (otpDataList.isNotEmpty) {
      selectedOtpData = otpDataList.first;
      _startOtpTimer();
    }
  }

  void _startOtpTimer() {
    _nextOtpUpdateTime = DateTime.now();
    _generateOtp();
    _timer?.cancel();
    _timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      final now = DateTime.now();
      setState(() {
        _progress = (_otpValidityDuration - now.second % _otpValidityDuration) / _otpValidityDuration;
      });

      if (now.isAfter(_nextOtpUpdateTime)) {
        _nextOtpUpdateTime = now.add(Duration(seconds: _otpValidityDuration - now.second % _otpValidityDuration));
        _generateOtp();
      }
    });
  }

  void _generateOtp() {
    if (selectedOtpData == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("No provider selected.")));
      return;
    }

    final now = DateTime.now();
    final location = timezone.getLocation('Europe/Stockholm');
    final date = timezone.TZDateTime.from(now, location);

    setState(() {
      _otpCode = OTP.generateTOTPCodeString(
          selectedOtpData!.secret, date.millisecondsSinceEpoch, interval: _otpValidityDuration, algorithm: Algorithm.SHA1);
    });
  }


  void _addNewOtp(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => QRScanPage()),
    );
  }

  void _settingsPage(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => const SettingsPage()),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4.0),
          child: LinearProgressIndicator(
            value: _progress,
            backgroundColor: Colors.grey[200],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _addNewOtp(context);
            },
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              _settingsPage(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              flex: 1,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Center(
                  child: TOTPCard(
                    serviceName: selectedOtpData!.issuer,
                    email: selectedOtpData!.username,
                    otpCode: _otpCode,
                  ),
                ),
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClickableIcons(
                  otpDataList: otpDataList,
                  onIconPressed: (OTPData selectedData) {
                    _generateOtpFromSelectedData(selectedData);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

