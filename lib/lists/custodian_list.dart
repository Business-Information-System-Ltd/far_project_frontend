import 'package:far_project_frontend/forms/custodian_form.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../api/api_service.dart';
import '../api/data.dart';
import '../forms/custodian_form.dart'; 

class CustodianListScreen extends StatefulWidget {
  const CustodianListScreen({Key? key}) : super(key: key);

  @override
  State<CustodianListScreen> createState() => _CustodianListScreenState();
}

class _CustodianListScreenState extends State<CustodianListScreen> {
  final ApiService apiService = ApiService();
  List<Custodian> custodianList = [];
  List<PlutoRow> rows = [];
  bool isLoading = true;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    loadCustodians();
  }

  void loadCustodians() async {
    setState(() => isLoading = true);
    var data = await apiService.fetchCustodians();
    
    setState(() {
      custodianList = data;
      buildPlutoRows();
      isLoading = false;
    });
  }

  void buildPlutoRows() {
    rows = custodianList.asMap().entries.map((entry) {
      int index = entry.key;
      Custodian custodian = entry.value;
      return PlutoRow(
        cells: {
          'id': PlutoCell(value: custodian.id ?? 0),
          'code': PlutoCell(value: custodian.code),
          'name': PlutoCell(value: custodian.name),
          'type': PlutoCell(value: custodian.type),
          'email': PlutoCell(value: custodian.email),
          'phNo': PlutoCell(value: custodian.phNo),
          'deptName': PlutoCell(value: custodian.deptName?.toString() ?? '-'),
          'branch': PlutoCell(value: custodian.branch?.toString() ?? '-'),
          'status': PlutoCell(value: custodian.isActive ? 'Active' : 'Inactive'),
          'action': PlutoCell(value: 'Edit'),
        },
        sortIdx: index,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Custodian List"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCustodians,
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
                  // Action Bar Header
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
                          backgroundColor: Colors.blue[800],
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
                          ).then((_) => loadCustodians());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // PlutoGrid Layout Setup
                  Expanded(
                    child: rows.isEmpty
                        ? const Center(child: Text("No custodians available."))
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
                                title: 'Ph no',
                                field: 'phNo',
                                type: PlutoColumnType.text(),
                                width: 140,
                              ),
                              PlutoColumn(
                                title: 'Dept Name',
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
                                  bool isActive = rendererContext.cell.value == 'Active';
                                  return Center(
                                    child: Transform.scale(
                                      scale: 0.75,
                                      child: Switch(
                                        value: isActive,
                                        onChanged: (bool value) async {
                                          // Implement status toggle if needed
                                          print('Status toggled: $value');
                                        },
                                        activeColor: Colors.white,
                                        activeTrackColor: Colors.blue[600],
                                        inactiveThumbColor: Colors.grey[400],
                                        inactiveTrackColor: Colors.grey[200],
                                      ),
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
                                  int rowIndex = rendererContext.rowIdx;
                                  Custodian selectedCustodian = custodianList[rowIndex];
                                  return TextButton.icon(
                                    icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Edit"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CustodianFormScreen(
                                            custodian: selectedCustodian, // Fixed: was commented out
                                          ),
                                        ),
                                      ).then((_) => loadCustodians());
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
                              style: PlutoGridStyleConfig(),
                            ),
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}