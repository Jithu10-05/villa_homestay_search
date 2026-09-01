import 'package:flutter/material.dart';

import '../../../../app/app_colors.dart';
import '../../../../app/app_spacing.dart';
import '../../../../app/app_theme.dart';
import '../../../../shared/utils/currency.dart';
import '../../../../shared/widgets/app_tag.dart';
import '../../../../shared/widgets/remote_image.dart';
import '../../domain/models/property.dart';
import 'rating_badge.dart';

/// A single stay in the listings feed.
class PropertyCard extends StatefulWidget {
  const PropertyCard({
    required this.property,
    required this.nights,
    super.key,
  });

  final Property property;

  /// Nights in the current search, used for the total price line.
  final int nights;

  @override
  State<PropertyCard> createState() => _PropertyCardState();
}

class _PropertyCardState extends State<PropertyCard> {
  bool _saved = false;

  @override
  Widget build(BuildContext context) {
    final Property property = widget.property;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: kSoftShadow,
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _CardImage(
            property: property,
            saved: _saved,
            onToggleSaved: () => setState(() => _saved = !_saved),
          ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.md + 2),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                RatingBadge(
                  rating: property.ratingLabel,
                  word: property.ratingWord,
                  reviewCount: property.reviewCount,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  property.name,
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 2),
                Text(
                  '${property.location} · ${property.neighbourhood}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '${property.type.label} · ${property.bedrooms} bedrooms · '
                  'up to ${property.maxGuests} guests',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.ink,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  property.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                if (property.tags.isNotEmpty) ...<Widget>[
                  const SizedBox(height: AppSpacing.md),
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: property.tags
                        .map((String tag) => AppTag(label: tag))
                        .toList(growable: false),
                  ),
                ],
                const SizedBox(height: AppSpacing.md),
                _Benefits(property: property),
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
                  child: Divider(height: 1, color: AppColors.border),
                ),
                _PriceRow(property: property, nights: widget.nights),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CardImage extends StatelessWidget {
  const _CardImage({
    required this.property,
    required this.saved,
    required this.onToggleSaved,
  });

  final Property property;
  final bool saved;
  final VoidCallback onToggleSaved;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 16 / 10,
      child: Stack(
        fit: StackFit.expand,
        children: <Widget>[
          RemoteImage(
            url: property.imageUrl,
            fallbackAsset: property.imageAsset,
          ),
          Positioned(
            top: AppSpacing.md,
            left: 0,
            child: Row(
              children: <Widget>[
                if (property.isStarHost)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.sm + 2,
                      vertical: 5,
                    ),
                    decoration: const BoxDecoration(
                      color: AppColors.accent,
                      borderRadius: BorderRadius.horizontal(
                        right: Radius.circular(AppRadius.pill),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Icon(Icons.workspace_premium_rounded,
                            size: 13, color: Colors.white),
                        SizedBox(width: 4),
                        Text(
                          'STAR HOST',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Positioned(
            top: AppSpacing.sm,
            right: AppSpacing.sm,
            child: Material(
              color: Colors.white.withValues(alpha: 0.9),
              shape: const CircleBorder(),
              child: IconButton(
                onPressed: onToggleSaved,
                iconSize: 18,
                visualDensity: VisualDensity.compact,
                tooltip: saved ? 'Remove from wishlist' : 'Save to wishlist',
                icon: Icon(
                  saved ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                  color: saved ? AppColors.danger : AppColors.ink,
                ),
              ),
            ),
          ),
          if (property.hasDiscount)
            Positioned(
              left: 0,
              bottom: AppSpacing.md,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm + 2,
                  vertical: 5,
                ),
                decoration: const BoxDecoration(
                  color: AppColors.success,
                  borderRadius: BorderRadius.horizontal(
                    right: Radius.circular(AppRadius.pill),
                  ),
                ),
                child: Text(
                  '${property.discountPercent}% OFF',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _Benefits extends StatelessWidget {
  const _Benefits({required this.property});

  final Property property;

  @override
  Widget build(BuildContext context) {
    final List<String> benefits = <String>[
      if (property.freeCancellation) 'Free cancellation till 24 hrs before',
      if (property.breakfastIncluded) 'Breakfast included',
      if (property.petFriendly) 'Pets welcome',
    ];
    if (benefits.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: benefits
          .map(
            (String benefit) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Row(
                children: <Widget>[
                  const Icon(Icons.check_rounded,
                      size: 15, color: AppColors.success),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      benefit,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
          .toList(growable: false),
    );
  }
}

class _PriceRow extends StatelessWidget {
  const _PriceRow({required this.property, required this.nights});

  final Property property;
  final int nights;

  @override
  Widget build(BuildContext context) {
    final int effectiveNights = nights <= 0 ? 1 : nights;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              if (property.hasDiscount)
                Text(
                  Currency.inr(property.originalPricePerNight),
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: AppColors.inkFaint,
                    decoration: TextDecoration.lineThrough,
                  ),
                ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: <Widget>[
                  Text(
                    Currency.inr(property.pricePerNight),
                    style: const TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.w800,
                      color: AppColors.ink,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Text(
                    '/ night',
                    style: TextStyle(
                      fontSize: 12.5,
                      color: AppColors.inkMuted,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                '${Currency.inr(property.totalPriceFor(effectiveNights))} '
                'total · $effectiveNights '
                '${effectiveNights == 1 ? 'night' : 'nights'}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.inkMuted,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        const AppTag(
          label: 'Book with ₹0 payment',
          icon: Icons.verified_user_outlined,
          background: AppColors.successSoft,
          foreground: AppColors.success,
        ),
      ],
    );
  }
}
