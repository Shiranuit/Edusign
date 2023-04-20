import 'dart:ui';

import 'package:flutter/material.dart';

class AcrylicAppbar extends StatelessWidget {
  final Widget title;
  const AcrylicAppbar({
    Key? key,
    required this.title,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(32),
        bottomRight: Radius.circular(32),
      ),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: kToolbarHeight,
          decoration: BoxDecoration(
            color: Colors.grey.shade300.withOpacity(0.1),
          ),
          child: Stack(
            alignment: AlignmentDirectional.centerStart,
            children: [
              IconButton(
                onPressed: () {
                  Scaffold.of(context).openDrawer();
                },
                icon: const Icon(Icons.menu),
              ),
              Center(
                child: title,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
