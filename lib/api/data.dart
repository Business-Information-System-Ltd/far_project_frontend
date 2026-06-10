import 'dart:convert';



class Custodian {
  final int? id;
  final String code;
  final String name;
  final String type;
  final String email;
  final String phNo;
  final int deptId;      
  final int branchId;    
  final bool canHoldAssets;
  final bool isActive;

  Custodian({
    this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.email,
    required this.phNo,
    required this.deptId,
    required this.branchId,
    required this.canHoldAssets,
    this.isActive = true,
  });

  factory Custodian.fromJson(Map<String, dynamic> json) {
    int _getDeptId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is Map) {
        return value['dept_id'] ?? value['department_id'] ?? value['id'] ?? 0;
      }
      return int.tryParse(value.toString()) ?? 0;
    }

    int _getBranchId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is Map) {
        return value['branch_id'] ?? value['id'] ?? 0;
      }
      return int.tryParse(value.toString()) ?? 0;
    }

    return Custodian(
      id: json['custodian_id'] as int? ?? json['id'] as int?,
      code: json['custodian_code']?.toString() ?? json['code']?.toString() ?? '',
      name: json['custodian_name']?.toString() ?? json['name']?.toString() ?? '',
      type: json['custodian_type']?.toString() ?? json['type']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phNo: json['phone']?.toString() ?? json['ph_no']?.toString() ?? '',
      deptId: _getDeptId(json['dept'] ?? json['department'] ?? json['dept_id']),
      branchId: _getBranchId(json['branch'] ?? json['branch_id']),
      canHoldAssets: json['can_hold_assets'] == true || json['can_hold_assets'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'custodian_id': id,
      'custodian_code': code,
      'custodian_name': name,
      'custodian_type': type,
      'email': email,
      'phone': phNo,
      'dept': deptId,
      'branch': branchId,
      'can_hold_assets': canHoldAssets,
      'is_active': isActive,
    };
  }
}


class Department {
  final int? departmentId;
  final int? parentDeptId;
  final String? deptCode;
  final String deptName;
  final String? deptShortName;
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
    this.deptShortName,
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
      departmentId: json['department_id'] as int?,
      parentDeptId: json['parent_dept'] as int?,
      deptCode: json['dept_code']?.toString(),
      deptName: json['dept_name']?.toString() ?? '',
      deptShortName: json['dept_short_name']?.toString(),
      deptType: json['dept_type']?.toString() ?? '',
      allowAssignment: json['allow_assignment'] == true || json['allow_assignment'] == 1,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at']?.toString() ?? '',
      updatedAt: json['updated_at']?.toString() ?? '',
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (departmentId != null) 'department_id': departmentId,
      if (parentDeptId != null) 'parent_dept': parentDeptId,
      if (deptCode != null) 'dept_code': deptCode,
      'dept_name': deptName,
      if (deptShortName != null) 'dept_short_name': deptShortName,
      'dept_type': deptType,
      'allow_assignment': allowAssignment,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      if (createdBy != null) 'created_by': createdBy,
      if (updatedBy != null) 'updated_by': updatedBy,
    };
  }
}


class Branch {
  final int branchId;
  final int countryId;
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
    required this.branchId,
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
    // Handle nested country object
    int getCountryId(dynamic value) {
      if (value == null) return 0;
      if (value is int) return value;
      if (value is Map) return value['country_id'] ?? value['id'] ?? 0;
      return 0;
    }

    String? getCountryName(dynamic value) {
      if (value == null) return null;
      if (value is String) return value;
      if (value is Map) return value['country_name']?.toString();
      return null;
    }

