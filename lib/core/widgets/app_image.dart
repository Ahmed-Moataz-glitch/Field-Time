import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:field_time/core/constants/app_colors.dart';

class AppImage extends StatelessWidget {
  final String imagePath;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final Widget? errorWidget;

  const AppImage({
    super.key,
    required this.imagePath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.errorWidget,
  });

  bool get _isNetwork =>
      imagePath.startsWith('http://') || imagePath.startsWith('https://');

  bool get _isAsset => imagePath.startsWith('assets/');

  @override
  Widget build(BuildContext context) {
    Widget child;

    if (imagePath.isEmpty) {
      child = _buildPlaceholder();
    } else if (_isNetwork) {
      child = CachedNetworkImage(
        imageUrl: imagePath,
        width: width,
        height: height,
        fit: fit,
        placeholder: (context, url) => _buildPlaceholder(),
        errorWidget: (context, url, error) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else if (_isAsset) {
      child = Image.asset(
        imagePath,
        width: width,
        height: height,
        fit: fit,
        errorBuilder: (context, error, stackTrace) =>
            errorWidget ?? _buildErrorWidget(),
      );
    } else {
      // Local File (from image_picker or device storage)
      if (kIsWeb) {
        child = Image.network(
          imagePath,
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildErrorWidget(),
        );
      } else {
        child = Image.file(
          File(imagePath),
          width: width,
          height: height,
          fit: fit,
          errorBuilder: (context, error, stackTrace) =>
              errorWidget ?? _buildErrorWidget(),
        );
      }
    }

    if (borderRadius != null) {
      return ClipRRect(
        borderRadius: borderRadius!,
        child: child,
      );
    }

    return child;
  }

  Widget _buildPlaceholder() {
    return Container(
      width: width,
      height: height,
      color: AppColors.greyLight,
      child: const Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: AppColors.primary,
          ),
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return Container(
      width: width,
      height: height,
      color: AppColors.greyLight,
      child: const Icon(
        Icons.broken_image_outlined,
        color: AppColors.iconGrey,
      ),
    );
  }
}
