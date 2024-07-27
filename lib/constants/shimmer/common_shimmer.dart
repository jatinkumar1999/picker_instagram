import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class CommonShimmerScreen extends StatelessWidget {
  final double? width;
  final double? height;
  final double? radius;

  const CommonShimmerScreen({super.key, this.width, this.height, this.radius});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width ?? double.infinity,
      height: height ?? double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius ?? 10),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade400,
        highlightColor: Colors.grey.shade500,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          decoration: BoxDecoration(
            color: Colors.red,
            borderRadius: BorderRadius.circular(radius ?? 10),
          ),
        ),
      ),
    );
  }
}
