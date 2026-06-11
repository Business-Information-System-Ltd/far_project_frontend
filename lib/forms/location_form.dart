import 'dart:convert';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:far_project_frontend/api/data.dart';

class LocationRegisterForm extends StatefulWidget {
  final Location? location; // Edit 
  const LocationRegisterForm({super.key, this.location});
  
  @override
  State<LocationRegisterForm> createState() => _LocationRegisterFormState();
}

class _LocationRegisterFormState extends State<LocationRegisterForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  
  // UI State Controls
  bool _addPhysicalAddress = true;
  bool _allowAssignment = true; // Default checked
  bool _isActive = true;        // Default active

  List<Location> _selectedParentLocations = [];
  Country? selectedCountry;
  String? selectedType;

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _regionStateController = TextEditingController();
  final TextEditingController _cityTownshipController = TextEditingController();
  final TextEditingController _line1Controller = TextEditingController();
  final TextEditingController _line2Controller = TextEditingController();
  final TextEditingController _gpsController = TextEditingController();
  

  late Future<List<Location>> _locationTableData;
  late Future<List<Country>> _countryTableData;

  final String baseUrl = "http://127.0.0.1:8000/api/v1/far";
  final TextStyle _textStyle = const TextStyle(fontSize: 13, color: Colors.black);
  
  
  
@override
void initState() {
 
  _locationTableData = fetchLocationsFromApi();
  _countryTableData = fetchCountriesFromApi();

  // Populate basic text fields immediately
  if (widget.location != null) {
    
    _codeController.text = widget.location!.locationCode ?? '';
    _nameController.text = widget.location!.locationName ?? '';
    _regionStateController.text = widget.location!.region ?? '';
    _cityTownshipController.text = widget.location!.city ?? '';
    _line1Controller.text = widget.location!.line1 ?? '';
    _line2Controller.text = widget.location!.line2 ?? '';
    _gpsController.text = widget.location!.gpsMapReference ?? '';
    
    selectedType = widget.location!.locationType;
    _isActive = widget.location!.isActive ?? true;
    _allowAssignment = widget.location!.allowAssetAssignment ?? true;

    // Trigger state population when APIs return
    _populateData();
  }
}

_populateData() async {
  final List<Location> locations = await _locationTableData;
  final List<Country> countries = await _countryTableData;

  if (!mounted) return;

  setState(() {
    if (widget.location?.parentLocation != null) {
      _selectedParentLocations = locations
          .where((loc) => loc.locationId == widget.location!.parentLocation)
          .toList();
    }

    if (widget.location?.countryId != null) {
      // ဒီနေရာမှာ orElse ကို null ပြန်ပေးပါ
      selectedCountry = countries.firstWhere(
        (c) => c.id == widget.location!.countryId,
        orElse: () => null as Country, 
      );
    }
  });
}
  Future<List<Location>> fetchLocationsFromApi() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/locations/'));
      return response.statusCode == 200 ? (jsonDecode(response.body) as List).map((json) => Location.fromJson(json)).toList() : [];
    } catch (_) { return []; }
  }

   Future<List<Country>> fetchCountriesFromApi() async {
  try {
    final response = await http.get(Uri.parse('$baseUrl/countries/'));
    
    if (response.statusCode == 200) {
      final Map<String, dynamic> rawData = jsonDecode(response.body);
      
      
      print("Form API Raw Data: $rawData");

       
      if (rawData.containsKey('results')) {
        final List<dynamic> results = rawData['results'];
        return results.map((json) => Country.fromJson(json)).toList();
      }
    }
    return [];
  } catch (e) {
    print('Error fetching countries in form: $e');
    return [];
  }
}
  Future<void> _handleSave() async {
  if (!_formKey.currentState!.validate()) return;
  
  setState(() => _isLoading = true);

  try {
    final locationData = Location(
      
      locationId: widget.location?.locationId, // Keep null if new
      locationCode: _codeController.text.trim(),
      locationName: _nameController.text.trim(),
      locationType: selectedType!,
      parentLocation: _selectedParentLocations.isNotEmpty ? _selectedParentLocations.first.locationId : null,
      countryId: selectedCountry?.id,
      region: _regionStateController.text.trim(),
      city: _cityTownshipController.text.trim(),
      line1: _line1Controller.text.trim(),
      line2: _line2Controller.text.trim(),
      gpsMapReference: _gpsController.text.trim(),
      allowAssetAssignment: _allowAssignment,
     
    );

    final apiService = ApiService();
    Location result;

    if (widget.location == null) {
      // CREATE
      result = await apiService.createLocation(locationData);
      
      //  Clear 
      _clearForm(); 
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Successfully created!'), backgroundColor: Colors.green));
      
    } else {
      // UPDATE: 
      result = await apiService.updateLocation(widget.location!.locationId!, locationData);
      
      
      if (!mounted) return;
      Navigator.pop(context, result); 
      ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Updated successfully!'), 
      backgroundColor: Colors.green
    )
  );
    }
    
  } catch (e) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}

