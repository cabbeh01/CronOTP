
import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'displayQrContent.dart';

class QRScanPage extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _QRScanPageState();
}

class _QRScanPageState extends State<QRScanPage> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');

  QRViewController? controller;
  final storage = const FlutterSecureStorage();
  bool _isQRCodeDetected = false;

  @override
  void reassemble() {
    super.reassemble();
    if (controller != null) {
      controller!.resumeCamera();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isQRCodeDetected) {
      controller?.resumeCamera().then((_) {
        setState(() {
          _isQRCodeDetected = false;
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: <Widget>[
          Expanded(
            flex: 5,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: _isQRCodeDetected ? Colors.green : Colors.red,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 300,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan a QR code'),
            ),
          )
        ],
      ),
    );
  }

  void _onQRViewCreated(QRViewController newController) {
    setState(() {
      this.controller = newController;
    });
    newController.scannedDataStream.listen((scanData) async {
      if (!_isQRCodeDetected) {
        setState(() {
          _isQRCodeDetected = true;
        });

        await storage.write(key: 'otp_key', value: scanData.code);
        String? storedData = await storage.read(key: 'otp_key');

        if (storedData != null) {
          await controller?.pauseCamera();

          await Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => DisplayQRDataScreen(qrData: storedData),
            ),
          );

          _isQRCodeDetected = false;

          await controller?.resumeCamera();
        }
      }
    });
  }


  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
