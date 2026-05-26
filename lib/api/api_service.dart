import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'data.dart';

class ApiService {
  static const String baseUrl = "http://127.0.0.1:8000/api/far/v1/";
  final String custodianEndpoint = 'custodians/';
  static final String departmentEndpoint = 'departments/';
  static final String branchEndpoint = 'branches/';
  static final String currencyEndpoint = 'currencies/';

  // Fixed fetchAllDropdowns()
  Future<Map<String, List<Map<String, dynamic>>>> fetchAllDropdowns() async {
    final results = await Future.wait([
      http.get(Uri.parse('$baseUrl$branchEndpoint')).timeout(const Duration(seconds: 5)),
      http.get(Uri.parse('$baseUrl$departmentEndpoint')).timeout(const Duration(seconds: 5)),
      http.get(Uri.parse('$baseUrl$custodianEndpoint')).timeout(const Duration(seconds: 5)),
    ]);

    return {
      'branches': results[0].statusCode == 200 
          ? List<Map<String, dynamic>>.from(json.decode(results[0].body)) 
          : [],
      'depts': results[1].statusCode == 200 
          ? List<Map<String, dynamic>>.from(json.decode(results[1].body)) 
          : [],
      'types': results[2].statusCode == 200 
          ? List<Map<String, dynamic>>.from(json.decode(results[2].body)) 
          : [],
    };
  }

  // Fixed createCustodian()
  Future<Custodian> createCustodian(Custodian custodian) async {
    try {
      final payload = custodian.toJson();
      print('Sending payload: ${json.encode(payload)}');
      
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

  Future<List<Custodian>> fetchCustodians() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$custodianEndpoint'));
      print("Backend send raw data: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Custodian.fromJson(item)).toList();
      } else {
        print("Custodian Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching custodians: $e");
      return [];
    }
  }

  Future<List<Currency>> fetchCurrencies() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$currencyEndpoint'));

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((dynamic item) => Currency.fromJson(item)).toList();
      } else {
        print("Currency Server Error: ${response.statusCode}");
        return [];
      }
    } catch (e) {
      print("Error fetching currencies: $e");
      return [];
    }
  }
  
  Future<bool> updateCustodian(int id, Map<String, dynamic> data) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$custodianEndpoint$id/'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(data),
      );
      return response.statusCode == 200 || response.statusCode == 204;
    } catch (e) {
      print('Error updating custodian: $e');
      return false;
    }
  }

  Future<List<Department>> fetchDepartments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + departmentEndpoint));
      print('Department response status: ${response.statusCode}');
      print('Department response body: ${response.body}');
    
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching departments: $e');
      rethrow;
    }
  }

  Future<List<Branch>> fetchBranches() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + branchEndpoint));
      print('Branch response status: ${response.statusCode}');
      print('Branch response body: ${response.body}');
    
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching branches: $e');
      rethrow;
    }
  }
}