import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import '../api/api_service.dart';
import '../api/data.dart';
import '../forms/branch_form.dart'; 

class CurrencyListScreen extends StatefulWidget {
  const CurrencyListScreen({Key? key}) : super(key: key);

  @override
  State<CurrencyListScreen> createState() => _CurrencyListScreenState();
}

class _CurrencyListScreenState extends State<CurrencyListScreen> {
  final ApiService apiService = ApiService();
  List<Currency> currencyList = [];
  List<PlutoRow> rows = [];
  bool isLoading = true;
  late PlutoGridStateManager stateManager;

  @override
  void initState() {
    super.initState();
    loadCurrencies();
  }

  void loadCurrencies() async {
    setState(() => isLoading = true);
    var data = await apiService.fetchCurrencies();
    setState(() {
      currencyList = data;
      buildPlutoRows();
      isLoading = false;
    });
  }

  void buildPlutoRows() {
    rows = currencyList.asMap().entries.map((entry) {
      int index = entry.key;
      Currency item = entry.value;
      
      String code = item.currencyCode ?? '-';
      String name = item.currencyName ?? '-';
      String symbol = item.currencySymbol ?? '-';
      double rate = item.exchangeRate ?? 0.0;
      String statusStr = (item.isActive == true) ? 'Active' : 'Inactive';
      String transactionCurrency = item.transactionCurrency ?? '-';
      String functionalCurrency = item.functionalCurrency ?? '-';
      
      return PlutoRow(
        cells: {
          'id': PlutoCell(value: item.currencyId ?? 0),
          'code': PlutoCell(value: code),
          'name': PlutoCell(value: name),
          'symbol': PlutoCell(value: symbol),
          'exchangeRate': PlutoCell(value: rate),
          'transactionCurrency': PlutoCell(value: transactionCurrency),
          'functionalCurrency': PlutoCell(value: functionalCurrency),
          'status': PlutoCell(value: statusStr),
          'action': PlutoCell(value: 'Detail'),
        },
        sortIdx: index,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency List"),
        backgroundColor: const Color(0xFF1E56A0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: loadCurrencies,
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
                          "Add New Currency",
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
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => const CurrencyListScreen(),
                          //   ),
                          // ).then((_) => loadCurrencies());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: rows.isEmpty
                        ? const Center(child: Text("No Data Available"))
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
                                title: 'Currency Code',
                                field: 'code',
                                type: PlutoColumnType.text(),
                                width: 120,
                              ),
                              PlutoColumn(
                                title: 'Name',
                                field: 'name',
                                type: PlutoColumnType.text(),
                                width: 160,
                              ),
                              PlutoColumn(
                                title: 'Symbol',
                                field: 'symbol',
                                type: PlutoColumnType.text(),
                                width: 110,
                              ),
                              PlutoColumn(
                                title: 'Exchange Rate',
                                field: 'exchangeRate',
                                type: PlutoColumnType.number(),
                                width: 150,
                              ),
                              PlutoColumn(
                                title: 'Transaction Currency',
                                field: 'transactionCurrency',
                                type: PlutoColumnType.text(),
                                width: 180,
                              ),
                              PlutoColumn(
                                title: 'Functional Currency',
                                field: 'functionalCurrency',
                                type: PlutoColumnType.text(),
                                width: 180,
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
                                        onChanged: (bool value) {
                                          
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
                                  Currency selectedCurrency = currencyList[rowIndex];
                                  return TextButton.icon(
                                    //icon: const Icon(Icons.edit, size: 16),
                                    label: const Text("Detail"),
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => CurrencyListScreen(
                                            //currency: selectedCurrency, // Pass the selected currency
                                          ),
                                        ),
                                      ).then((_) => loadCurrencies());
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