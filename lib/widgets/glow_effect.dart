import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

class GlowEffect extends SingleChildRenderObjectWidget {
  /// Glowing color
  Color color;

  /// Blur radius
  /// Default: 10
  double blurRadius;

  /// Glow strength
  /// Default: 0.1
  /// 0.0 - 1.0
  double glowStrength;

  GlowEffect({
    super.key,
    super.child,
    this.color = Colors.white,
    this.blurRadius = 10,
    this.glowStrength = 0.1,
  });

  @override
  RenderGlowEffect createRenderObject(BuildContext context) {
    return RenderGlowEffect(
        color: color, blurRadius: blurRadius, glowStrength: glowStrength);
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant RenderGlowEffect renderObject) {
    renderObject
      ..glowStrength = glowStrength
      ..color = color
      ..blurRadius = blurRadius;
  }
}

class RenderGlowEffect extends RenderProxyBox {
  /// Glowing color
  Color color;

  /// Blur radius
  /// Default: 10
  double blurRadius;

  /// Glow strength
  /// Default: 0.1
  /// 0.0 - 1.0
  double glowStrength;

  RenderGlowEffect({
    RenderBox? child,
    required this.color,
    required this.blurRadius,
    required this.glowStrength,
  }) : super(child);

  @override
  void paint(PaintingContext context, Offset offset) {
    if (child != null) {
      context.paintChild(child!, offset);
      context.canvas.drawRect(
        Rect.fromLTWH(
          offset.dx,
          offset.dy,
          child!.size.width,
          child!.size.height,
        ),
        Paint()
          ..color = color.withOpacity(glowStrength)
          ..blendMode = BlendMode.colorDodge
          ..maskFilter = MaskFilter.blur(BlurStyle.normal, blurRadius),
      );
    }
  }
}
