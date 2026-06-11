import 'package:far_project_frontend/forms/department_form.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';

class DepartmentListPage extends StatefulWidget {
  const DepartmentListPage({Key? key}) : super(key: key);

  @override
  State<DepartmentListPage> createState() => _DepartmentListPageState();
}

class _DepartmentListPageState extends State<DepartmentListPage> {
  final ApiService _apiService = ApiService();
  
  List<PlutoColumn> columns = [];
  List<PlutoRow> rows = [];
  PlutoGridStateManager? stateManager;
  
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _buildGridColumns();
    _loadDepartmentData(); 
  }


  Future<void> _refreshDepartments() async {
    await _loadDepartmentData();
  }

  void _editDepartment(Department department) async {
    final result = await Navigator.push<Department>(
      context,
      MaterialPageRoute(builder: (_) => AddDepartmentForm(department: department)),
    );
    
   
    if (result != null) {
      _refreshDepartments(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Department Updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  void _createDepartment() async {
    final result = await Navigator.push<Department?>(
      context,
      MaterialPageRoute(builder: (_) => const AddDepartmentForm()), 
    );

    if (result != null) {
      _refreshDepartments(); 
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Department created successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    }
  }

  
  Future<void> _loadDepartmentData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      
      List<Department> departments = await _apiService.fetchDepartments();
      
      List<PlutoRow> fetchedRows = departments.map((dept) {

       //parent deptname
       String displayParentName = '-';
        if (dept.parentDeptId != null) {
          try {
            
            final parentObj = departments.firstWhere((d) => d.departmentId == dept.parentDeptId);
            displayParentName = parentObj.deptName; 
          } catch (e) {
           
            displayParentName = dept.parentDeptId.toString();
          }
        }

        return PlutoRow(
          cells: {
            'dept_code': PlutoCell(value: dept.deptCode ?? '-'),
            'dept_name': PlutoCell(value: dept.deptName),
            
            'short_name': PlutoCell(value: dept.shortName ?? '-'),
            // 'parent_dept': PlutoCell(value: dept.parentDeptName != null ? dept.parentDeptName.toString() : '-'),
            'parent_dept': PlutoCell(value: displayParentName),
            'status': PlutoCell(value: dept.isActive),
            
            'action': PlutoCell(value: dept), 
          },
        );
      }).toList();

      setState(() {
        rows = fetchedRows;
        _isLoading = false;
      });

      if (stateManager != null) {
        stateManager!.refRows.clear();
        stateManager!.refRows.addAll(fetchedRows);
        stateManager!.notifyListeners();
      }

    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading data. Please try again.";
      });
      print("Error loading departments: $e");
    }
  }

  
  void _buildGridColumns() {
    columns = [
      PlutoColumn(
        title: 'Dept Code',
        field: 'dept_code',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: true, 
        enableContextMenu: false,
        enableDropToResize: false,
      ),
      PlutoColumn(
        title: 'Department Name',
        field: 'dept_name',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: true,
        enableContextMenu: false,
        enableDropToResize: false,
      ),
      PlutoColumn(
        title: 'Short Name',
        field: 'short_name',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
      ),
      PlutoColumn(
        title: 'Parent Department',
        field: 'parent_dept',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        renderer: (rendererContext) {
          final value = rendererContext.cell.value.toString();
          return Align(
            alignment: Alignment.centerLeft,
            child: Text(value, style: const TextStyle(color: Colors.black87)),
          );
        },
      ),
      PlutoColumn(
        width: 185,
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        renderer: (rendererContext) {
          bool? isActive = rendererContext.cell.value;
          if (isActive == null) return const SizedBox.shrink();
          
          return StatefulBuilder(
            builder: (context, setState) {
              return Transform.scale(
                scale: 0.75, 
                child: Switch(
                  value: isActive ?? false,
                  activeColor: Colors.blue[600],
                  onChanged: (value) async {
                    setState(() {
                      isActive = value;
                      rendererContext.cell.value = value;
                    });
                  },
                ),
              );
            },
          );
        },
      ),
      PlutoColumn(
        width: 193,
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        renderer: (rendererContext) {
       
          final Department currentDept = rendererContext.cell.value as Department; 
          
          return TextButton.icon(
            onPressed: () {
              print("Edit Department ID: ${currentDept.departmentId}");
              
              _editDepartment(currentDept); 
            },
            icon: const Icon(Icons.edit_outlined, size: 14, color: Colors.black54),
            label: const Text('Edit', style: TextStyle(color: Colors.black87, fontSize: 13)),
          );
        },
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F9),
      body: Center(
        child: Container(
          width: double.infinity,
          margin: const EdgeInsets.all(24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(bottom: 24.0),
                  child: Text(
                    'Department List',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
                  ),
                ),
              ),
              Row(
                
                children: [
                  
                  const Text('Status ', style: TextStyle(color: Colors.black54)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade300),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: 'Active',
                        items: ['Active', 'Inactive'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (_) {},
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  SizedBox(
                    width: 240,
                    height: 40,
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 12),
                        suffixIcon: const Icon(Icons.search, size: 20, color: Colors.grey),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(6),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton.icon(
                    onPressed: _createDepartment, 
                    icon: const Icon(Icons.add, size: 18, color: Colors.white),
                    label: const Text('Add New', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E56C5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                  OutlinedButton.icon(
                    onPressed: _loadDepartmentData, 
                    icon: const Icon(Icons.refresh, size: 18, color: Colors.black87),
                    label: const Text('Refresh Data', style: TextStyle(color: Colors.black87)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: Colors.grey.shade400),
                      backgroundColor: const Color(0xFFEFEFEF),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator()) 
                    : _errorMessage != null
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(_errorMessage!, style: const TextStyle(color: Colors.red)),
                                const SizedBox(height: 8),
                                ElevatedButton(
                                  onPressed: _loadDepartmentData,
                                  child: const Text('Retry'),
                                )
                              ],
                            ),
                          )
                        : PlutoGrid(
                            columns: columns,
                            rows: rows,
                            onChanged: (PlutoGridOnChangedEvent event) {},
                            onLoaded: (PlutoGridOnLoadedEvent event) {
                              stateManager = event.stateManager;
                              stateManager!.setShowColumnFilter(false);
                            },
                            configuration: PlutoGridConfiguration(
                              style: PlutoGridStyleConfig(
                                gridBorderColor: Colors.grey.shade300,
                                rowHeight: 35,
                                columnHeight: 35,
                                borderColor: Colors.grey.shade200,
                                activatedColor: Colors.transparent,
                              ),
                            ),
                            createFooter: null, 
                          ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}