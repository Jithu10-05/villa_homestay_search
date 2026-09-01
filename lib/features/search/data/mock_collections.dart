import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_images.dart';
import '../domain/models/travel_collection.dart';

const String _photo = AppImages.photoPrefix;
const String _thumb = AppImages.thumbParams;

/// Curated home-screen shortcuts (mock data).
const List<TravelCollection> kMockCollections = <TravelCollection>[
  TravelCollection(
    title: 'Beachfront villas',
    subtitle: 'Goa',
    imageAsset: AppAssets.collectionBeach,
    imageUrl: '${_photo}1596178067639-5c6e68aea6dc$_thumb',
    locationId: 'goa',
  ),
  TravelCollection(
    title: 'Mountain escapes',
    subtitle: 'Manali',
    imageAsset: AppAssets.collectionMountain,
    imageUrl: '${_photo}1564053502047-a90b101ccc48$_thumb',
    locationId: 'manali',
  ),
  TravelCollection(
    title: 'Heritage stays',
    subtitle: 'Jaipur',
    imageAsset: AppAssets.collectionCity,
    imageUrl: '${_photo}1758467745943-e80e6236d200$_thumb',
    locationId: 'jaipur',
  ),
];
