import 'package:far_project_frontend/forms/branch_form.dart'; 
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart'; 
import 'package:far_project_frontend/details/branch_detail.dart'; 

class BranchListPage extends StatefulWidget {
  const BranchListPage({Key? key}) : super(key: key);

  @override
  State<BranchListPage> createState() => _BranchListPageState();
}

class _BranchListPageState extends State<BranchListPage> {
  final ApiService _apiService = ApiService();

  // PlutoGrid Columns & Rows
  List<PlutoColumn> mainColumns = [];
  List<PlutoRow> mainRows = [];
  PlutoGridStateManager? mainStateManager;

  List<PlutoColumn> detailColumns = [];
  List<PlutoRow> detailRows = [];
  PlutoGridStateManager? detailStateManager;

  // States
  bool _isLoading = true;
  String? _errorMessage;
  bool _isAdvanceSearchChecked = false;
  String _selectedStatus = 'Active';
  bool _showDetailedInfo = false;

  // Controllers
  final _searchCodeController = TextEditingController();
  final _searchNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _buildMainGridColumns();
    _buildDetailGridColumns();
    _loadBranchData();
  }

  @override
  void dispose() {
    _searchCodeController.dispose();
    _searchNameController.dispose();
    super.dispose();
  }

 
  Future<void> _loadBranchData() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _showDetailedInfo = false; 
      });

      List<Branch> branches = await _apiService.fetchBranches();

      List<PlutoRow> fetchedRows = branches.map((branch) {
        return PlutoRow(
          cells: {
            'code': PlutoCell(value: branch.branchCode ?? '-'),
            'name': PlutoCell(value: branch.branchName ?? '-'),
            'phone': PlutoCell(value: branch.phone ?? '-'),
            'email': PlutoCell(value: branch.email ?? '-'),
            'address': PlutoCell(value: branch.address ?? '-'),
            'city': PlutoCell(value: branch.city ?? '-'),
            'country': PlutoCell(value: branch.countryName ?? '-'),
            'status': PlutoCell(value: branch.isActive),
            'action': PlutoCell(value: branch), 
       } );
      }).toList();

      setState(() {
        mainRows = fetchedRows;
        _isLoading = false;
      });

      if (mainStateManager != null) {
        mainStateManager!.refRows.clear();
        mainStateManager!.refRows.addAll(fetchedRows);
        mainStateManager!.notifyListeners();
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = "Error loading data. Please try again.";
      });
      print("Error loading branches: $e");
    }
  }

  void _buildMainGridColumns() {
    mainColumns = [
      PlutoColumn(width:120, title: 'Branch Code', field: 'code', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: true, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:150,title: 'Branch Name', field: 'name', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: true, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:150,title: 'Ph No', field: 'phone', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: false, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:170,title: 'Email', field: 'email', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: false, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:170,title: 'Address', field: 'address', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: false, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:110,title: 'City', field: 'city', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: true, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(width:110,title: 'Country', field: 'country', type: PlutoColumnType.text(), enableEditingMode: false, enableSorting: true, enableContextMenu: false, enableDropToResize: false),
      PlutoColumn(
        width: 100,
        title: 'Status',
        field: 'status',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        renderer: (rendererContext) {
          bool isActive = rendererContext.cell.value ?? false;
          return StatefulBuilder(
            builder: (context, setStateRow) {
              return Transform.scale(
                scale: 0.75,
                child: Switch(
                  value: isActive,
                  activeColor: const Color(0xFF1B51C4),
                  onChanged: (value) {
                    setStateRow(() {
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
        width: 100,
        title: 'Action',
        field: 'action',
        type: PlutoColumnType.text(),
        enableEditingMode: false,
        enableSorting: false,
        enableContextMenu: false,
        enableDropToResize: false,
        renderer: (rendererContext) {
          final Branch branch = rendererContext.cell.value;
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
             
              TextButton(
                onPressed: () async {
                  
                  final result = await Navigator.of(context).push<Branch>(
                    MaterialPageRoute(
                      builder: (context) => AddBranchForm(branch: branch), 
                    ),
                  );

                
                  if (result != null) {
                    _loadBranchData(); 
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Branch Updated successfully'), backgroundColor: Colors.green),
                      );
                    }
                  }
                },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(40, 30)),
                child: const Text('Edit', style: TextStyle(color: Color(0xFF1B51C4), fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const Text('/', style: TextStyle(color: Colors.grey)),
              TextButton(
                onPressed: () async { 
   
    await Navigator.of(context).push( 
      MaterialPageRoute(
        builder: (context) => BranchDetailScreen(branch: branch),
      ),
    );


    _loadBranchData(); 
  },
                style: TextButton.styleFrom(padding: EdgeInsets.zero, minimumSize: const Size(45, 30)),
                child: const Text('Detail', style: TextStyle(color:  Color(0xFF1B51C4), fontSize: 12,fontWeight: FontWeight.bold)),
              ),
            ], 
          );
        },
      ),
    ];
  }

  void _buildDetailGridColumns() {
    detailColumns = mainColumns.map((col) {
      return PlutoColumn(
        title: col.title,
        field: col.field,
        type: col.type,
        enableEditingMode: col.enableEditingMode,
        enableSorting: col.enableSorting,
        enableContextMenu: col.enableContextMenu,
        enableDropToResize: col.enableDropToResize,
        renderer: col.renderer, 
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Center(
              child: Padding(
                padding: EdgeInsets.only(bottom: 20.0),
                child: Text(
                  'Branch List',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                ),
              ),
            ),

            // Search Toolbar
            Row(
              children: [
                const Text('Status ', style: TextStyle(fontSize: 13, color: Colors.black54)),
                const SizedBox(width: 4),
                Container(
                  height: 36,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                    color: Colors.grey.shade50,
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: _selectedStatus,
                      style: const TextStyle(fontSize: 13, color: Colors.black87),
                      items: ['Active', 'Inactive'].map((String val) {
                        return DropdownMenuItem<String>(value: val, child: Text(val));
                      }).toList(),
                      onChanged: (val) {
                        setState(() => _selectedStatus = val!);
                      },
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: SizedBox(
                    height: 36,
                    child: TextField(
                      style: const TextStyle(fontSize: 13),
                      decoration: InputDecoration(
                        hintText: 'Search...',
                        hintStyle: TextStyle(color: Colors.grey.shade400, fontSize: 13),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        suffixIcon: const Icon(Icons.search, size: 18, color: Colors.grey),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: BorderSide(color: Colors.grey.shade300)),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Row(
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _isAdvanceSearchChecked,
                        activeColor: const Color(0xFF1B51C4),
                        side: BorderSide(color: Colors.grey.shade400, width: 1.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        onChanged: (bool? val) {
                          setState(() {
                            _isAdvanceSearchChecked = val ?? false;
                          });
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('Advance Search', style: TextStyle(color: Colors.black54, fontSize: 13, fontWeight: FontWeight.w500)),
                  ],
                ),
              ],
            ),

            if (_isAdvanceSearchChecked) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchCodeController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Filter by Branch Code...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: SizedBox(
                        height: 36,
                        child: TextField(
                          controller: _searchNameController,
                          style: const TextStyle(fontSize: 13),
                          decoration: InputDecoration(
                            hintText: 'Filter by Branch Name...',
                            contentPadding: const EdgeInsets.symmetric(horizontal: 12),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 16),

            // Top Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B51C4),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  ),
                  onPressed: () async {
                    final result = await Navigator.of(context).push<Branch>(
                      MaterialPageRoute(
                        builder: (context) => const AddBranchForm(), 
                      ),
                    );
                    
                    
                    if (result != null) {
                      _loadBranchData();
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Branch Created successfully'), backgroundColor: Colors.green),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.add, size: 18),
                  label: const Text('Add New', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
                ),
                OutlinedButton.icon(
                  onPressed: _loadBranchData,
                  icon: const Icon(Icons.refresh, size: 18, color: Colors.black87),
                  label: const Text('Refresh Data', style: TextStyle(color: Colors.black87)),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Colors.grey.shade400),
                    backgroundColor: const Color(0xFFEFEFEF),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
                              ElevatedButton(onPressed: _loadBranchData, child: const Text('Retry')),
                            ],
                          ),
                        )
                      : PlutoGrid(
                          columns: mainColumns,
                          rows: mainRows,
                          onChanged: (PlutoGridOnChangedEvent event) {},
                          onLoaded: (PlutoGridOnLoadedEvent event) {
                            mainStateManager = event.stateManager;
                            mainStateManager!.setShowColumnFilter(false);
                          },
                          configuration: _getGridConfiguration(),
                        ),
            ),

            // Detailed Table View
            if (_showDetailedInfo) ...[
              const SizedBox(height: 24),
              const Text(
                'Detailed Information',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF1B51C4)),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 110, 
                child: PlutoGrid(
                  columns: detailColumns,
                  rows: detailRows,
                  onChanged: (PlutoGridOnChangedEvent event) {},
                  onLoaded: (PlutoGridOnLoadedEvent event) {
                    detailStateManager = event.stateManager;
                    detailStateManager!.setShowColumnFilter(false);
                  },
                  configuration: _getGridConfiguration(),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  PlutoGridConfiguration _getGridConfiguration() {
    return PlutoGridConfiguration(
      style: PlutoGridStyleConfig(
        gridBorderColor: Colors.grey.shade300,
        rowHeight: 35,
        columnHeight: 35,
        borderColor: Colors.grey.shade200,
        activatedColor: Colors.transparent,
      ),
    );
  }
}