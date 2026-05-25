import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../core/theme.dart';

/// A smart image widget that automatically renders network or asset images
/// based on the URL. Supports Cloudinary (http/https) and local asset paths.
class ProductImage extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;

  const ProductImage({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  bool get _isNetworkUrl =>
      imageUrl.startsWith('http://') || imageUrl.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildPlaceholder(context);
    }

    if (_isNetworkUrl) {
      return Image.network(
        imageUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, progress) {
          if (progress == null) return child;
          return _buildLoading(context);
        },
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder(context);
        },
      );
    }

    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      height: height,
      errorBuilder: (context, error, stackTrace) {
        return _buildPlaceholder(context);
      },
    );
  }

  Widget _buildLoading(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: NoorTheme.cardAlt(context),
      child: Center(
        child: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: NoorTheme.textMuted(context),
          ),
        ),
      ),
    );
  }

  Widget _buildPlaceholder(BuildContext context) {
    return Container(
      width: width,
      height: height,
      color: NoorTheme.cardAlt(context),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: NoorTheme.textMuted(context),
          size: 32,
        ),
      ),
    );
  }
}
