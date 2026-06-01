import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../utils/dimensions.dart';
import 'custom_loading_widget.dart';

class CustomCachedNetworkImage extends StatelessWidget {
  const CustomCachedNetworkImage({
    super.key,
    required this.imageUrl,
    this.placeHolder,
    this.errorPlaceholder,
    this.height,
    this.width,
    this.isCircle = false,
    this.radius,
  });

  final String imageUrl;
  final Widget? placeHolder;
  final Widget? errorPlaceholder;
  final double? height;
  final double? width;
  final double? radius;
  final bool isCircle;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      height: height ?? double.infinity,
      width: width ?? double.infinity,
      imageUrl: imageUrl,
      imageBuilder: (context, imageProvider) => Container(
        height: height ?? double.infinity,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          shape: isCircle ? BoxShape.circle : BoxShape.rectangle,
          borderRadius: isCircle
              ? null
              : BorderRadius.circular(Dimensions.radius * (radius ?? 1.2)),
          image: DecorationImage(image: imageProvider, fit: BoxFit.fill),
        ),
      ),
      placeholder: (context, url) => placeHolder ?? const CustomLoadingWidget(),
      errorWidget: (context, url, error) =>
          errorPlaceholder ??
          placeHolder ??
          Container(
            color: Colors.transparent,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: Colors.grey.withOpacity(0.4),
                size: 24,
              ),
            ),
          ),
    );
  }
}
