import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmerScreen extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;
  const CommonShimmerScreen({super.key, this.width, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey.shade300,
      highlightColor: Colors.grey.shade400,
      child: Container(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(
            radius ?? 0.0,
          ),
        ),
      ),
    );
  }
}
