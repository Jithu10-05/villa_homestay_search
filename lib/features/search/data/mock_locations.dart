import '../domain/models/app_location.dart';

/// Static destination catalogue used while the app runs on mock data.
///
/// Swapping this for a real API only means changing the repository
/// implementation - nothing in the UI reads this list directly.
const List<AppLocation> kMockLocations = <AppLocation>[
  AppLocation(
    id: 'delhi',
    city: 'Delhi',
    country: 'India',
    region: 'National Capital Territory',
    isPopular: true,
  ),
  AppLocation(
    id: 'mumbai',
    city: 'Mumbai',
    country: 'India',
    region: 'Maharashtra',
    isPopular: true,
  ),
  AppLocation(
    id: 'bengaluru',
    city: 'Bengaluru',
    country: 'India',
    region: 'Karnataka',
    isPopular: true,
  ),
  AppLocation(
    id: 'goa',
    city: 'Goa',
    country: 'India',
    region: 'North & South Goa',
    isPopular: true,
  ),
  AppLocation(
    id: 'jaipur',
    city: 'Jaipur',
    country: 'India',
    region: 'Rajasthan',
    isPopular: true,
  ),
  AppLocation(
    id: 'manali',
    city: 'Manali',
    country: 'India',
    region: 'Himachal Pradesh',
    isPopular: true,
  ),
  AppLocation(
    id: 'kochi',
    city: 'Kochi',
    country: 'India',
    region: 'Kerala',
  ),
  AppLocation(
    id: 'hyderabad',
    city: 'Hyderabad',
    country: 'India',
    region: 'Telangana',
  ),
  AppLocation(
    id: 'udaipur',
    city: 'Udaipur',
    country: 'India',
    region: 'Rajasthan',
  ),
  AppLocation(
    id: 'lonavala',
    city: 'Lonavala',
    country: 'India',
    region: 'Maharashtra',
  ),
  AppLocation(
    id: 'alibaug',
    city: 'Alibaug',
    country: 'India',
    region: 'Maharashtra',
  ),
  AppLocation(
    id: 'coorg',
    city: 'Coorg',
    country: 'India',
    region: 'Karnataka',
  ),
  AppLocation(
    id: 'pondicherry',
    city: 'Pondicherry',
    country: 'India',
    region: 'Puducherry',
  ),
  AppLocation(
    id: 'shimla',
    city: 'Shimla',
    country: 'India',
    region: 'Himachal Pradesh',
  ),
  AppLocation(
    id: 'rishikesh',
    city: 'Rishikesh',
    country: 'India',
    region: 'Uttarakhand',
  ),
  AppLocation(
    id: 'colombo',
    city: 'Colombo',
    country: 'Sri Lanka',
    region: 'Western Province',
  ),
  AppLocation(
    id: 'kathmandu',
    city: 'Kathmandu',
    country: 'Nepal',
    region: 'Bagmati',
  ),
  AppLocation(
    id: 'dubai',
    city: 'Dubai',
    country: 'United Arab Emirates',
  ),
];
