import 'package:flutter/material.dart';

import '../Enitities/OTPData.dart';


class ClickableIcons extends StatelessWidget {
  final List<OTPData> otpDataList;
  final void Function(OTPData) onIconPressed;

  const ClickableIcons({
    Key? key,
    required this.otpDataList,
    required this.onIconPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        childAspectRatio: 1.5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: otpDataList.length,
      itemBuilder: (BuildContext context, int index) {
        return InkWell(
          onTap: () => onIconPressed(otpDataList[index]),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Icon(
              Icons.key,
              size: 24,
              color: Colors.black,
            ),
          ),
        );
      },
    );
  }
}
