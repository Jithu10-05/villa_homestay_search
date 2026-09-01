import 'package:flutter/material.dart';

import '../../app/app_colors.dart';

/// Shows a remote photograph with a local illustration as the safety net.
///
/// * while the photo downloads, a soft placeholder holds the space;
/// * if the download fails (offline, blocked network, bad URL), the bundled
///   asset is shown instead, so the screen never breaks.
class RemoteImage extends StatelessWidget {
  const RemoteImage({
    required this.url,
    required this.fallbackAsset,
    this.fit = BoxFit.cover,
    super.key,
  });

  /// Remote photo. When null or empty the fallback asset is used directly.
  final String? url;

  /// Bundled illustration used while offline or on error.
  final String fallbackAsset;
  final BoxFit fit;

  @override
  Widget build(BuildContext context) {
    final String? source = url;
    if (source == null || source.isEmpty) return _fallback();

    return Image.network(
      source,
      fit: fit,
      excludeFromSemantics: true,
      // Cross-fades the placeholder into the photo once it has downloaded.
      loadingBuilder: (
        BuildContext context,
        Widget child,
        ImageChunkEvent? progress,
      ) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: progress == null ? child : const _LoadingPlaceholder(),
        );
      },
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          _fallback(),
    );
  }

  Widget _fallback() {
    return Image.asset(
      fallbackAsset,
      fit: fit,
      excludeFromSemantics: true,
      errorBuilder: (BuildContext context, Object error, StackTrace? stack) =>
          const ColoredBox(color: AppColors.primarySoft),
    );
  }
}

class _LoadingPlaceholder extends StatelessWidget {
  const _LoadingPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[Color(0xFFEDF2F9), Color(0xFFDCE5F0)],
        ),
      ),
      child: Center(
        child: Icon(
          Icons.photo_outlined,
          color: AppColors.inkFaint,
          size: 26,
        ),
      ),
    );
  }
}
