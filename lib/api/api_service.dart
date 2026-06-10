import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/v1/far/";
  final String custodianEndpoint = 'custodians/';
  static final String departmentEndpoint = 'departments/';
  static final String branchEndpoint = 'branches/';
  static final String currencyEndpoint = 'currencies/';

  Future<Map<String, List<Map<String, dynamic>>>> fetchAllDropdowns() async {
    try {
      final results = await Future.wait([
        http.get(Uri.parse('$baseUrl$branchEndpoint')).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse('$baseUrl$departmentEndpoint')).timeout(const Duration(seconds: 5)),
        http.get(Uri.parse('$baseUrl${custodianEndpoint}types/')).timeout(const Duration(seconds: 5)),
      ]);

      List<Map<String, dynamic>> departments = [];
      if (results[1].statusCode == 200) {
        final deptData = json.decode(results[1].body);
        if (deptData is Map && deptData.containsKey('results')) {
          departments = List<Map<String, dynamic>>.from(deptData['results']);
        } else if (deptData is List) {
          departments = List<Map<String, dynamic>>.from(deptData);
        }
      }

      return {
        'branches': results[0].statusCode == 200 
            ? List<Map<String, dynamic>>.from(json.decode(results[0].body)) 
            : [],
        'depts': departments,
        'types': results[2].statusCode == 200 
            ? List<Map<String, dynamic>>.from(json.decode(results[2].body)) 
            : [],
      };
    } catch (e) {
      print('Error fetching dropdowns: $e');
      return {'branches': [], 'depts': [], 'types': []};
    }
  }

  Future<Custodian> createCustodian(Custodian custodian) async {
    try {
      final payload = custodian.toJson();
      print('=== CREATE CUSTODIAN ===');
      print('Payload: ${json.encode(payload)}');
      
      final response = await http.post(
        Uri.parse('$baseUrl$custodianEndpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(payload),
      ).timeout(const Duration(seconds: 10));

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Created Custodian: $data");
        return Custodian.fromJson(data);
      } else {
        throw Exception('Failed to create Custodian: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Error creating Custodian: $e');
      rethrow;
    }
  }

  Future<bool> updateCustodian(int id, Map<String, dynamic> data) async {
    try {
      print('=== UPDATE CUSTODIAN ===');
      print('ID: $id');
      print('Payload: ${jsonEncode(data)}');
      
      final response = await http.put(
        Uri.parse('$baseUrl$custodianEndpoint$id/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      
      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');
      
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating custodian: $e');
      return false;
    }
  }

  Future<List<Custodian>> fetchCustodians() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$custodianEndpoint'));
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((item) => Custodian.fromJson(item))
              .toList();
        } else if (data is List) {
          return data.map((item) => Custodian.fromJson(item)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching custodians: $e");
      return [];
    }
  }

  Future<List<Branch>> fetchBranches() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + branchEndpoint));
    
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((json) => Branch.fromJson(json))
              .toList();
        } else if (data is List) {
          return data.map((json) => Branch.fromJson(json)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching branches: $e');
      return [];
    }
  }

  Future<List<Department>> fetchDepartments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + departmentEndpoint));
    
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        List<dynamic> data;
        
        if (jsonData is Map && jsonData.containsKey('results')) {
          data = jsonData['results'];
        } else if (jsonData is List) {
          data = jsonData;
        } else {
          return [];
        }
        
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        return [];
      }
    } catch (e) {
      print('Error fetching departments: $e');
      return [];
    }
  }

  Future<List<Currency>> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$currencyEndpoint'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is Map && data.containsKey('results')) {
          return (data['results'] as List)
              .map((item) => Currency.fromJson(item))
              .toList();
        } else if (data is List) {
          return data.map((item) => Currency.fromJson(item)).toList();
        }
        return [];
      } else {
        return [];
      }
    } catch (e) {
      print("Error fetching currencies: $e");
      return [];
    }
  }

  Future<bool> updateCurrency(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$currencyEndpoint$id/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating currency: $e');
      return false;
    }
  }

  Future<PaginatedData<Custodian>> getCustodiansPaginated({
    required int page,
    required int limit,
    String? search,
    String? type,
    bool? isActive,
  }) async {
    try {
      final params = <String, String>{
        'page': page.toString(),
        'limit': limit.toString(),
      };
      if (search != null && search.isNotEmpty) params['search'] = search;
      if (type != null && type.isNotEmpty) params['custodian_type'] = type;
      if (isActive != null) params['is_active'] = isActive.toString();
      
      final uri = Uri.parse('$baseUrl$custodianEndpoint').replace(queryParameters: params);
      final response = await http.get(uri).timeout(const Duration(seconds: 10));

      print('Custodians Paginated response: ${response.statusCode}');
      print('Custodians Paginated body: ${response.body}');

      if (response.statusCode == 200) {
        final json = jsonDecode(response.body);
        
        List<dynamic> itemsJson;
        int totalCount;
        
        if (json.containsKey('results')) {
          itemsJson = json['results'];
          totalCount = json['count'] ?? 0;
        } else if (json.containsKey('items')) {
          itemsJson = json['items'];
          totalCount = json['total'] ?? 0;
        } else if (json is List) {
          itemsJson = json;
          totalCount = json.length;
        } else {
          itemsJson = [];
          totalCount = 0;
        }
        
        final List<Custodian> custodians = itemsJson
            .map((j) => Custodian.fromJson(j))
            .toList();
            
        return PaginatedData<Custodian>(
          items: custodians, 
          totalCount: totalCount,
        );
      } else {
        throw Exception('Failed to load custodians: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching paginated custodians: $e');
      return PaginatedData<Custodian>(items: [], totalCount: 0);
    }
  }
}