
import 'dart:convert';

class Custodian {
  final int? id;
  final String code;
  final String name;
  final String type;
  final String email;
  final String phNo;
  final int deptName;
  final int branch;
  final bool can_hold_assets;
  final bool isActive;

  Custodian({
    this.id,
    required this.code,
    required this.name,
    required this.type,
    required this.email,
    required this.phNo,
    required this.deptName,
    required this.branch,
    required this.can_hold_assets,
    this.isActive = true,
  });

  factory Custodian.fromJson(Map<String, dynamic> json) {
    return Custodian(
      id: json['custodian_id'] as int?,
      code: json['custodian_code']?.toString() ?? json['code']?.toString() ?? '',
      name: json['custodian_name']?.toString() ?? json['name']?.toString() ?? '',
      type: json['custodian_type']?.toString() ?? json['type']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      phNo: json['phone']?.toString() ?? '-',
      deptName: json['department'] as int? ?? 0,
      branch: json['branch'] as int? ?? 0,
      can_hold_assets: json['can_hold_assets'] == true,
      isActive: json['is_active'] == true || json['status'] == 'Active',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'custodian_code': code,
      'custodian_name': name,
      'custodian_type': type,
      'email': email,
      'phone': phNo,
      'department': deptName,
      'branch': branch,
      'can_hold_assets': can_hold_assets,
      'is_active': isActive,
    };
  }
  
  Map<String, dynamic> toJsonWithId() {
    return {
      'custodian_id': id,
      'custodian_code': code,
      'custodian_name': name,
      'custodian_type': type,
      'email': email,
      'phone': phNo,
      'department': deptName,
      'branch': branch,
      'can_hold_assets': can_hold_assets,
      'is_active': isActive,
    };
  }
}

class Department {
  final int? departmentId;
  final int? parentDeptId;
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
    required this.departmentId,
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
    return Department(
      departmentId: json['department_id'] as int?,
      parentDeptId: json['parent_dept'] as int?,
      deptCode: json['dept_code']?.toString(),
      deptName: json['dept_name']?.toString() ?? '',
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
      'department_id': departmentId,
      'parent_dept': parentDeptId,
      'dept_code': deptCode,
      'dept_name': deptName,
      'dept_type': deptType,
      'allow_assignment': allowAssignment,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'created_by': createdBy,
      'updated_by': updatedBy,
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
    return Branch(
      branchId: json['branch_id'] as int? ?? 0,
      countryId: json['country_id'] as int? ?? 0,
      countryName: json['country_name']?.toString(),
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
}

class Currency {
  final int? currencyId;
  final String? currencyCode;
  final String? currencyName;
  final String? currencySymbol;
  final int? decimalPlaces;
  final double? exchangeRate;
  final bool? isFunctionalCurrency;
  final bool? isPresentationCurrency;
  final bool? allowTransactionCurrency;
  final bool? isActive;
  final String? transactionCurrency;
  final String? functionalCurrency;

  Currency({
    this.currencyId,
    this.currencyCode,
    this.currencyName,
    this.currencySymbol,
    this.decimalPlaces,
    this.exchangeRate,
    this.isFunctionalCurrency,
    this.isPresentationCurrency,
    this.allowTransactionCurrency,
    this.isActive,
    this.transactionCurrency,
    this.functionalCurrency,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      currencyId: json['id'] as int?,
      currencyCode: json['currency_code']?.toString(),
      currencyName: json['currency_name']?.toString(),
      currencySymbol: json['currency_symbol']?.toString(),
      decimalPlaces: json['decimal_places'] as int?,
      exchangeRate: json['exchange_rate'] != null 
          ? double.tryParse(json['exchange_rate'].toString()) 
          : null,
      isFunctionalCurrency: json['is_functional_currency'] as bool?,
      isPresentationCurrency: json['is_presentation_currency'] as bool?,
      allowTransactionCurrency: json['allow_transaction_currency'] as bool?,
      isActive: json['is_active'] as bool?,
      transactionCurrency: json['transaction_currency'] ?? json['transactionCurrency'] ?? '-',
      functionalCurrency: json['functional_currency'] ?? json['functionalCurrency'] ?? '-',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': currencyId,
      'currency_code': currencyCode,
      'currency_name': currencyName,
      'currency_symbol': currencySymbol,
      'exchange_rate': exchangeRate,
      'is_active': isActive,
    };
  }
}