import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourierLogoWidget extends StatelessWidget {
  final String? logoUrl;
  final String? pngUrl;
  final double width;
  final double height;
  final BoxFit fit;
  final Widget? fallbackWidget;

  const CourierLogoWidget({
    Key? key,
    this.logoUrl,
    this.pngUrl,
    this.width = 64,
    this.height = 40,
    this.fit = BoxFit.contain,
    this.fallbackWidget,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Wrap everything in a constrained box to prevent overflow
    return SizedBox(
      width: width,
      height: height,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: _buildContent(),
      ),
    );
  }

  Widget _buildContent() {
    // If no URLs provided, show fallback
    if ((logoUrl == null || logoUrl!.isEmpty) && (pngUrl == null || pngUrl!.isEmpty)) {
      return _buildFallback();
    }

    // Prefer PNG over SVG if available
    if (pngUrl != null && pngUrl!.isNotEmpty) {
      print('CourierLogoWidget: Attempting to load PNG: $pngUrl');
      return Image.network(
        pngUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) {
            print('CourierLogoWidget: PNG loaded successfully: $pngUrl');
            return child;
          }
          print('CourierLogoWidget: PNG loading progress: ${loadingProgress.expectedTotalBytes != null ? '${loadingProgress.cumulativeBytesLoaded}/${loadingProgress.expectedTotalBytes}' : 'Unknown'}');
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          print('CourierLogoWidget: PNG failed to load: $error');
          print('CourierLogoWidget: PNG URL that failed: $pngUrl');
          // Try SVG as fallback
          if (logoUrl != null && logoUrl!.isNotEmpty && logoUrl!.toLowerCase().endsWith('.svg')) {
            print('CourierLogoWidget: Trying SVG fallback: $logoUrl');
            return SvgPicture.network(
              logoUrl!,
              width: width,
              height: height,
              fit: fit,
              placeholderBuilder: (context) => _buildLoadingPlaceholder(),
              errorBuilder: (context, error, stackTrace) {
                print('CourierLogoWidget: SVG also failed to load: $error');
                return _buildFallback();
              },
            );
          }
          return _buildFallback();
        },
      );
    }

    // Use SVG if PNG is not available
    if (logoUrl != null && logoUrl!.isNotEmpty && logoUrl!.toLowerCase().endsWith('.svg')) {
      return SvgPicture.network(
        logoUrl!,
        width: width,
        height: height,
        fit: fit,
        placeholderBuilder: (context) => _buildLoadingPlaceholder(),
        errorBuilder: (context, error, stackTrace) {
          print('CourierLogoWidget: SVG failed to load: $error');
          return _buildFallback();
        },
      );
    }

    // Use logo URL as fallback (might be PNG or other format)
    if (logoUrl != null && logoUrl!.isNotEmpty) {
      return Image.network(
        logoUrl!,
        width: width,
        height: height,
        fit: fit,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return _buildLoadingPlaceholder();
        },
        errorBuilder: (context, error, stackTrace) {
          print('CourierLogoWidget: Logo URL failed to load: $error');
          return _buildFallback();
        },
      );
    }

    return _buildFallback();
  }

  Widget _buildLoadingPlaceholder() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Center(
        child: SizedBox(
          width: 16,
          height: 16,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.grey[400]!),
          ),
        ),
      ),
    );
  }

  Widget _buildFallback() {
    if (fallbackWidget != null) {
      return SizedBox(
        width: width,
        height: height,
        child: fallbackWidget!,
      );
    }
    
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(4),
      ),
      child: Icon(
        Icons.local_shipping,
        color: Colors.grey[400],
        size: width * 0.4,
      ),
    );
  }
} 