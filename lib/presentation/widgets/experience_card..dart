import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';

class ExperienceCard extends StatelessWidget {
  final String imageUrl;
  final bool selected;
  final VoidCallback onTap;

  const ExperienceCard({
    super.key,
    required this.imageUrl,
    required this.selected,
    required this.onTap,
  });

  static const List<double> _greyscaleMatrix = <double>[
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0.2126, 0.7152, 0.0722, 0, 0,
    0, 0, 0, 1, 0,
  ];

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(14.0);
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          children: [
            // Main Image
            AspectRatio(
              aspectRatio: 1, // keeps the card square
              child: ColorFiltered(
                colorFilter: selected
                    ? const ColorFilter.mode(
                    Colors.transparent, BlendMode.multiply)
                    : const ColorFilter.matrix(_greyscaleMatrix),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  fit: BoxFit.cover,
                  placeholder: (context, url) =>
                      Container(color: Colors.grey[300]),
                  errorWidget: (context, url, err) => Container(
                    color: Colors.grey[300],
                    child: const Icon(Icons.broken_image, color: Colors.grey),
                  ),
                ),
              ),
            ),

            // Gradient overlay (subtle dark at bottom)
            Positioned.fill(
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Color.fromARGB(120, 0, 0, 0),
                    ],
                  ),
                ),
              ),
            ),

            // // Selection checkmark
            // if (selected)
            //   Positioned(
            //     top: 2.w,
            //     right: 2.w,
            //     child: Container(
            //       padding: EdgeInsets.all(2.w),
            //       decoration: BoxDecoration(
            //         color: Colors.white,
            //         shape: BoxShape.circle,
            //         boxShadow: [
            //           BoxShadow(
            //             color: Colors.black26,
            //             blurRadius: 4,
            //             offset: const Offset(0, 2),
            //           ),
            //         ],
            //       ),
            //       // child: Icon(
            //       //   Icons.check,
            //       //   size: 14.sp,
            //       //   color: Theme.of(context).primaryColor,
            //       // ),
            //     ),
            //   ),
          ],
        ),
      ),
    );
  }
}
