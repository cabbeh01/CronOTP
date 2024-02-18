import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class OTPData {
  final String issuer;
  final String username;
  final String secret;
  final String? icon;

  OTPData({
    required this.issuer,
    required this.username,
    required this.secret,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'issuer': issuer,
    'username': username,
    'secret': secret,
    'icon': icon ?? 'default_icon',
  };

  factory OTPData.fromJson(Map<String, dynamic> json) {
    return OTPData(
      issuer: json['issuer'],
      username: json['username'],
      secret: json['secret'],
      icon: json['icon'],
    );
  }
}

class OTPDataStorage {
  static const String _storageKey = 'otp_data_list';

  static Future<List<OTPData>> loadOTPDataList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? jsonStringList = prefs.getStringList(_storageKey);
    if (jsonStringList != null) {
      return jsonStringList.map((jsonString) => OTPData.fromJson(jsonDecode(jsonString))).toList();
    }
    return [];
  }

  static Future<void> addOTPData(OTPData data) async {
    List<OTPData> dataList = await loadOTPDataList();
    dataList.add(data);
    await _saveOTPDataList(dataList);
  }

  static Future<void> removeOTPData(OTPData dataToRemove) async {
    List<OTPData> dataList = await loadOTPDataList();
    dataList.removeWhere((data) =>
    data.issuer == dataToRemove.issuer &&
        data.username == dataToRemove.username &&
        data.secret == dataToRemove.secret &&
        data.icon == dataToRemove.icon);
    await _saveOTPDataList(dataList);
  }

  static Future<void> _saveOTPDataList(List<OTPData> dataList) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> jsonStringList = dataList.map((data) => jsonEncode(data.toJson())).toList();
    await prefs.setStringList(_storageKey, jsonStringList);
  }
}
