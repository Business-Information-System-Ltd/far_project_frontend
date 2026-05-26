import 'dart:convert';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; 

class AddBranchForm extends StatefulWidget {
  final Branch? branch; 

  const AddBranchForm({super.key, this.branch});

  @override
  State<AddBranchForm> createState() => _AddBranchFormState();
}

class _AddBranchFormState extends State<AddBranchForm> {
  final _formKey = GlobalKey<FormState>();
  bool _isActive = true; 
  
  int? selectedCountryId;
  String? selectedCountryName;
  List<Country> _countries = [];
  bool _isLoading = true; 

  final _branchCodeController = TextEditingController();
  final _branchNameController = TextEditingController();
  final _regionController = TextEditingController();
  final _cityController = TextEditingController();
  final _addressController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();

  final List<String> _existingBranchCodes = ['BR-001', 'BR-002', 'HQ-999'];

  @override
  void initState() {
    super.initState();
    _fetchData(); 
    

    
    if (widget.branch != null) {
      _branchCodeController.text = widget.branch!.branchCode ?? '';
      _branchNameController.text = widget.branch!.branchName ?? '';
      _regionController.text = widget.branch!.region ?? '';
      _cityController.text = widget.branch!.city ?? '';
      _addressController.text = widget.branch!.address ?? '';
      _postalCodeController.text = widget.branch!.postalCode?.toString() ?? '';
      _phoneController.text = widget.branch!.phone ?? '';
      _emailController.text = widget.branch!.email ?? '';
      _isActive = widget.branch!.isActive;
      selectedCountryId = widget.branch!.countryId;
      
    }
  }

  void _fetchData() async {
    final ApiService apiService = ApiService();
    try {
      List<Country> countries = await apiService.fetchCountries();
      setState(() {
        _countries = countries;
        _isLoading = false; 
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching countries in UI: $e');
    }
  }

  @override
  void dispose() {
    _branchCodeController.dispose();
    _branchNameController.dispose();
    _regionController.dispose();
    _cityController.dispose();
    _addressController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _branchCodeController.clear();
    _branchNameController.clear();
    _regionController.clear();
    _cityController.clear();
    _addressController.clear();
    _postalCodeController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      selectedCountryName = null;
      selectedCountryId = null;
      _isActive = true; 
    });
  }

  
  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    int? parsedPostalCode;
    if (_postalCodeController.text.trim().isNotEmpty) {
      parsedPostalCode = int.tryParse(_postalCodeController.text.trim());
    }

    final ApiService apiService = ApiService();

