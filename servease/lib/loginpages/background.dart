import 'package:flutter/material.dart';
class Background extends StatelessWidget {
  const Background({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: -100,
          right: -50,
          child: _circleShape(180, 200, const Color(0xFFD7F0DB)),
        ),
        Positioned(
          top: -50,
          left: -100,
          child: _circleShape(250, 250, const Color(0xFFB5E0BD)),
        ),
        Positioned(
          bottom: -100,
          right: -80,
          child: _circleShape(200, 200, const Color(0xFFD7F0DB)),
        ),
      ],
    );
  }
}

Widget _circleShape(double width, double height, Color color) {
  return Container(
    width: width,
    height: height,
    decoration: BoxDecoration(color: color, shape: BoxShape.circle),
  );
}