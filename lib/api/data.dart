
class Country {
  final int? id;
  final String? countryCode;
  final String? countryName;
  final String? iso;
  final String? phone;
  final String? defaultLanguage;
  final String? dateFormat;
  final bool? isActive;
  

  Country({
    this.id, this.countryCode, this.countryName, this.iso,
    this.phone, this.defaultLanguage, this.dateFormat, this.isActive,
  });

  String get name => countryName ?? 'Unknown';
  String get displayName => '$countryName (${countryCode ?? ""})';

  factory Country.fromJson(Map<String, dynamic> json) {
    print("Country JSON: $json");
    return Country(
      id: json['country_id'] ?? json['id'],
      countryCode: json['country_code']?.toString(),
      countryName: json['country_name']?.toString() ?? json['name']?.toString(),
      iso: json['iso']?.toString(),
      phone: json['phone']?.toString(),
      defaultLanguage: json['default_language']?.toString(),
      dateFormat: json['date_format']?.toString(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': id,
      'country_code': countryCode,
      'country_name': countryName,
      'iso': iso,
      'phone': phone,
      'default_language': defaultLanguage,
      'date_format': dateFormat,
      'is_active': isActive,
    };
  }


}

class Location {
  
  final int? locationId;
  final int? countryId;
  final String locationCode;
  final String locationName;
  final String locationType;
  final String city;
  final String region;
  final String? address;
  final String? line1;
  final String? line2;
  final String? gpsMapReference;
  final String? fullLocationCode;
  final String? fullPath;
  final bool allowAssetAssignment;
  final bool isActive;
  final int? parentLocation;
  final DateTime? createdAt; 
  final String? createdBy;
  
  
  
  
  

Location( {
    this.locationId,
    this.countryId,
    required this.locationCode,
    required this.locationName,
    required this.locationType,
    required this.city,
    required this.region,
    this.address,
    this.line1,
    this.line2,
    this.gpsMapReference,
    this.fullLocationCode,
    this.fullPath,
    this.allowAssetAssignment = true,
    this.isActive = true,
    this.parentLocation,
    this.createdAt, // <--- ဒီမှာ ထည့်ပါ
    this.createdBy, 
   
    
    

  });

  factory Location.fromJson(Map<String, dynamic> json) {
    final dynamic countryObj = json['country'];
    final dynamic rawCountryId = (countryObj != null && countryObj is Map) 
        ? countryObj['country_id'] 
        : null;

    final dynamic rawLocId = json['location_id'];
    final dynamic rawParentLoc = json['parent_location'];

  return Location(
  
      locationId: rawLocId is int ? rawLocId : int.tryParse(rawLocId?.toString() ?? ''),
      countryId: rawCountryId is int ? rawCountryId : int.tryParse(rawCountryId?.toString() ?? ''),
      parentLocation: rawParentLoc is int ? rawParentLoc : int.tryParse(rawParentLoc?.toString() ?? ''),
      
      locationCode: json['location_code'] as String? ?? '',
      locationName: json['location_name'] as String? ?? '',
      locationType: json['location_type'] as String? ?? '',
      city: json['city'] as String? ?? '',
      region: json['region'] as String? ?? '',
      address: json['address'] as String?,
      line1: json['line1']?.toString() ?? '', // Safely handles numeric inputs like string '1'
      line2: json['line2']?.toString()??'',
      gpsMapReference: json['gps_map_reference'] as String?,
      fullLocationCode: json['full_location_code'] as String?,
      fullPath: json['full_path'] as String?,
      allowAssetAssignment: json['allow_asset_assignment'] as bool? ?? true,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at']) : null,
      createdBy: json['created_by'],
      
     
      
    );
    
    
  }

  Map<String, dynamic> toJson() {
    return {
      'location_id': locationId,
      'country_id': countryId,
      'location_code': locationCode,
      'location_name': locationName,
      'location_type': locationType,
      'city': city,
      'region': region,
      'address': address,
      'line1': line1,
      'line2': line2,
      'gps_map_reference': gpsMapReference,
      'full_location_code': fullLocationCode,
      'full_path': fullPath,
      'allow_asset_assignment': allowAssetAssignment,
      'is_active': isActive,
      'parent_location': parentLocation,
      'created_at': createdAt?.toIso8601String(), 
      'created_by': createdBy,
    };
    
  }

  
  
  int? get id => locationId;
  String get name => locationName;
  String get type => locationType;
  int? get parentLocationId => parentLocation;
  String? get cityTownship => city;
  String? get regionState => region;
}
class PaginatedData<T> {
  final List<T> items;
  final int totalCount;

  PaginatedData({required this.items, required this.totalCount});
}