// Form 
void _clearForm() {
  _codeController.clear();
  _nameController.clear();
  _regionStateController.clear();
  _cityTownshipController.clear();
  _line1Controller.clear();
  _line2Controller.clear();
  _gpsController.clear();
  setState(() {
    _allowAssignment = false;
    _isActive = true;
    selectedType = null;
    selectedCountry = null;
    _selectedParentLocations = [];
  });
}


  void _handleClear() {
    _formKey.currentState!.reset();
    setState(() {
      _codeController.clear(); _nameController.clear(); _regionStateController.clear();
      _cityTownshipController.clear(); _line1Controller.clear(); _line2Controller.clear();
      _gpsController.clear(); 
      _selectedParentLocations = []; 
      selectedCountry = null;
      selectedType = null; 
      _addPhysicalAddress = true; 
      _allowAssignment = true; 
      _isActive = true;
    });
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 650),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(color: Colors.white, border: Border.all(color: Colors.grey.shade200), borderRadius: BorderRadius.circular(8)),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Center(child: Text("Location Register Form", style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold))),
                  const SizedBox(height: 25),
                  
                  // Row 1
                  Row(children: [
                    Expanded(child: _buildTextFormField("Location Code", "Enter code", controller: _codeController, isRequired: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildTextFormField("Name", "Enter name", controller: _nameController, isRequired: true)),
                    const SizedBox(width: 12),
                    Expanded(child: _buildDropdownField("Type", ["WAREHOUSE", "OFFICE", "STORE", "FACTORY", "BRANCH"], hint: "Select type", value: selectedType, onChanged: (v) => setState(() => selectedType = v), isRequired: true)),
                  ]),
                  
                  const SizedBox(height: 16),
                  _buildLabelWithAsterisk("Parent Location", isRequired: false),
                  const SizedBox(height: 6),
                  FutureBuilder<List<Location>>(
                    future: _locationTableData,
                    builder: (context, snapshot) {
                      return // MultiSelectDialogField 
MultiSelectDialogField<Location>(
  initialValue: _selectedParentLocations, 
  items: (snapshot.data ?? []).map((loc) => MultiSelectItem(loc, loc.name)).toList(),
  listType: MultiSelectListType.CHIP,
  onConfirm: (values) => setState(() => _selectedParentLocations = values),
  buttonText: const Text("Select parent location"),
  // ...
);
                    },
                  ),

                  const SizedBox(height: 16),
                  Row(children: [
                     Expanded(child: _buildCountryDropdown()),
                     const SizedBox(width: 12),
                     Expanded(child: _buildTextFormField("Region/State", "Enter region", controller: _regionStateController, isRequired: true)),
                     const SizedBox(width: 12),
                     Expanded(child: _buildTextFormField("City/Township", "Enter city", controller: _cityTownshipController, isRequired: true)),
                  ]),

                  CheckboxListTile(
                    title: const Text("Add Physical Address", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                    value: _addPhysicalAddress,
                    onChanged: (v) => setState(() => _addPhysicalAddress = v!),
                    controlAffinity: ListTileControlAffinity.leading,
                    contentPadding: EdgeInsets.zero,
                  ),

                  if (_addPhysicalAddress) ...[
                    _buildTextFormField("Line 1", "Enter address line 1", controller: _line1Controller),
                    _buildTextFormField("Line 2", "Enter address line 2", controller: _line2Controller),
                    const SizedBox(height: 15),
                    _buildTextFormField("GPS/Map Reference", "Enter GPS or map reference", controller: _gpsController),
                  ],

                  // Final toggles
                 

//Allow Assignments
Row(
  children: [
    // Allow Assignment Checkbox
    Row(
      children: [
        Checkbox(
          value: _allowAssignment,
          onChanged: (v) => setState(() => _allowAssignment = v!),
          activeColor: Colors.deepPurple,
        ),
        const Text("Allow Assignment", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      ],
    ),
    
    
    const Spacer(), 

    // Status Switch
    const Text("Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    const SizedBox(width: 10),
    Switch(
      value: _isActive,
      onChanged: (v) => setState(() => _isActive = v),
      activeColor: Colors.deepPurple,
    ),
    Text(_isActive ? "Active" : "Inactive", style: const TextStyle(fontSize: 13)),
  ],
),



                  const SizedBox(height: 30),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    _buildActionButton("Save", isPrimary: true, onPressed: _isLoading ? () {} : _handleSave),
                    const SizedBox(width: 16),
                    _buildActionButton("Clear", isPrimary: false, onPressed: _handleClear),
                  ]),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextFormField(String label, String hint, {TextEditingController? controller, bool isRequired = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabelWithAsterisk(label, isRequired: isRequired),
      const SizedBox(height: 6),
      TextFormField(
        controller: controller,
        style: _textStyle,
        decoration: _buildInputDecoration(hint: hint),
        validator: (v) => (isRequired && (v == null || v.isEmpty)) ? "Required" : null,
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildDropdownField(String label, List<String> items, {required String hint, String? value, required ValueChanged<String?> onChanged, bool isRequired = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabelWithAsterisk(label, isRequired: isRequired),
      const SizedBox(height: 6),
      DropdownButtonFormField<String>(
        value: value,
        style: _textStyle,
        decoration: _buildInputDecoration(hint: hint),
        items: items.map((e) => DropdownMenuItem(value: e, child: Text(e, style: _textStyle))).toList(),
        onChanged: onChanged,
        validator: (v) => (isRequired && v == null) ? "Required" : null,
      ),
      const SizedBox(height: 12),
    ],
  );

 Widget _buildCountryDropdown() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildLabelWithAsterisk("Country", isRequired: true),
      const SizedBox(height: 6),
      FutureBuilder<List<Country>>(
        future: _countryTableData,
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const CircularProgressIndicator();
          
          final List<Country> countries = snapshot.data!;
          
          
          Country? currentValue;
          if (selectedCountry != null) {
            try {
              currentValue = countries.firstWhere((c) => c.id == selectedCountry!.id);
            } catch (e) {
              currentValue = null;
            }
          }

          return DropdownButtonFormField<Country>(
  isExpanded: true,
  
  value: (selectedCountry != null) 
      ? countries.firstWhere((c) => c.id == selectedCountry!.id, orElse: () => selectedCountry!) 
      : null,
  decoration: _buildInputDecoration(hint: 'Select Country'),
            style: _textStyle,
            
            items: countries.map((c) => DropdownMenuItem(
              value: c, 
              
              child: Text(c.name, style: _textStyle)
              
            )).toList(),
            onChanged: (Country? v) {
  setState(() {
    selectedCountry = v;
    print("Selected Country: ${v?.name}"); 
  });
},

            validator: (v) => v == null ? "Required" : null,
          );
        },
      ),
      const SizedBox(height: 12),
    ],
  );

  Widget _buildLabelWithAsterisk(String label, {required bool isRequired}) => RichText(
    text: TextSpan(text: label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black, fontSize: 13), 
    children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : []),
  );

  Widget _buildActionButton(String label, {required bool isPrimary, required VoidCallback onPressed}) => ElevatedButton(
    onPressed: onPressed,
    style: ElevatedButton.styleFrom(backgroundColor: isPrimary ? Colors.deepPurple : Colors.white, foregroundColor: isPrimary ? Colors.white : Colors.deepPurple, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 16)),
    child: Text(label, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
  );

  InputDecoration _buildInputDecoration({String? hint}) => InputDecoration(
    hintText: hint,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
  );
}