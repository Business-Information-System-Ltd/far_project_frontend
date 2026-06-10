import 'package:far_project_frontend/forms/custodian_form.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../api/api_service.dart';
import '../api/data.dart';

class CustodianListScreen extends StatefulWidget {
  const CustodianListScreen({Key? key}) : super(key: key);

  @override
  State<CustodianListScreen> createState() => _CustodianListScreenState();
}

class _CustodianListScreenState extends State<CustodianListScreen> {
  final ApiService apiService = ApiService();
  List<Custodian> custodianList = [];
  List<Branch> branchList = [];
  List<Department> deptList = [];
  List<PlutoRow> rows = [];
  bool isLoading = true;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    loadAllData();
  }

  
  Future<void> loadAllData() async {
    setState(() => isLoading = true);
    
    print('=== LOADING CUSTODIAN DATA ===');
    
    // Load custodians
    List<Custodian> custodians = [];
    try {
      custodians = await apiService.fetchCustodians();
      print('Custodians loaded: ${custodians.length}');
    } catch (e) {
      print('Error loading custodians: $e');
    }
    
    // Load branches
    List<Branch> branches = [];
    try {
      branches = await apiService.fetchBranches();
      print('Branches loaded: ${branches.length}');
    } catch (e) {
      print('Error loading branches: $e');
    }
    
    // Load departments
    List<Department> departments = [];
    try {
      departments = await apiService.fetchDepartments();
      print('Departments loaded: ${departments.length}');
    } catch (e) {
      print('Error loading departments: $e');
    }
    
    setState(() {
      custodianList = custodians;
      branchList = branches;
      deptList = departments;
      buildPlutoRows();
      isLoading = false;
    });
  }

  void buildPlutoRows() {
   
    final Map<int, String> branchNameMap = {
      for (var branch in branchList) branch.branchId: branch.branchName
    };
    
    final Map<int, String> deptNameMap = {
      for (var dept in deptList) dept.departmentId!: dept.deptName
    };

    rows = custodianList.asMap().entries.map((entry) {
      int index = entry.key;
      Custodian custodian = entry.value;
      
      // Get names from maps
      String branchName = branchNameMap[custodian.branchId] ?? 'ID: ${custodian.branchId}';
      String deptName = deptNameMap[custodian.deptId] ?? 'ID: ${custodian.deptId}';
      
      return PlutoRow(
        cells: {
          'id': PlutoCell(value: custodian.id ?? 0),
          'code': PlutoCell(value: custodian.code),
          'name': PlutoCell(value: custodian.name),
          'type': PlutoCell(value: custodian.type),
          'email': PlutoCell(value: custodian.email),
          'phNo': PlutoCell(value: custodian.phNo),
          'deptName': PlutoCell(value: deptName),
          'branch': PlutoCell(value: branchName),
          'status': PlutoCell(value: custodian.isActive),
          'action': PlutoCell(value: 'Edit'),
        },
        sortIdx: index,
      );
    }).toList();
  }

  Future<void> _toggleStatus(Custodian custodian, bool newStatus) async {
    try {
      print('Toggling status for ${custodian.name} to $newStatus');
      
      final payload = {
        
      'custodian_name': custodian.name,
      'custodian_type': custodian.type,
      'email': custodian.email,
      'phone': custodian.phNo,
      'dept': custodian.deptId,     
      'branch': custodian.branchId,  
      'can_hold_assets': custodian.canHoldAssets,
      'is_active': newStatus,
      };
      
      final success = await apiService.updateCustodian(custodian.id!, payload);
      
      if (success) {
       
        final index = custodianList.indexWhere((c) => c.id == custodian.id);
        if (index != -1) {
          setState(() {
            custodianList[index] = Custodian(
              id: custodian.id,
              code: custodian.code,
              name: custodian.name,
              type: custodian.type,
              email: custodian.email,
              phNo: custodian.phNo,
              branchId: custodian.branchId,
              deptId: custodian.deptId,
              canHoldAssets: custodian.canHoldAssets,
              isActive: newStatus,
            );
            buildPlutoRows();
          });
        }
        _showSnackbar('Status updated successfully', Colors.green);
      } else {
        _showSnackbar('Failed to update status', Colors.red);
      }
    } catch (e) {
      print('Error toggling status: $e');
      _showSnackbar('Error: $e', Colors.red);
    }
  }

  void _showSnackbar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custodian List"),
        backgroundColor: const Color(0xFF1E56A0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadAllData,
          ),
        ],
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      ElevatedButton.icon(
                        icon: const Icon(Icons.add, color: Colors.white),
                        label: const Text(
                          "Add New",
                          style: TextStyle(
                            color: Colors.white, 
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E56A0),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const CustodianFormScreen(),
                            ),
                          ).then((_) => loadAllData());
                        },
                      ),
                      const SizedBox(width: 16),
                      Text(
                        'Total: ${custodianList.length}',
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          color: Colors.black54,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: rows.isEmpty
                        ? const Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.people_outline, size: 64, color: Colors.grey),
                                SizedBox(height: 16),
                                Text(
                                  "No custodians available.",
                                  style: TextStyle(fontSize: 16, color: Colors.grey),
                                ),
                              ],
                            ),
                          )
                        : PlutoGrid(
                            columns: [
                              PlutoColumn(
                                title: 'ID',
                                field: 'id',
                                type: PlutoColumnType.text(),
                                width: 60,
                                hide: true,
                              ),
                              PlutoColumn(
                                title: 'Code',
                                field: 'code',
                                type: PlutoColumnType.text(),
                                width: 100,
                              ),
                              PlutoColumn(
                                title: 'Name',
                                field: 'name',
                                type: PlutoColumnType.text(),
                                width: 150,
                              ),
                              PlutoColumn(
                                title: 'Type',
                                field: 'type',
                                type: PlutoColumnType.text(),
                                width: 120,
                              ),
                              PlutoColumn(
                                title: 'Email',
                                field: 'email',
                                type: PlutoColumnType.text(),
                                width: 180,
                              ),
                              PlutoColumn(
                                title: 'Phone No',
                                field: 'phNo',
                                type: PlutoColumnType.text(),
                                width: 140,
                              ),
                              PlutoColumn(
                                title: 'Department',
                                field: 'deptName',
                                type: PlutoColumnType.text(),
                                width: 140,
                              ),
                              PlutoColumn(
                                title: 'Branch',
                                field: 'branch',
                                type: PlutoColumnType.text(),
                                width: 140,
                              ),
                              PlutoColumn(
                                title: 'Status',
                                field: 'status',
                                type: PlutoColumnType.text(),
                                width: 110,
                                renderer: (rendererContext) {
                                  final rowIndex = rendererContext.rowIdx;
                                  if (rowIndex >= custodianList.length) {
                                    return const SizedBox();
                                  }
                                  final custodian = custodianList[rowIndex];
                                  return Center(
                                    child: Switch(
                                      value: custodian.isActive,
                                      onChanged: (bool value) async {
                                        await _toggleStatus(custodian, value);
                                      },
                                      activeColor: Colors.white,
                                      activeTrackColor: const Color(0xFF1E56A0),
                                      inactiveThumbColor: Colors.grey[400],
                                      inactiveTrackColor: Colors.grey[200],
                                    ),
                                  );
                                },
                              ),
                              PlutoColumn(
                                title: 'Action',
                                field: 'action',
                                type: PlutoColumnType.text(),
                                width: 120,
                                enableEditingMode: false,
                                renderer: (rendererContext) {
                                  final rowIndex = rendererContext.rowIdx;
                                  if (rowIndex >= custodianList.length) {
                                    return const SizedBox();
                                  }
                                  final selectedCustodian = custodianList[rowIndex];
                                  return TextButton.icon(
                                    icon: const Icon(Icons.edit, size: 16, color: Color(0xFF1E56A0)),
                                    label: const Text("Edit", style: TextStyle(color: Color(0xFF1E56A0))),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustodianFormScreen(
                                            custodian: selectedCustodian,
                                          ),
                                        ),
                                      ).then((_) => loadAllData());
                                    },
                                  );
                                },
                              ),
                            ],
                            rows: rows,
                            onLoaded: (PlutoGridOnLoadedEvent event) {
                              stateManager = event.stateManager;
                            },
                            configuration: const PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                                activatedColor: Color(0xFF1E56A0),
                                gridBorderColor: Colors.grey,
                                cellTextStyle: TextStyle(fontSize: 13),
                              ),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}