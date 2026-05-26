import 'package:far_project_frontend/forms/custodian_form.dart';
import 'package:far_project_frontend/lists/currency_list.dart';
import 'package:far_project_frontend/lists/custodian_list.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CustodianListScreen(), 
    );
  }
}






class CustodianForm extends StatefulWidget {
  const CustodianForm({Key? key}) : super(key: key);

  @override
  State<CustodianForm> createState() => _CustodianFormState();
}

class _CustodianFormState extends State<CustodianForm> {
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  
  // Switch & Checkbox States
  bool _canHoldAssets = true;
  bool _isActive = true;

  // Selected ID Variables (String အစား ID သိမ်းရန်)
  int? _selectedBranchId;
  int? _selectedDepartmentId;

  // Dummy Data: API မှ ခေါ်ယူရရှိမည့် ပုံစံမျိုး (သင့်ထံတွင် Branch/Dept List ရှိပြီးသားဖြစ်ရမည်)
  final List<Map<String, dynamic>> _branchList = [
    {"id": 1, "name": "Asus"},
    {"id": 2, "name": "Acer"},
  ];

  final List<Map<String, dynamic>> _departmentList = [
    {"id": 1, "name": "IT"},
    {"id": 2, "name": "Education"},
  ];

  // Save Data Function
  Future<void> _saveCustodianData() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_selectedBranchId == null || _selectedDepartmentId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select Branch and Department')),
      );
      return;
    }

    final String apiUrl = "http://localhost:26086/api/far/v1/custodians/"; // သင့် API URL

    // Backend မှ မျှော်လင့်ထားသည့် Key အမျိုးအစားအတိုင်း ပို့ပေးခြင်း
    final Map<String, dynamic> payload = {
      "name": _nameController.text.trim(),
      "phone_number": _phoneController.text.trim(),
      "email": _emailController.text.trim(),
      "branch": _selectedBranchId,       // စာသားမဟုတ်ဘဲ ID integer ကို ပို့သည်
      "department": _selectedDepartmentId, // စာသားမဟုတ်ဘဲ ID integer ကို ပို့သည်
      "can_hold_assets": _canHoldAssets,
      "is_active": _isActive,
    };

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Custodian Saved Successfully!')),
        );
        _clearForm();
      } else {
        // Error 400 တက်ပါက ဘာကြောင့်လဲဆိုတာ Flutter Debug Console တွင် ပြပေးမည်
        print("Backend Validation Error Response: ${response.body}");
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Server Error: ${response.statusCode}. Check validation.')),
        );
      }
    } catch (e) {
      print("Connection Error: $e");
    }
  }

  void _clearForm() {
    _nameController.clear();
    _phoneController.clear();
    _emailController.clear();
    setState(() {
      _selectedBranchId = null;
      _selectedDepartmentId = null;
      _canHoldAssets = true;
      _isActive = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Custodian Registration")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Custodian Name Field
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Custodian Name *"),
                validator: (v) => v!.isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),

              // Branch Dropdown (Value ကို ID အဖြစ် သုံးထားသည်)
              DropdownButtonFormField<int>(
                value: _selectedBranchId,
                hint: const Text("Select Branch *"),
                items: _branchList.map((branch) {
                  return DropdownMenuItem<int>(
                    value: branch['id'] as int, // ID ကို value အဖြစ်ထားသည်
                    child: Text(branch['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedBranchId = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Department Dropdown (Value ကို ID အဖြစ် သုံးထားသည်)
              DropdownButtonFormField<int>(
                value: _selectedDepartmentId,
                hint: const Text("Select Department *"),
                items: _departmentList.map((dept) {
                  return DropdownMenuItem<int>(
                    value: dept['id'] as int, // ID ကို value အဖြစ်ထားသည်
                    child: Text(dept['name']),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedDepartmentId = value;
                  });
                },
              ),
              const SizedBox(height: 15),

              // Phone Number Field
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: "Phone Number *"),
                validator: (v) => v!.isEmpty ? "Enter phone number" : null,
              ),
              const SizedBox(height: 15),

              // Email Address Field
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email Address *"),
                validator: (v) {
                  if (v!.isEmpty) return "Enter email";
                  if (!v.contains('@') || !v.contains('.')) return "Invalid email format";
                  return null;
                },
              ),
              const SizedBox(height: 15),

              // Checkbox & Switch
              CheckboxListTile(
                title: const Text("Can Hold Assets"),
                value: _canHoldAssets,
                onChanged: (v) => setState(() => _canHoldAssets = v!),
              ),
              SwitchListTile(
                title: const Text("Status (Active)"),
                value: _isActive,
                onChanged: (v) => setState(() => _isActive = v),
              ),
              const SizedBox(height: 25),

              // Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveCustodianData,
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.blue[800]),
                      child: const Text("Save Data", style: TextStyle(color: Colors.white)),
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _clearForm,
                      child: const Text("Clear"),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}