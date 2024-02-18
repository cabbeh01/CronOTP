import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class TOTPCard extends StatelessWidget {
  final String serviceName;
  final String email;
  final String otpCode;

  const TOTPCard({
    Key? key,
    required this.serviceName,
    required this.email,
    required this.otpCode,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.blue,
          width: 2.0,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SvgPicture.network(
                'https://upload.wikimedia.org/wikipedia/commons/1/19/Spotify_logo_without_text.svg',
                width: 24,
                height: 24,
              ),
              const SizedBox(width: 8),
              Text(
                serviceName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            email,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                otpCode,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 32,
                ),
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: () {
                  Clipboard.setData(ClipboardData(text: otpCode));
                },
                child: Container(
                  padding: EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.copy, // Copy icon
                    color: Colors.white, // Icon color
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
