import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../theme/app_theme.dart';

class ShimmerPostCard extends StatelessWidget {
  const ShimmerPostCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Shimmer.fromColors(
          baseColor: context.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          highlightColor: context.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Status + date row
            Row(children: [
              _box(w: 72, h: 22, radius: 6),
              const Spacer(),
              _box(w: 100, h: 14, radius: 4),
            ]),
            const SizedBox(height: 12),
            _box(w: double.infinity, h: 14, radius: 4),
            const SizedBox(height: 6),
            _box(w: double.infinity, h: 14, radius: 4),
            const SizedBox(height: 6),
            _box(w: 160, h: 14, radius: 4),
            const SizedBox(height: 14),
            Row(children: [
              _box(w: 42, h: 26, radius: 6),
              const SizedBox(width: 8),
              _box(w: 52, h: 26, radius: 6),
              const SizedBox(width: 8),
              _box(w: 36, h: 26, radius: 6),
            ]),
          ]),
        ),
      ),
    );
  }

  Widget _box({double? w, required double h, required double radius}) => Container(
        width: w,
        height: h,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(radius),
        ),
      );
}

class ShimmerAccountCard extends StatelessWidget {
  const ShimmerAccountCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Shimmer.fromColors(
          baseColor: context.isDark ? const Color(0xFF2C2C2E) : const Color(0xFFE5E7EB),
          highlightColor: context.isDark ? const Color(0xFF3A3A3C) : const Color(0xFFF9FAFB),
          child: Row(children: [
            const CircleAvatar(backgroundColor: Colors.white, radius: 22),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(width: 120, height: 14, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
                const SizedBox(height: 6),
                Container(width: 80, height: 12, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(4))),
              ]),
            ),
            Container(width: 56, height: 24, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(6))),
          ]),
        ),
      ),
    );
  }
}

Widget shimmerList({int count = 5, Widget Function()? item}) {
  return ListView.builder(
    physics: const NeverScrollableScrollPhysics(),
    itemCount: count,
    itemBuilder: (_, __) => item?.call() ?? const ShimmerPostCard(),
  );
}
