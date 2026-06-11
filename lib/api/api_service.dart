import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:far_project_frontend/api/data.dart';

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000/api/v1/far/';

  // Endpoints
  static final String departmentEndpoint = 'departments/';
  static final String branchEndpoint = 'branches/';
  static final String countryEndpoint = 'countries/';

 
  // For department
  
  Future<List<Department>> fetchDepartments() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + departmentEndpoint));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Department data : $data");
        print("${response.body}");
        print("${response.statusCode} ${response.reasonPhrase}");
        return data.map((json) => Department.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load departments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching departments: $e');
      rethrow;
    }
  }

  Future<Department> fetchDepartmentById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$departmentEndpoint$id/'));
      print("Department data ID: $id");
      print("${response.statusCode} ${response.reasonPhrase}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Department.fromJson(data);
      } else {
        throw Exception('Failed to load department: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching department: $e');
      rethrow;
    }
  }

  Future<Department> createDepartment(Department department) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + departmentEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(department.toJson()),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Department data : $data");
        print("${response.statusCode} ${response.reasonPhrase}");
        return Department.fromJson(data);
      } else {
        throw Exception('Failed to create department: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating department: $e');
      rethrow;
    }
  }

  Future<Department> updateDepartment(int id, Department department) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$departmentEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(department.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Updated data : $data");
        print("${response.statusCode} ${response.reasonPhrase}");
        return Department.fromJson(data);
      } else {
        throw Exception('Failed to update department: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating department: $e');
      rethrow;
    }
  }

  Future<Department> patchDepartment(int id, Map<String, dynamic> fieldsToUpdate) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$departmentEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fieldsToUpdate),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Patched data : $data");
        print("${response.statusCode} ${response.reasonPhrase}");
        return Department.fromJson(data);
      } else {
        throw Exception('Failed to patch department: ${response.statusCode}');
      }
    } catch (e) {
      print('Error patching department: $e');
      rethrow;
    }
  }

  Future<void> deleteDepartment(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$departmentEndpoint$id/'));
      if (response.statusCode == 204) {
        print("Deleted Department ID : $id");
        print("${response.statusCode} ${response.reasonPhrase}");
      } else {
        throw Exception('Failed to delete department: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting department: $e');
      rethrow;
    }
  }

  // BRANCH METHODS
  

  Future<List<Branch>> fetchBranches() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + branchEndpoint));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Branch data : $data");
        print("${response.body}");
        print("${response.statusCode} ${response.reasonPhrase}");
        return data.map((json) => Branch.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load branches: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching branches: $e');
      rethrow;
    }
  }

  Future<Branch> fetchBranchById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$branchEndpoint$id/'));
      print("Branch data ID: $id");
      print("${response.statusCode} ${response.reasonPhrase}");
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Branch.fromJson(data);
      } else {
        throw Exception('Failed to load branch: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching branch: $e');
      rethrow;
    }
  }

  // Future<Branch> createBranch(Branch branch) async {
  //   try {
  //     final response = await http.post(
  //       Uri.parse(baseUrl + branchEndpoint),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(branch.toJson()),
  //     );
  //     if (response.statusCode == 201) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       print("Branch data : $data");
  //       print("${response.statusCode} ${response.reasonPhrase} ${response.body}");
  //       return Branch.fromJson(data);
  //     } else {
  //       throw Exception('Failed to create branch: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error creating branch: $e');
  //     rethrow;
  //   }
  // }



  Future<Branch> createBranch(Branch branch) async {
  try {
    Map<String, dynamic> rawMap = branch.toJson();
    rawMap.remove('branch_id');
    rawMap['country_id'] = branch.countryId; 
    rawMap.remove('country');
    rawMap['is_active'] = branch.isActive;

    final response = await http.post(
      Uri.parse(baseUrl + branchEndpoint),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(rawMap),
    );
    
    if (response.statusCode == 201) {
      final Map<String, dynamic> data = json.decode(response.body);
      return Branch.fromJson(data);
    } else {
      print("Django Create Error Detail: ${response.body}");
      throw Exception('Failed to create branch: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error creating branch: $e');
    rethrow;
  }
}

  // Future<Branch> updateBranch(int id, Branch branch) async {
  //   try {
  //     final response = await http.put(
  //       Uri.parse('$baseUrl$branchEndpoint$id/'),
  //       headers: {'Content-Type': 'application/json'},
  //       body: json.encode(branch.toJson()),
  //     );
  //     if (response.statusCode == 200) {
  //       final Map<String, dynamic> data = json.decode(response.body);
  //       print("Updated data : $data");
  //       print("${response.statusCode} ${response.reasonPhrase}");
  //       return Branch.fromJson(data);
  //     } else {
  //       throw Exception('Failed to update branch: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error updating branch: $e');
  //     rethrow;
  //   }
  // }

  Future<Branch> updateBranch(Branch branch, int id) async {
  try {
    Map<String, dynamic> rawMap = branch.toJson();
    rawMap.remove('branch_id');
    rawMap['country_id'] = branch.countryId; 
    rawMap.remove('country'); 
    rawMap['is_active'] = branch.isActive;
    print("Sending Corrected JSON to Django: ${json.encode(rawMap)}");
    final response = await http.put(
      Uri.parse('$baseUrl$branchEndpoint$id/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode(rawMap),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      print("Updated successfully : $data");
      return Branch.fromJson(data);
    } else {
      print("Django Error Detail: ${response.body}");
      throw Exception('Failed to update branch: ${response.statusCode} - ${response.body}');
    }
  } catch (e) {
    print('Error updating branch: $e');
    rethrow;
  }
}

  Future<Branch> patchBranch(int id, Map<String, dynamic> fieldsToUpdate) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$branchEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fieldsToUpdate),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        print("Patched data : $data");
        print("${response.statusCode} ${response.reasonPhrase}");
        return Branch.fromJson(data);
      } else {
        throw Exception('Failed to patch branch: ${response.statusCode}');
      }
    } catch (e) {
      print('Error patching branch: $e');
      rethrow;
    }
  }

  Future<void> deleteBranch(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$branchEndpoint$id/'));
      if (response.statusCode == 204) {
        print("Deleted Branch ID : $id");
        print("${response.statusCode} ${response.reasonPhrase}");
      } else {
        throw Exception('Failed to delete branch: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting branch: $e');
      rethrow;
    }
  }

  //country
  Future<List<Country>> fetchCountries() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + countryEndpoint));
      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        print("Country data : $data");
        print("${response.statusCode} ${response.reasonPhrase}");
        return data.map((json) => Country.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load countries: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching countries: $e');
      rethrow;
    }
  }

  Future<Country> fetchCountryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$countryEndpoint$id/'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Country.fromJson(data);
      } else {
        throw Exception('Failed to load country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching country: $e');
      rethrow;
    }
  }

  Future<Country> createCountry(Country country) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + countryEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(country.toJson()),
      );
      if (response.statusCode == 201) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Country.fromJson(data);
      } else {
        throw Exception('Failed to create country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error creating country: $e');
      rethrow;
    }
  }

  Future<Country> updateCountry(int id, Country country) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$countryEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(country.toJson()),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Country.fromJson(data);
      } else {
        throw Exception('Failed to update country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error updating country: $e');
      rethrow;
    }
  }

  Future<Country> patchCountry(int id, Map<String, dynamic> fieldsToUpdate) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$countryEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fieldsToUpdate),
      );
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Country.fromJson(data);
      } else {
        throw Exception('Failed to patch country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error patching country: $e');
      rethrow;
    }
  }

  Future<void> deleteCountry(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$countryEndpoint$id/'));
      if (response.statusCode == 204) {
        print("Deleted Country ID : $id");
      } else {
        throw Exception('Failed to delete country: ${response.statusCode}');
      }
    } catch (e) {
      print('Error deleting country: $e');
      rethrow;
    }
  }

//pagination for branch
Future<PaginatedData<Branch>> getBranchesPaginated({
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$branchEndpoint?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> itemsJson = json['items'];
      final List<Branch> branches = itemsJson
          .map((j) => Branch.fromJson(j))
          .toList();
      return PaginatedData<Branch>(items: branches, totalCount: json['total']);
    } else {
      throw Exception('Failed to load branches');
    }
  }

  //pagination for department
  Future<PaginatedData<Department>> getDepartmentsPaginated({
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$departmentEndpoint?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> itemsJson = json['items'];
      final List<Department> departments = itemsJson
          .map((j) => Department.fromJson(j))
          .toList();
      return PaginatedData<Department>(items: departments, totalCount: json['total']);
    } else {
      throw Exception('Failed to load branches');
    }
  }
 
}