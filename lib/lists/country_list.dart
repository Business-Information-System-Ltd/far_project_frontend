import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';

class CountryList extends StatefulWidget {
  const CountryList({super.key});

  @override
  State<CountryList> createState() => _CountryListState();
}

class _CountryListState extends State<CountryList> {
  late PlutoGridStateManager stateManager;
  List<PlutoRow> rows = [];
  bool isLoading = true;

  // Search နှင့် Filter variables
  String selectedStatus = 'Active';
  final TextEditingController searchController = TextEditingController();

  final List<PlutoColumn> columns = [
    _buildColumn('Country Code', 'code'),
    _buildColumn('Country Name', 'name'),
    _buildColumn('ISO Code', 'iso'),
    _buildColumn('Phone No', 'phone'),
    _buildColumn('Default Language', 'language'),
    _buildColumn('Date Format', 'format'),
    PlutoColumn(
      title: 'Status',
      field: 'status',
      type: PlutoColumnType.text(),
      enableContextMenu: false,
      enableSorting: false,
      enableColumnDrag: false,
      enableDropToResize: false,
      renderer: (rendererContext) => Transform.scale(
        scale: 0.8,
        child: Switch(
          value: rendererContext.cell.value == 'Active',
          activeTrackColor: Colors.blue,
          onChanged: (bool value) => rendererContext.stateManager
              .changeCellValue(rendererContext.cell, value ? 'Active' : 'Inactive'),
        ),
      ),
    ),
    PlutoColumn(
      title: 'Action',
      field: 'action',
      type: PlutoColumnType.text(),
      enableContextMenu: false,
      enableSorting: false,
      enableColumnDrag: false,
      enableDropToResize: false,
      renderer: (rendererContext) => TextButton(
        onPressed: () {},
        child: const Text("Detail",
            style: TextStyle(
                color: Colors.blue, )),
      ),
    ),
  ];

  static PlutoColumn _buildColumn(String title, String field) {
    return PlutoColumn(
      title: title,
      field: field,
      type: PlutoColumnType.text(),
      enableContextMenu: false,
      enableSorting: false,
      enableColumnDrag: false,
      enableDropToResize: false,
    );
  }

  @override
  void initState() {
    super.initState();
    _loadCountryData();
  }

  Future<void> _loadCountryData() async {
    try {
      final List<Country> fetchedCountries = await ApiService().fetchCountries();
      final List<PlutoRow> fetchedRows = fetchedCountries.map((country) {
        return PlutoRow(cells: {
          'code': PlutoCell(value: country.countryCode ?? ''),
          'name': PlutoCell(value: country.countryName ?? ''),
          'iso': PlutoCell(value: country.iso ?? ''),
          'phone': PlutoCell(value: country.phone ?? ''),
          'language': PlutoCell(value: country.defaultLanguage ?? ''),
          'format': PlutoCell(value: country.dateFormat ?? ''),
          'status': PlutoCell(value: country.isActive == true ? 'Active' : 'Inactive'),
          'action': PlutoCell(value: 'Detail'),
        });
      }).toList();

      if (mounted) {
        setState(() {
          rows = fetchedRows;
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error loading data: $e");
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Country List"), centerTitle: true),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Search Bar, Status Dropdown, Download Button 
                // Row 
Padding(
  padding: const EdgeInsets.all(16.0),
  child: Row(
    children: [
      // Status Label and Dropdown 
      const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          borderRadius: BorderRadius.circular(4),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedStatus,
            icon: const Icon(Icons.arrow_drop_down),
            items: ['Active', 'Inactive'].map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
            onChanged: (val) {
              setState(() => selectedStatus = val!);
            },
          ),
        ),
      ),
      const SizedBox(width: 16),
      // Search Bar
      Expanded(
        child: SizedBox(
          height: 48,
          child: TextField(
            controller: searchController,
            decoration: const InputDecoration(
              hintText: 'Search...',
              border: OutlineInputBorder(),
              contentPadding: EdgeInsets.symmetric(horizontal: 10),
            ),
          ),
        ),
      ),
      const SizedBox(width: 16),
      // Download PDF Button
      SizedBox(
        height: 48,
        child: ElevatedButton.icon(
          onPressed: () {},
          icon: const Icon(Icons.download),
          label: const Text("Download PDF"),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
        ),
      ),
    ],
  ),
),
const SizedBox(
  height: 30,
),
                // Grid 
                Expanded(
  child: Padding(
    
    padding: const EdgeInsets.symmetric(horizontal: 20), 
    child: PlutoGrid(
      columns: columns,
      rows: rows,
      onLoaded: (event) => stateManager = event.stateManager,
      configuration: const PlutoGridConfiguration(
        columnSize: PlutoGridColumnSizeConfig(
          autoSizeMode: PlutoAutoSizeMode.equal,
        ),
      ),
    ),
  ),
),
          
                
              ],
            ),
    );
  }
}