    return Branch(
      branchId: json['branch_id'] as int? ?? 0,
      countryId: getCountryId(json['country'] ?? json['country_id']),
      countryName: getCountryName(json['country'] ?? json['country_name']),
      branchCode: json['branch_code']?.toString(),
      branchName: json['branch_name']?.toString() ?? '',
      region: json['region']?.toString(),
      city: json['city']?.toString(),
      address: json['address']?.toString(),
      phone: json['phone']?.toString(),
      email: json['email']?.toString(),
      postalCode: json['postal_code'] as int?,
      isActive: json['is_active'] == true || json['is_active'] == 1,
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
      createdBy: json['created_by']?.toString(),
      updatedBy: json['updated_by']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'branch_id': branchId,
      'country_id': countryId,
      if (branchCode != null) 'branch_code': branchCode,
      'branch_name': branchName,
      if (region != null) 'region': region,
      if (city != null) 'city': city,
      if (address != null) 'address': address,
      if (phone != null) 'phone': phone,
      if (email != null) 'email': email,
      if (postalCode != null) 'postal_code': postalCode,
      'is_active': isActive,
    };
  }
}


class Currency {
  final int? currencyId;
  final String? currencyCode;
  final String? currencyName;
  final String? currencySymbol;
  final int? decimalPlaces;
  final double? exchangeRate;
  final bool isFunctionalCurrency;
  final bool isPresentationCurrency;
  final bool allowTransactionCurrency;
  final bool isActive;
  final String? transactionCurrency;
  final String? functionalCurrency;
  final double? amountRoundingPrecision;
  final double? depreciationRounding;
  final double? depreciationRoundingAlternate;

  Currency({
    this.currencyId,
    this.currencyCode,
    this.currencyName,
    this.currencySymbol,
    this.decimalPlaces,
    this.exchangeRate,
    this.isFunctionalCurrency = false,
    this.isPresentationCurrency = false,
    this.allowTransactionCurrency = false,
    this.isActive = true,
    this.transactionCurrency,
    this.functionalCurrency,
    this.amountRoundingPrecision,
    this.depreciationRounding,
    this.depreciationRoundingAlternate,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      currencyId: json['currency_id'] as int? ?? json['id'] as int?,
      currencyCode: json['currency_code']?.toString(),
      currencyName: json['currency_name']?.toString(),
      currencySymbol: json['currency_symbol']?.toString(),
      decimalPlaces: json['decimal_places'] as int?,
      exchangeRate: json['exchange_rate'] != null 
          ? double.tryParse(json['exchange_rate'].toString()) 
          : null,
      isFunctionalCurrency: json['is_functional_currency'] == true,
      isPresentationCurrency: json['is_presentation_currency'] == true,
      allowTransactionCurrency: json['allow_transaction_currency'] == true,
      isActive: json['is_active'] == true,
      transactionCurrency: json['transaction_currency']?.toString(),
      functionalCurrency: json['functional_currency']?.toString(),
      amountRoundingPrecision: json['amount_rounding_precision'] != null 
          ? double.tryParse(json['amount_rounding_precision'].toString()) 
          : null,
      depreciationRounding: json['depreciation_rounding'] != null 
          ? double.tryParse(json['depreciation_rounding'].toString()) 
          : null,
      depreciationRoundingAlternate: json['depreciation_rounding_alternate'] != null           ? double.tryParse(json['depreciation_rounding_alternate'].toString()) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (currencyId != null) 'currency_id': currencyId,
      if (currencyCode != null) 'currency_code': currencyCode,
      if (currencyName != null) 'currency_name': currencyName,
      if (currencySymbol != null) 'currency_symbol': currencySymbol,
      if (decimalPlaces != null) 'decimal_places': decimalPlaces,
      if (exchangeRate != null) 'exchange_rate': exchangeRate,
      'is_functional_currency': isFunctionalCurrency,
      'is_presentation_currency': isPresentationCurrency,
      'allow_transaction_currency': allowTransactionCurrency,
      'is_active': isActive,
      if (transactionCurrency != null) 'transaction_currency': transactionCurrency,
      if (functionalCurrency != null) 'functional_currency': functionalCurrency,
      if (amountRoundingPrecision != null) 'amount_rounding_precision': amountRoundingPrecision,
      if (depreciationRounding != null) 'depreciation_rounding': depreciationRounding,
      if (depreciationRoundingAlternate != null) 'depreciation_rounding_alternate': depreciationRoundingAlternate,
    };
  }
}
class PaginatedData<T> {
  final List<T> items;
  final int totalCount;

  PaginatedData({required this.items, required this.totalCount});
}