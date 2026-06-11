import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:far_project_frontend/api/data.dart';

class ApiService {
  static String baseUrl = 'http://127.0.0.1:8000/api/v1/far/';

  // Endpoints
  static final String countryEndpoint = 'countries/';
  static final String locationEndpoint = 'locations/';

  /// Generic handler to reduce repeated code for JSON decoding and status checks
  dynamic _handleResponse(http.Response response, int successCode, String actionName) {
    print("$actionName status: ${response.statusCode} ${response.reasonPhrase}");
    if (response.statusCode == successCode) {
      if (response.body.isEmpty) return null;
      try {
        return json.decode(response.body);
      } catch (e) {
        print("JSON Decode Error in $actionName: $e");
        return null;
      }
    } else {
      throw Exception('Failed to $actionName: ${response.statusCode}');
    }
  }

  
  // COUNTRY METHODS
  Future<List<Country>> fetchCountries() async {
  try {
    final response = await http.get(Uri.parse(baseUrl + countryEndpoint));
    final rawData = _handleResponse(response, 200, 'Fetch Countries');
    
    // Debug အတွက်
    print("API Raw Data Type: ${rawData.runtimeType}"); 

    // 1. API က Object ({...}) ပုံစံနဲ့ ပို့ရင် 'results' key ထဲကို ဝင်ပါ
    if (rawData is Map<String, dynamic> && rawData.containsKey('results')) {
      final List<dynamic> results = rawData['results'];
      return results.map((json) => Country.fromJson(json)).toList();
    } 
    // 2. API က List ([...]) ပုံစံနဲ့ ပို့ရင် တိုက်ရိုက်လုပ်ပါ
    else if (rawData is List) { 
      return rawData.map((json) => Country.fromJson(json)).toList();
    }
    
    return []; 
  } catch (e) {
    print('Error fetching countries: $e');
    rethrow;
  }
}

  Future<Country> fetchCountryById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$countryEndpoint$id/'));
      final data = _handleResponse(response, 200, 'Fetch Country ID: $id');
      if (data == null) throw Exception('Country data is null');
      return Country.fromJson(data);
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
      final data = _handleResponse(response, 201, 'Create Country');
      return Country.fromJson(data);
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
      final data = _handleResponse(response, 200, 'Update Country ID: $id');
      return Country.fromJson(data);
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
      final data = _handleResponse(response, 200, 'Patch Country ID: $id');
      return Country.fromJson(data);
    } catch (e) {
      print('Error patching country: $e');
      rethrow;
    }
  }

  Future<void> deleteCountry(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$countryEndpoint$id/'));
      _handleResponse(response, 204, 'Delete Country ID: $id');
    } catch (e) {
      print('Error deleting country: $e');
      rethrow;
    }
  }

  Future<PaginatedData<Country>> getCountriesPaginated({
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$countryEndpoint?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> itemsJson = json['items'];
      final List<Country> countries = itemsJson
          .map((j) => Country.fromJson(j))
          .toList();
      return PaginatedData<Country>(items: countries, totalCount: json['total']);
    } else {
      throw Exception('Failed to load countries');
    }
  }


 
  // LOCATION METHODS

  Future<List<Location>> fetchLocations() async {
    try {
      final response = await http.get(Uri.parse(baseUrl + locationEndpoint));
      final rawData = _handleResponse(response, 200, 'Fetch Locations');
      
      print("Location data : $rawData");
      
      
      if (rawData is List) {
        return rawData.map((json) => Location.fromJson(json)).toList();
      }
      
      return []; 
    } catch (e) {
      print('Error fetching locations: $e');
      rethrow;
    }
  }

  Future<Location> fetchLocationById(int id) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl$locationEndpoint$id/'));
      final data = _handleResponse(response, 200, 'Fetch Location ID: $id');
      if (data == null) throw Exception('Location data is null');
      return Location.fromJson(data);
    } catch (e) {
      print('Error fetching location: $e');
      rethrow;
    }
  }

  Future<Location> createLocation(Location location) async {
    try {
      final response = await http.post(
        Uri.parse(baseUrl + locationEndpoint),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson()),
        
      );
      print('${response.statusCode} ${response.body}');
      final data = _handleResponse(response, 201, 'Create Location');
      return Location.fromJson(data);
    } catch (e) {
      print('Error creating location: $e');
      rethrow;
    }
  }

  Future<Location> updateLocation(int id, Location location) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl$locationEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(location.toJson()),
      );
      final data = _handleResponse(response, 200, 'Update Location ID: $id');
      return Location.fromJson(data);
    } catch (e) {
      print('Error updating location: $e');
      rethrow;
    }
  }

  Future<Location> patchLocation(int id, Map<String, dynamic> fieldsToUpdate) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$locationEndpoint$id/'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(fieldsToUpdate),
      );
      final data = _handleResponse(response, 200, 'Patch Location ID: $id');
      return Location.fromJson(data);
    } catch (e) {
      print('Error patching location: $e');
      rethrow;
    }
  }

  Future<void> deleteLocation(int id) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$locationEndpoint$id/'));
      _handleResponse(response, 204, 'Delete Location ID: $id');
    } catch (e) {
      print('Error deleting location: $e');
      rethrow;
    }
  }
  Future<PaginatedData<Location>> getLocationsPaginated({
    required int page,
    required int limit,
  }) async {
    final response = await http.get(
      Uri.parse('$baseUrl$locationEndpoint?page=$page&limit=$limit'),
    );
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final List<dynamic> itemsJson = json['items'];
      final List<Location> locations = itemsJson
          .map((j) => Location.fromJson(j))
          .toList();
      return PaginatedData<Location>(items: locations, totalCount: json['total']);
    } else {
      throw Exception('Failed to load locations');
    }
  }
}