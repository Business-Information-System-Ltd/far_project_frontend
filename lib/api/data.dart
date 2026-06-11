import 'dart:convert';

//for department
class Department {
  final int? departmentId;
  final int? parentDeptId;
  final String? parentDeptName;
  final String? shortName;
  final String? deptCode;
  final String deptName;
  final String deptType;
  final bool allowAssignment;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Department({
    this.departmentId,
    this.parentDeptId,
    this.parentDeptName,
    this.deptCode,
    required this.deptName,
    this.shortName,
    required this.deptType,
    required this.allowAssignment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    return Department(
      departmentId: json['department_id'] ?? json['id'], 
      parentDeptId: json['parent_dept'] ?? json['parent_dept_id'],
      parentDeptName: json['parent_dept_name'] ?? '-',
      deptCode: json['dept_code'],
      deptName: json['dept_name'] ?? json['department_name'] ?? '',
      shortName: json['dept_short_name'],
      deptType: json['dept_type'] ?? '',
      allowAssignment: json['allow_assignment'] is int 
          ? json['allow_assignment'] == 1 
          : (json['allow_assignment'] ?? false),
      isActive: json['is_active'] is int 
          ? json['is_active'] == 1 
          : (json['is_active'] ?? false),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': departmentId,
      'parent_dept': parentDeptId,
      'dept_code': deptCode,
      'dept_name': deptName,
      'dept_short_name': shortName,
      'dept_type': deptType,
      'allow_assignment': allowAssignment,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Department &&
          runtimeType == other.runtimeType &&
          departmentId == other.departmentId;

  @override
  int get hashCode => departmentId.hashCode;
}

//for branch
class Branch {
  final int? branchId;
  final int? countryId;
  final String? countryName;
  final String? branchCode;
  final String branchName;
  final String? region;
  final String? city;
  final String? address;
  final String? phone;
  final String? email;
  final int? postalCode;
  final bool isActive;
  final String? createdAt;
  final String? updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Branch({
    this.branchId,
    required this.countryId,
    this.countryName,
    this.branchCode,
    required this.branchName,
    this.region,
    this.city,
    this.address,
    this.phone,
    this.email,
    this.postalCode,
    required this.isActive,
    this.createdAt,
    this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
  
    int? fetchedCountryId;
    String? fetchedCountryName;

    if (json['country'] != null && json['country'] is Map) {
      fetchedCountryId = json['country']['country_id'] ?? json['country']['id'];
      fetchedCountryName = json['country']['country_name'];
    } else {
      
      fetchedCountryId = json['country_id'] ?? json['country'];
    }

    return Branch(
      branchId: json['branch_id'] ?? json['id'], 
      countryId: fetchedCountryId,
      countryName: fetchedCountryName,
      branchCode: json['branch_code'],
      branchName: json['branch_name'] ?? '',
      region: json['region'],
      city: json['city'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      postalCode: json['postal_code'] is String ? int.tryParse(json['postal_code']) : json['postal_code'],
      isActive: json['is_active'] is int ? json['is_active'] == 1 : (json['is_active'] ?? false),
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'country': countryId, 
      'branch_code': branchCode,
      'branch_name': branchName,
      'region': region,
      'city': city,
      'address': address,
      'phone': phone,
      'email': email,
      'postal_code': postalCode,
      'is_active': isActive, 
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}

//for country
class Country {
  final int countryId;
  final int? currencyId;
  final String countryCode;
  final String countryName;
  final String? iso;
  final String? phone;
  final String? defaultTimeZone;
  final String? defaultLanguage;
  final String? dateFormat; 
  final bool allowAssetLocation;
  final bool defaultCountry;
  final bool isActive;
  final String createdAt;
  final String updatedAt;
  final String? createdBy;
  final String? updatedBy;

  Country({
    required this.countryId,
    this.currencyId,
    required this.countryCode,
    required this.countryName,
    this.iso,
    this.phone,
    this.defaultTimeZone,
    this.defaultLanguage,
    this.dateFormat,
    required this.allowAssetLocation,
    required this.defaultCountry,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      countryId: json['country_id'] ?? json['id'] ?? 0,
      currencyId: json['currency_id'],
      countryCode: json['country_code'] ?? '',
      countryName: json['country_name'] ?? '',
      iso: json['iso'],
      phone: json['phone'],
      defaultTimeZone: json['default_time_zone'],
      defaultLanguage: json['default_language'],
      dateFormat: json['date_format'],
      allowAssetLocation: json['allow_asset_location'] is int 
          ? json['allow_asset_location'] == 1 
          : (json['allow_asset_location'] ?? false),
      defaultCountry: json['default_country'] is int 
          ? json['default_country'] == 1 
          : (json['default_country'] ?? false),
      isActive: json['is_active'] is int 
          ? json['is_active'] == 1 
          : (json['is_active'] ?? false),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'country_id': countryId,
      'currency_id': currencyId,
      'country_code': countryCode,
      'country_name': countryName,
      'iso': iso,
      'phone': phone,
      'default_time_zone': defaultTimeZone,
      'default_language': defaultLanguage,
      'date_format': dateFormat,
      'allow_asset_location': allowAssetLocation,
      'default_country': defaultCountry,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Country &&
          runtimeType == other.runtimeType &&
          countryId == other.countryId;

  @override
  int get hashCode => countryId.hashCode;
}

//pagination
class PaginatedData<T> {
  final List<T> items;
  final int totalCount;

  PaginatedData({required this.items, required this.totalCount});
}  