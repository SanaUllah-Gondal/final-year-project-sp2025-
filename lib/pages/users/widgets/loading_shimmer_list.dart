import 'package:flutter/material.dart';
import 'package:plumber_project/widgets/loading_shimmer.dart';

class LoadingShimmerList extends StatelessWidget {
  const LoadingShimmerList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 5,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: LoadingShimmer.card(),
      ),
    );
  }
}