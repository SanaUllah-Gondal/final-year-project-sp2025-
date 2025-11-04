import 'package:flutter/material.dart';

class CustomBadge extends StatelessWidget {
  final Widget child;
  final int count;
  final Color? backgroundColor;
  final Color? textColor;
  final double? size;
  final double? fontSize;
  final bool showZero;

  const CustomBadge({
    Key? key,
    required this.child,
    this.count = 0,
    this.backgroundColor,
    this.textColor,
    this.size,
    this.fontSize,
    this.showZero = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final shouldShowBadge = count > 0 || (showZero && count == 0);

    return Stack(
      clipBehavior: Clip.none,
      children: [
        child,
        if (shouldShowBadge)
          Positioned(
            top: -6,
            right: -6,
            child: Container(
              padding: EdgeInsets.all(4),
              constraints: BoxConstraints(
                minWidth: size ?? 22,
                minHeight: size ?? 22,
              ),
              decoration: BoxDecoration(
                color: backgroundColor ?? Colors.red,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.3),
                    blurRadius: 4,
                    offset: Offset(0, 2),
                  ),
                ],
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: TextStyle(
                    color: textColor ?? Colors.white,
                    fontSize: fontSize ?? 10,
                    fontWeight: FontWeight.bold,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
      ],
    );
  }
}