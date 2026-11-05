import 'package:flutter/material.dart';

class HeaderSub extends StatelessWidget {
  const HeaderSub({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24),
      child: Row(
        children: [
          Image.asset(
            'assets/img/LogoHeader.png',
            width: 165,
            height: 50,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}