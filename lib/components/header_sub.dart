import 'package:flutter/material.dart';

class HeaderSub extends StatelessWidget {
  final VoidCallback? onBack;

  const HeaderSub({
    super.key,
    this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 12,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: onBack ?? () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF043F6D),
              size: 22,
            ),
          ),
          Image.asset(
            'assets/img/LogoHeader.png',
            width: 110,
            height: 38,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}