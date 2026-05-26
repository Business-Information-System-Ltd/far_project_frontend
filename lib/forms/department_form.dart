import 'dart:convert';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class AddDepartmentForm extends StatefulWidget {
  final Department? department;
  
  const AddDepartmentForm({super.key, this.department});

  @override
  State<AddDepartmentForm> createState() => _AddDepartmentFormState();
}

class _AddDepartmentFormState extends State<AddDepartmentForm> {
  final _formKey = GlobalKey<FormState>();
  
  bool _isActive = true;
  bool _allowAssetAssignment = true;
  
 
  bool _isLoadingDepartments = true;
  bool _isSubmitting = false;

  // DB Dropdown Variables
  int? selectedParentDeptId; 
  String? selectedParentDeptName;
  List<Department> _departments = [];

  // Department Type Selection
  String? selectedDeptType;
  final List<String> _deptTypes = ['OPERATION', 'SUPPORT'];

  // Controllers
  final _deptCodeController = TextEditingController();
  final _deptNameController = TextEditingController();
  final _deptShortNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchDepartmentData(); 
    
  
    if (widget.department != null) {
      _deptCodeController.text = widget.department!.deptCode ?? '';
      _deptNameController.text = widget.department!.deptName;
      _deptShortNameController.text = widget.department!.deptName; 
      
      _isActive = widget.department!.isActive;
      _allowAssetAssignment = widget.department!.allowAssignment;
      selectedParentDeptId = widget.department!.parentDeptId;
      
      String currentType = widget.department!.deptType.toUpperCase();
      if (currentType == 'OPERATIONS' || currentType == 'OPERATION') {
        selectedDeptType = 'OPERATION';
      } else if (_deptTypes.contains(currentType)) {
        selectedDeptType = currentType;
      }
    }
  }


  void _fetchDepartmentData() async {
    try {
      final response = await ApiService().fetchDepartments();
      setState(() {
        _departments = response;
        _isLoadingDepartments = false;
      });
    } catch (e) {
      setState(() {
        _isLoadingDepartments = false;
      });
      print('Error fetching departments: $e');
    }
  }

  @override
  void dispose() {
    _deptCodeController.dispose();
    _deptNameController.dispose();
    _deptShortNameController.dispose();
    super.dispose();
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    _deptCodeController.clear();
    _deptNameController.clear();
    _deptShortNameController.clear();
    setState(() {
      selectedParentDeptId = null;
      selectedParentDeptName = null;
      selectedDeptType = null;
      _isActive = true;
      _allowAssetAssignment = true;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSubmitting = true); 

    try {
      String formatDeptType = (selectedDeptType ?? 'OPERATION').toUpperCase();
      if (formatDeptType == 'OPERATION') {
        formatDeptType = 'OPERATIONS'; 
      }

      if (widget.department == null) {
       
        final newDepartment = Department(
          departmentId: null, 
          deptCode: _deptCodeController.text.trim().isEmpty ? null : _deptCodeController.text.trim(),
          deptName: _deptNameController.text.trim(),
          deptType: formatDeptType,
          parentDeptId: selectedParentDeptId,
          allowAssignment: _allowAssetAssignment,
          isActive: _isActive,
          createdAt: DateTime.now().toIso8601String(),
          updatedAt: DateTime.now().toIso8601String(),
        );

        final created = await ApiService().createDepartment(newDepartment);

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data saved successfully!'), backgroundColor: Colors.green),
          );
          Navigator.pop(context, created); 
        }

      } else {
        // Update Mode
        final updatedDepartment = Department(
          departmentId: widget.department!.departmentId, 
          deptCode: _deptCodeController.text.trim().isEmpty ? null : _deptCodeController.text.trim(),
          deptName: _deptNameController.text.trim(),
          deptType: formatDeptType,
          parentDeptId: selectedParentDeptId,
          allowAssignment: _allowAssetAssignment,
          isActive: _isActive,
          createdAt: widget.department!.createdAt, 
          updatedAt: DateTime.now().toIso8601String(),
        );

        final result = await ApiService().updateDepartment(
          widget.department!.departmentId!, 
          updatedDepartment,
        );

        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Data updated successfully!'), backgroundColor: Colors.green),
          );
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
      setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Card(
        elevation: 1,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: Colors.grey.shade100),
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
                      widget.department == null ? 'Add Department Form' : 'Edit Department Form',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black87),
                    ),
                  ),
                  const SizedBox(height: 24),

                  _buildInputField(
                    'Department Code', 
                    'Enter department code', 
                    controller: _deptCodeController,
                    isRequired: true,
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildInputField(
                          'Department Name', 
                          'Enter department name', 
                          controller: _deptNameController,
                          isRequired: true,
                        ),
                      ),
                      const SizedBox(width: 16), 
                      Expanded(
                        child: _buildInputField(
                          'Department Short Name', 
                          'Enter short name', 
                          controller: _deptShortNameController,
                          isRequired: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildParentDeptDropdown()),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDeptTypeDropdown()),
                    ],
                  ),
                  const SizedBox(height: 20),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Checkbox(
                            value: _allowAssetAssignment,
                            activeColor: Colors.deepPurple,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                            onChanged: (value) {
                              setState(() {
                                _allowAssetAssignment = value ?? true;
                              });
                            },
                          ),
                          const Text(
                            'Allow Asset Assignment', 
                            style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)
                          ),
                        ],
                      ),
                      
                      Row(
                        children: [
                          const Text(
                            'Status', 
                            style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.black87)
                          ),
                          const SizedBox(width: 6),
                          Transform.scale(
                            scale: 0.8,
                            child: Switch(
                              value: _isActive,
                              activeColor: Colors.white,
                              activeTrackColor: Colors.deepPurple,
                              onChanged: (value) {
                                setState(() {
                                  _isActive = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            _isActive ? 'Active' : 'Inactive', 
                            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: Colors.black87)
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 28),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: _isSubmitting ? null : _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                        child: _isSubmitting
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                              )
                            : const Text('Save', style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: _isSubmitting ? null : _clearForm,
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

  Widget _buildParentDeptDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Parent Department',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
        ),
        const SizedBox(height: 4),
        _isLoadingDepartments
            ? const Padding(
                padding: EdgeInsets.symmetric(vertical: 10.0),
                child: SizedBox(
                  height: 18,
                  width: 18,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.deepPurple),
                ),
              )
            : DropdownButtonFormField<Department>(
                isExpanded: true, 
                decoration: _buildInputDecoration(),
                value: selectedParentDeptId != null && _departments.any((d) => d.departmentId == selectedParentDeptId)
                    ? _departments.firstWhere((d) => d.departmentId == selectedParentDeptId) 
                    : null, 
                hint: Text(
                  'Select parent department',
                  style: TextStyle(color: Colors.grey.shade400, fontSize: 12),
                ),
                style: const TextStyle(fontSize: 13, color: Colors.black87),
                icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
                items: _departments.map((Department dept) {
                  return DropdownMenuItem<Department>(
                    value: dept,
                    child: Text(dept.deptName), 
                  );
                }).toList(),
                onChanged: (Department? newValue) {
                  if (newValue != null) {
                    setState(() {
                      selectedParentDeptId = newValue.departmentId;
                      selectedParentDeptName = newValue.deptName;
                    });
                  }
                },
              )
      ],
    );
  }

  Widget _buildDeptTypeDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: const TextSpan(
            text: 'Department Type',
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
            children: [TextSpan(text: ' *', style: TextStyle(color: Colors.red))],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<String>(
          value: selectedDeptType,
          hint: Text('Select department type', style: TextStyle(color: Colors.grey.shade400, fontSize: 12)),
          style: const TextStyle(fontSize: 13, color: Colors.black87),
          icon: const Icon(Icons.keyboard_arrow_down, size: 20, color: Colors.black54),
          validator: (value) => value == null ? 'This field cannot be null' : null,
          items: _deptTypes.map((String type) {
            return DropdownMenuItem<String>(value: type, child: Text(type));
          }).toList(),
          onChanged: (value) {
            setState(() {
              selectedDeptType = value;
            });
          },
          decoration: _buildInputDecoration(),
        ),
      ],
    );
  }

  Widget _buildInputField(String label, String hint, {TextEditingController? controller, bool isRequired = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black87, fontSize: 12),
            children: isRequired ? [const TextSpan(text: ' *', style: TextStyle(color: Colors.red))] : [],
          ),
        ),
        const SizedBox(height: 4),
        TextFormField(
          controller: controller,
          style: const TextStyle(fontSize: 13),
          validator: isRequired ? (value) => (value == null || value.trim().isEmpty) ? 'This field cannot be null' : null : null,
          decoration: _buildInputDecoration(hint: hint),
        ),
      ],
    );
  }

  InputDecoration _buildInputDecoration({String? hint}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 12),
      contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.deepPurple, width: 1.2)),
      errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red, width: 1)),
      focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: Colors.red, width: 1.2)),
    );
  }
}