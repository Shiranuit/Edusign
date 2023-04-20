import 'package:flutter/material.dart';
import 'package:animated_check/animated_check.dart';
import 'package:animated_cross/animated_cross.dart';

enum ValidatorIcon { check, cross }

class AnimatedValidator extends StatefulWidget {
  /// If you want a check or a cross
  final ValidatorIcon icon;

  /// Animation controller
  final AnimationController controller;

  /// Icon size
  final double size;

  /// Icon color
  final Color? color;

  /// Background circle color
  final Color? backgroundColor;
  AnimatedValidator({
    Key? key,
    required this.icon,
    required this.controller,
    required this.size,
    this.color,
    this.backgroundColor,
  }) : super(key: key);

  @override
  _AnimatedValidatorState createState() => _AnimatedValidatorState();
}

class _AnimatedValidatorState extends State<AnimatedValidator> {
  late Widget animatedValidatorIcon;
  late Animation<double> _animationValidator;
  late Animation<double> _animationCircle;

  @override
  void initState() {
    _animationValidator = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: widget.controller, curve: const Interval(0.5, 1.0)),
    );
    _animationCircle = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
          parent: widget.controller, curve: const Interval(0.0, 0.5)),
    );
    animatedValidatorIcon = widget.icon == ValidatorIcon.check
        ? AnimatedCheck(
            progress: _animationValidator,
            size: widget.size,
            color: widget.color,
          )
        : AnimatedCross(
            progress: _animationValidator,
            size: widget.size,
            color: widget.color,
          );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationCircle,
      builder: (context, child) {
        return Transform.scale(
          scale: _animationCircle.value,
          child: child,
        );
      },
      child: ClipOval(
        child: Container(
          width: widget.size,
          height: widget.size,
          color: widget.backgroundColor,
          child: Center(
            child: animatedValidatorIcon,
          ),
        ),
      ),
    );
  }
}
