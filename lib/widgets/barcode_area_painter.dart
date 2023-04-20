import 'dart:math';

import 'package:flutter/material.dart';

class BarcodeAreaPainter extends CustomPainter {
  final double strokeWidth;
  final double radius;
  final double widthLengthPercent;
  final double heightLengthPercent;
  final double widthSizePercent;
  final double heightSizePercent;
  final Color color;
  final double outsideOpacity;
  final bool makeSquare;

  BarcodeAreaPainter({
    this.strokeWidth = 6,
    this.radius = 16,
    this.widthLengthPercent = 0.5,
    this.heightLengthPercent = 0.5,
    this.color = Colors.white,
    this.widthSizePercent = 0.5,
    this.heightSizePercent = 0.5,
    this.outsideOpacity = 0.3,
    this.makeSquare = false,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Size indicatorSize = size;

    if (makeSquare) {
      indicatorSize = Size(
        min(size.width, size.height),
        min(size.width, size.height),
      );
    }

    canvas.saveLayer(Rect.fromLTRB(0, 0, size.width, size.height), Paint());
    Paint darkenPaint = Paint()
      ..color = Colors.black.withOpacity(outsideOpacity);
    canvas.drawRect(Rect.fromLTRB(0, 0, size.width, size.height), darkenPaint);

    RRect outer = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: indicatorSize.width * widthSizePercent,
          height: indicatorSize.height * heightSizePercent),
      Radius.circular(radius),
    );
    RRect inner = RRect.fromRectAndRadius(
      Rect.fromCenter(
          center: Offset(size.width / 2, size.height / 2),
          width: indicatorSize.width * widthSizePercent - strokeWidth,
          height: indicatorSize.height * heightSizePercent - strokeWidth),
      Radius.circular(radius),
    );

    canvas.drawRRect(outer, Paint()..blendMode = BlendMode.clear);
    canvas.drawDRRect(outer, inner, Paint()..color = color);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: indicatorSize.width * widthSizePercent * widthLengthPercent,
            height: indicatorSize.height * heightSizePercent + 2),
        Paint()..blendMode = BlendMode.clear);
    canvas.drawRect(
        Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: indicatorSize.width * widthSizePercent + 2,
            height:
                indicatorSize.height * heightSizePercent * heightLengthPercent),
        Paint()..blendMode = BlendMode.clear);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    if (oldDelegate is BarcodeAreaPainter) {
      return oldDelegate.strokeWidth != strokeWidth ||
          oldDelegate.radius != radius ||
          oldDelegate.widthLengthPercent != widthLengthPercent ||
          oldDelegate.heightLengthPercent != heightLengthPercent ||
          oldDelegate.color != color;
    }
    return true;
  }
}