    try {
      if (widget.branch == null) {
       
        final newBranch = Branch(
          countryId: selectedCountryId, 
          branchCode: _branchCodeController.text.trim(),
          branchName: _branchNameController.text.trim(),
          region: _regionController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          postalCode: parsedPostalCode,
          isActive: _isActive,
        );

        Branch savedBranch = await apiService.createBranch(newBranch);
        
        if (context.mounted) {
          Navigator.pop(context, savedBranch); 
        }
      } else {
       
      
        final updatedBranch = Branch(
          branchId: widget.branch!.branchId, 
          countryId: selectedCountryId,
          branchCode: widget.branch!.branchCode, 
          branchName: _branchNameController.text.trim(),
          region: _regionController.text.trim(),
          city: _cityController.text.trim(),
          address: _addressController.text.trim(),
          phone: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          postalCode: parsedPostalCode,
          isActive: _isActive,
        );

        
        final result = await apiService.updateBranch(widget.branch!.branchId!, updatedBranch);
        
        if (context.mounted) {
          Navigator.pop(context, result);
        }
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center( 
      child: Card(
        elevation: 2, 
        color: Colors.white, 
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade200),
        ),
        margin: const EdgeInsets.all(16), 
        child: Container(
          constraints: const BoxConstraints(maxWidth: 650),
          padding: const EdgeInsets.all(24.0), 
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction, 
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Text(
                      widget.branch == null ? 'Add Branch Form' : 'Edit Branch Form',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Row 1
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Branch Code', 
                          'Enter branch code', 
                          controller: _branchCodeController,
                          enabled: widget.branch == null, 
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'This field cannot be null';
                            if (widget.branch == null && _existingBranchCodes.contains(value.trim())) {
                              return 'Duplicate branch code found';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'Branch Name', 
                          'Enter branch name', 
                          controller: _branchNameController,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'This field cannot be null';
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 2
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildDropdownField('Country', 'Select country')),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInputField('Region/State', 'Enter Region/State', controller: _regionController)),
                      const SizedBox(width: 12),
                      Expanded(child: _buildInputField('City / Township', 'Enter city / Township', controller: _cityController)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 3
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        flex: 2, 
                        child: _buildInputField('Address', 'Enter address details', controller: _addressController),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        flex: 1, 
                        child: _buildInputField(
                          'Postal Code', 
                          'Enter postal code', 
                          controller: _postalCodeController,
                          keyboardType: TextInputType.number,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) return 'This field cannot be null';
                            if (!RegExp(r'^[0-9]+$').hasMatch(value.trim())) return 'Numbers only'; 
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Row 4
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Phone Number', 
                          'Enter phone number', 
                          controller: _phoneController, 
                          keyboardType: TextInputType.phone,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _buildInputField(
                          'Email Address', 
                          'Enter branch address', 
                          controller: _emailController, 
                          keyboardType: TextInputType.emailAddress,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Status Switch
                  Row(
                    children: [
                      const Text('Status', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                      const SizedBox(width: 4),
                      Transform.scale(
                        scale: 0.75, 
                        child: Switch(
                          value: _isActive,
                          activeColor: Colors.deepPurple,
                          onChanged: (value) {
                            setState(() {
                              _isActive = value;
                            });
                          },
                        ),
                      ),
                      Text(_isActive ? 'Active' : 'Inactive', style: const TextStyle(fontSize: 13)),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, 
                    children: [
                      ElevatedButton(
                        onPressed: _isLoading ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: _isLoading 
                          ? const SizedBox(height: 16, width: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                          : const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _isLoading ? null : _clearForm,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.grey.shade700,
                          side: BorderSide(color: Colors.grey.shade300),
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: const Text('Clear', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String hint, {
    TextEditingController? controller,
    TextInputType keyboardType = TextInputType.text,
    FormFieldValidator<String>? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
            children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          enabled: enabled,
          style: const TextStyle(fontSize: 13),
          validator: validator ?? (value) => (value == null || value.trim().isEmpty) ? 'This field cannot be null' : null,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
            contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8), 
            fillColor: enabled ? Colors.white : Colors.grey.shade100,
            filled: !enabled,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.deepPurple, width: 1.2)),
            errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red, width: 1)),
            focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red, width: 1.2)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(String label, String hint) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
            children: const [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 4),
        
        _isLoading 
          ? const Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0),
              child: SizedBox(
                height: 18,
                width: 18,
                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
              ),
            )
          : DropdownButtonFormField<Country>( 
              isExpanded: true, 
              decoration: InputDecoration(
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6.0)),
                enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400, width: 1.0)),
                focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.deepPurple, width: 2.0)),
                errorBorder: const OutlineInputBorder(borderSide: BorderSide(color: Colors.red, width: 1.0)),
              ),
              value: selectedCountryId != null && _countries.any((c) => c.countryId == selectedCountryId)
                  ? _countries.firstWhere((c) => c.countryId == selectedCountryId) 
                  : null, 
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
              style: const TextStyle(fontSize: 13, color: Colors.black87),
              validator: (value) => value == null ? 'This field cannot be null' : null,
              items: _countries.map((Country country) {
                return DropdownMenuItem<Country>(
                  value: country, 
                  child: Text(country.countryName), 
                );
              }).toList(),
              onChanged: (Country? value) {
                if (value != null) {
                  setState(() {
                    selectedCountryId = value.countryId;  
                    selectedCountryName = value.countryName; 
                  });
                }
              },
            )
      ],
    );
  }
}

