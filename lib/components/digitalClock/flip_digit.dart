
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:studypal/theme/app_colors.dart';
import 'package:studypal/theme/app_text_style.dart';

class FlipDigit extends StatefulWidget {
  final String value;

  const FlipDigit({
    super.key,
    required this.value,
  });

  @override
  State<FlipDigit> createState() => _FlipDigitState();
}

class _FlipDigitState extends State<FlipDigit>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _oldValue;

  static const double cardWidth = 110;
  static const double cardHeight = 76;
  static const double halfHeight = 38;

  @override
  void initState() {
    super.initState();

    _oldValue = widget.value;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    );
  }

  @override
  void didUpdateWidget(covariant FlipDigit oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.value != widget.value) {
      _oldValue = oldWidget.value;
      _controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  TextStyle get digitStyle => AppTextStyles.title.copyWith(
        fontSize: 44,
        fontWeight: FontWeight.bold,
        color: AppColors.background,
        height: 1,
      );

  Widget _number(String value) {
    return SizedBox(
      width: cardWidth,
      height: cardHeight,
      child: Center(
        child: Text(value, style: digitStyle),
      ),
    );
  }

  // Memotong angka menjadi setengah kartu
  Widget _half(String value, {required bool top}) {
    return ClipRect(
      child: SizedBox(
        width: cardWidth,
        height: halfHeight,
        child: OverflowBox(
          alignment: top
              ? Alignment.topCenter
              : Alignment.bottomCenter,
          minHeight: cardHeight,
          maxHeight: cardHeight,
          child: _number(value),
        ),
      ),
    );
  }

  // Tampilan flap dengan shadow
  Widget _flapFace(
    String value, {
    required bool top,
    required double shadowOpacity,
  }) {
    return Container(
      width: cardWidth,
      height: halfHeight,
      decoration: BoxDecoration(
        color: AppColors.primary,
        border: Border(
          bottom: BorderSide(
            color: Colors.black.withValues(alpha: 0.25),
            width: top ? 1 : 0,
          ),
          top: BorderSide(
            color: Colors.white.withValues(alpha: 0.06),
            width: top ? 0 : 1,
          ),
        ),
      ),
      child: Stack(
        children: [
          _half(value, top: top),

          // Shadow semakin gelap ketika kartu bergerak
          Positioned.fill(
            child: IgnorePointer(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(
                    alpha: shadowOpacity,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final progress = _controller.value;

        final topProgress =
            (progress * 2).clamp(0.0, 1.0);

        final bottomProgress =
            ((progress - 0.5) * 2).clamp(0.0, 1.0);

        final topAngle = -math.pi / 2 * topProgress;

        final bottomAngle =
            math.pi / 2 * (1 - bottomProgress);

        return Container(
          width: cardWidth,
          height: cardHeight,
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.16),
                blurRadius: 5,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            clipBehavior: Clip.hardEdge,
            children: [
              // 1. Bagian atas: angka baru di belakang flap
              Positioned(
                top: 0,
                child: _half(widget.value, top: true),
              ),

              // 2. Bagian bawah: angka lama sebagai dasar
              Positioned(
                bottom: 0,
                child: _half(
                  progress < 1 ? _oldValue : widget.value,
                  top: false,
                ),
              ),

              // 3. FLIP ATAS: angka lama jatuh
              if (progress < 0.5)
                Positioned(
                  top: 0,
                  child: Transform(
                    alignment: Alignment.bottomCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(topAngle),
                    child: _flapFace(
                      _oldValue,
                      top: true,
                      shadowOpacity: 0.08 + (0.18 * topProgress),
                    ),
                  ),
                ),

              // 4. FLIP BAWAH: angka baru masuk
              if (progress >= 0.5 && progress < 1)
                Positioned(
                  bottom: 0,
                  child: Transform(
                    alignment: Alignment.topCenter,
                    transform: Matrix4.identity()
                      ..setEntry(3, 2, 0.003)
                      ..rotateX(bottomAngle),
                    child: _flapFace(
                      widget.value,
                      top: false,
                      shadowOpacity: 0.08 + (0.18 * topProgress),
                    ),
                  ),
                ),

              // 5. Garis engsel
              Positioned(
                top: halfHeight - 0.5,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.black.withValues(alpha: 0.4),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
