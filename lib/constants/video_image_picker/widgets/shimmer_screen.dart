import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
// import 'package:get/get.dart';

import '../../shimmer/common_shimmer.dart';

class ShimmerScreen extends StatelessWidget {
  const ShimmerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      children: [
        CommonShimmerScreen(
          width: MediaQuery.of(context).size.width,
          height: 480,
          radius: 0,
        ),
        const SizedBox(height: 4),
        AlignedGridView.count(
          crossAxisCount: 4,
          mainAxisSpacing: 4.0,
          crossAxisSpacing: 4.0,
          shrinkWrap: true,
          primary: false,
          itemCount: 20,
          itemBuilder: (context, index) {
            return const CommonShimmerScreen(
              width: 100.0,
              height: 90.0,
              radius: 0,
            );
          },
        ),
      ],
    ));
  }
}
