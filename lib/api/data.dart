//Department
class Department {
  final int? departmentId;
  final int? parentDeptId;
  final String? deptCode;
  final String deptName;
  //final String departmentName;
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
    this.deptCode,
    required this.deptName,
    required this.deptType,
    required this.allowAssignment,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.createdBy,
    this.updatedBy,
  });

  factory Department.fromJson(Map<String, dynamic> json) {
    // return Department(
    //   departmentId: json['department_id'??1],
    //   parentDeptId: json['parent_dept'??1],
    //   deptCode: json['dept_code'],
    //   deptName: json['dept_name'],
    //   deptType: json['dept_type'],
    //   allowAssignment: json['allow_assignment'] is int ? json['allow_assignment'] == 1 : json['allow_assignment'],
    //   isActive: json['is_active'] is int ? json['is_active'] == 1 : json['is_active'],
    //   createdAt: json['created_at'],
    //   updatedAt: json['updated_at'],
    //   createdBy: json['created_by'],
    //   updatedBy: json['updated_by'],
    // );


    return Department(
      
      departmentId: json['department_id'] ?? json['id'], 
      parentDeptId: json['parent_dept'] ?? json['parent_dept_id'],
      deptCode: json['dept_code'],
      
      deptName: json['dept_name'] ?? json['department_name'] ?? '',
      deptType: json['dept_type'] ?? '',
      allowAssignment: json['allow_assignment'] is int 
          ? json['allow_assignment'] == 1 
          : (json['allow_assignment'] ?? false),
      isActive: json['is_active'] is int 
          ? json['is_active'] == 1 
          : (json['is_active'] ?? false),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'department_id': departmentId,
      'parent_dept': parentDeptId,
      'dept_code': deptCode,
      'dept_name': deptName,
      'dept_type': deptType,
      // 'allow_assignment': allowAssignment ? 1 : 0, 
      // 'is_active': isActive ? 1 : 0,
      //'dept_type': deptType?.toLowerCase() == 'operation' ? 'Operation' : deptType,
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

//Branches

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
    return Branch(
      branchId: json['branch_id'],
      //countryId: json['country_id'],
      countryId: json['country'] ?? json['country_id'],
      countryName: json['country_name'],
      branchCode: json['branch_code'],
      branchName: json['branch_name'],
      region: json['region'],
      city: json['city'],
      address: json['address'],
      phone: json['phone'],
      email: json['email'],
      postalCode: json['postal_code'],
      isActive: json['is_active'] is int ? json['is_active'] == 1 : json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
      
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
      'is_active': isActive ?1:0,
      // 'created_at': createdAt,
      // 'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
    };
  }
}

//country
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
      countryId: json['country_id'],
      currencyId: json['currency_id'],
      countryCode: json['country_code'],
      countryName: json['country_name'],
      iso: json['iso'],
      phone: json['phone'],
      defaultTimeZone: json['default_time_zone'],
      defaultLanguage: json['default_language'],
      dateFormat: json['date_format'],
      allowAssetLocation: json['allow_asset_location'] is int ? json['allow_asset_location'] == 1 : json['allow_asset_location'],
      defaultCountry: json['default_country'] is int ? json['default_country'] == 1 : json['default_country'],
      isActive: json['is_active'] is int ? json['is_active'] == 1 : json['is_active'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      createdBy: json['created_by'],
      updatedBy: json['updated_by'],
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
