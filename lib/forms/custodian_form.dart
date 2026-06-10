
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';
import 'package:flutter/material.dart';

class CustodianFormScreen extends StatefulWidget {
  final Custodian? custodian;
  const CustodianFormScreen({Key? key, this.custodian}) : super(key: key);

  @override
  State<CustodianFormScreen> createState() => _CustodianFormScreenState();
}

class _CustodianFormScreenState extends State<CustodianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final ApiService _apiService = ApiService();

  final TextEditingController _codeController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  String? _selectedType;
  int? _selectedBranchId;
  int? _selectedDeptId;

  bool _canHoldAssets = true;
  bool _isActive = true;
  bool _isLoadingData = true;
  bool _isSaving = false;
  bool _isEditMode = false;

  List<Branch> _branchList = [];
  List<Department> _deptList = [];
  final List<String> _typeList = ['Employee', 'Department', 'External Party'];

  @override
  void initState() {
    super.initState();
    _isEditMode = widget.custodian != null;
    
    _loadData();
  }

  void _fillOldData() {
    final c = widget.custodian!;
    
    _codeController.text = c.code;
    _nameController.text = c.name;
    _phoneController.text = c.phNo;
    _emailController.text = c.email;
    
    setState(() {
      _selectedType = c.type;
      _selectedBranchId = c.branchId;
      _selectedDeptId = c.deptId == 0 ? null : c.deptId;
      _canHoldAssets = c.canHoldAssets;
      _isActive = c.isActive;
    });
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);
    try {
      final branches = await _apiService.fetchBranches();
      final departments = await _apiService.fetchDepartments();
      
      setState(() {
        _branchList = branches;
        _deptList = departments;
        _isLoadingData = false;
      });
      
      if (_isEditMode) {
        _fillOldData();
      }
      
    } catch (e) {
      setState(() => _isLoadingData = false);
      _showSnackbar('Failed to load data: $e', Colors.red);
    }
  }

  Future<void> _saveData() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedType == null) {
      _showSnackbar('Please select custodian type', Colors.red);
      return;
    }
    if (_selectedBranchId == null) {
      _showSnackbar('Please select branch', Colors.red);
      return;
    }
    if (_selectedDeptId == null) {
      _showSnackbar('Please select department', Colors.red);
      return;
    }

    setState(() => _isSaving = true);
    try {
      if (_isEditMode) {
        final payload = {
          'custodian_code': _codeController.text.trim(),
          'custodian_name': _nameController.text.trim(),
          'custodian_type': _selectedType,
          'phone': _phoneController.text.trim(),
          'email': _emailController.text.trim(),
          'dept': _selectedDeptId,
          'branch': _selectedBranchId,
          'can_hold_assets': _canHoldAssets,
          'is_active': _isActive,
        };
        
        final success = await _apiService.updateCustodian(widget.custodian!.id!, payload);
        if (success) {
          _showSnackbar('Custodian updated successfully', Colors.green);
          Navigator.pop(context, true);
        } else {
          _showSnackbar('Failed to update custodian', Colors.red);
        }
      } else {
        final newCustodian = Custodian(
          id: null,
          code: _codeController.text.trim(),
          name: _nameController.text.trim(),
          type: _selectedType!,
          branchId: _selectedBranchId!,
          deptId: _selectedDeptId!,
          phNo: _phoneController.text.trim(),
          email: _emailController.text.trim(),
          canHoldAssets: _canHoldAssets,
          isActive: _isActive,
        );
        
        await _apiService.createCustodian(newCustodian);
        _showSnackbar('Custodian created successfully!', Colors.green);
        Navigator.pop(context, true);
      }
    } catch (e) {
      _showSnackbar('Error: $e', Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  void _clearFormFields() {
    _codeController.clear();
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _selectedType = null;
      _selectedBranchId = null;
      _selectedDeptId = null;
      _canHoldAssets = true;
      _isActive = true;
    });
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color)
    );
  }

  @override
  void dispose() {
    _codeController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(_isEditMode ? 'Edit Custodian' : 'Add Custodian'),
        backgroundColor: const Color(0xFF1E56A0),
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: _isLoadingData
            ? const CircularProgressIndicator()
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: 650,
                  padding: const EdgeInsets.all(40),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 5,
                        blurRadius: 10,
                      )
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        Text(
                          _isEditMode ? 'Edit Custodian Form' : 'Add Custodian Form',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)
                        ),
                        const SizedBox(height: 32),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Custodian Code',
                                controller: _codeController,
                                hint: 'Enter custodian code',
                                isRequired: true,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildDropdownField<String>(
                                label: 'Custodian Type',
                                value: _selectedType,
                                hint: 'Select custodian type',
                                items: _typeList.map((type) {
                                  return DropdownMenuItem<String>(
                                    value: type,
                                    child: Text(type),
                                  );
                                }).toList(),
                                isRequired: true,
                                onChanged: (val) => setState(() => _selectedType = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        _buildTextField(
                          label: 'Custodian Name',
                          controller: _nameController,
                          hint: 'Enter custodian name',
                          isRequired: true,
                        ),
                        const SizedBox(height: 24),
                        const Divider(height: 1, color: Color(0xFFE2E8F0), thickness: 1),
                        const SizedBox(height: 32),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildDropdownField<int>(
                                label: 'Branch',
                                value: _selectedBranchId,
                                hint: 'Select branch',
                                items: _branchList.map<DropdownMenuItem<int>>((Branch branch) {
                                  return DropdownMenuItem<int>(
                                    value: branch.branchId,
                                    child: Text(branch.branchName),
                                  );
                                }).toList(),
                                isRequired: true,
                                onChanged: (val) => setState(() => _selectedBranchId = val),
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildDropdownField<int>(
                                label: 'Department',
                                value: _selectedDeptId,
                                hint: 'Select department',
                                items: _deptList.map<DropdownMenuItem<int>>((Department dept) {
                                  return DropdownMenuItem<int>(
                                    value: dept.departmentId,
                                    child: Text(dept.deptName),
                                  );
                                }).toList(),
                                isRequired: true,
                                onChanged: (val) => setState(() => _selectedDeptId = val),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: _buildTextField(
                                label: 'Phone Number',
                                controller: _phoneController,
                                hint: 'Enter phone number',
                                isRequired: true,
                                keyboardType: TextInputType.phone,
                              ),
                            ),
                            const SizedBox(width: 32),
                            Expanded(
                              child: _buildTextField(
                                label: 'Email Address',
                                controller: _emailController,
                                hint: 'Enter email address',
                                isRequired: true,
                                keyboardType: TextInputType.emailAddress,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 32),

                        Row(
                          children: [
                            Expanded(
                              child: Row(
                                children: [
                                  Checkbox(
                                    value: _canHoldAssets,
                                    activeColor: const Color(0xFF1E56A0),
                                    onChanged: (val) => setState(() => _canHoldAssets = val!),
                                  ),
                                  const Text('Can Hold Assets'),
                                ],
                              ),
                            ),
                            Expanded(
                              child: Row(
                                children: [
                                  const Text('Status'),
                                  const SizedBox(width: 16),
                                  Switch(
                                    value: _isActive,
                                    activeColor: Colors.white,
                                    activeTrackColor: const Color(0xFF1E56A0),
                                    onChanged: (val) => setState(() => _isActive = val),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(_isActive ? 'Active' : 'Inactive'),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 40),
                        const Divider(height: 1, color: Color(0xFFE2E8F0)),
                        const SizedBox(height: 32),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: ElevatedButton(
                                onPressed: _isSaving ? null : _saveData,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E56A0),
                                  foregroundColor: Colors.white,
                                ),
                                child: Text(_isSaving ? 'Saving...' : 'Save'),
                              ),
                            ),
                            const SizedBox(width: 16),
                            SizedBox(
                              width: 120,
                              height: 40,
                              child: OutlinedButton(
                                onPressed: _isSaving ? null : _clearFormFields,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: const Color(0xFF1E56A0),
                                  side: const BorderSide(color: Color(0xFF1E56A0)),
                                ),
                                child: const Text('Clear'),
                              ),
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

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required bool isRequired,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          validator: (value) => (isRequired && (value == null || value.isEmpty)) ? 'This field is required' : null,
          decoration: InputDecoration(
            hintText: hint,
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField<T>({
    required String label,
    required T? value,
    required String hint,
    required List<DropdownMenuItem<T>> items,
    required bool isRequired,
    required void Function(T?)? onChanged,
  }) {
    final bool hasValue = value != null && items.any((item) => item.value == value);
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 14)),
            if (isRequired) const Text(' *', style: TextStyle(color: Colors.red)),
          ],
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<T>(
          value: hasValue ? value : null,
          hint: Text(hint),
          isExpanded: true,
          validator: (val) => (isRequired && val == null) ? 'Please select an option' : null,
          onChanged: onChanged,
          items: items,
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
          ),
        ),
      ],
    );
  }
}