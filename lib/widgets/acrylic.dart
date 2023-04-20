import 'dart:ui';

import 'package:flutter/material.dart';

class Acrylic extends StatefulWidget {
  Widget child;
  Acrylic({Key? key, required this.child}) : super(key: key);

  @override
  State<Acrylic> createState() => _AcrylicState();
}

class _AcrylicState extends State<Acrylic> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(32),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withOpacity(0.1),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
