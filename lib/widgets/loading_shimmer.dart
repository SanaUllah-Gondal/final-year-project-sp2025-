import 'package:flutter/material.dart';

class LoadingShimmer extends StatelessWidget {
  final double? width;
  final double? height;
  final double borderRadius;
  final Color? baseColor;
  final Color? highlightColor;

  const LoadingShimmer({
    Key? key,
    this.width,
    this.height,
    this.borderRadius = 8,
    this.baseColor,
    this.highlightColor,
  }) : super(key: key);

  factory LoadingShimmer.card() {
    return LoadingShimmer(
      height: 180,
      borderRadius: 16,
    );
  }

  factory LoadingShimmer.circle({double size = 40}) {
    return LoadingShimmer(
      width: size,
      height: size,
      borderRadius: size / 2,
    );
  }

  factory LoadingShimmer.text({double height = 16, double width = double.infinity}) {
    return LoadingShimmer(
      width: width,
      height: height,
      borderRadius: 4,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor ?? Colors.grey[300],
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(borderRadius),
        child: ShimmerLoader(
          baseColor: baseColor ?? Colors.grey[300]!,
          highlightColor: highlightColor ?? Colors.grey[100]!,
        ),
      ),
    );
  }
}

class ShimmerLoader extends StatefulWidget {
  final Color baseColor;
  final Color highlightColor;
  final Duration period;

  const ShimmerLoader({
    Key? key,
    required this.baseColor,
    required this.highlightColor,
    this.period = const Duration(milliseconds: 1500),
  }) : super(key: key);

  @override
  _ShimmerLoaderState createState() => _ShimmerLoaderState();
}

class _ShimmerLoaderState extends State<ShimmerLoader> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.period,
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                widget.baseColor,
                widget.highlightColor,
                widget.baseColor,
              ],
              stops: [
                _controller.value - 0.4,
                _controller.value,
                _controller.value + 0.4,
              ],
            ),
          ),
        );
      },
    );
  }
}

// Example usage:
// LoadingShimmer.card() - for card loading
// LoadingShimmer.circle(size: 50) - for circular loading
// LoadingShimmer.text(height: 20, width: 200) - for text loading