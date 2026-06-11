import 'package:far_project_frontend/forms/location_form.dart';
import 'package:flutter/material.dart';
import 'package:pluto_grid/pluto_grid.dart';
import 'package:far_project_frontend/api/api_service.dart';
import 'package:far_project_frontend/api/data.dart';
import 'package:far_project_frontend/details/location_details.dart';

class LocationList extends StatefulWidget {
  const LocationList({Key? key}) : super(key: key);

  @override
  State<LocationList> createState() => _LocationListState();
  }

class _LocationListState extends State<LocationList> {
  final ApiService _apiService = ApiService();

  

  List<PlutoColumn> mainColumns = [];
  List<PlutoRow> mainRows = [];
  PlutoGridStateManager? mainStateManager;

  List<Location> _locations = [];
  List<Country> _countries = [];

  bool _isLoading = true;
  bool _isAdvanceSearchChecked = false;
  String _selectedStatus = 'Active';

  final _searchCodeController = TextEditingController();
  final Color primaryBlue = const Color(0xFF1B51C4);

  @override
  void initState() {
    super.initState();
    _buildMainGridColumns();
    _loadAllGridData();
  }

  @override
  void dispose() {
    _searchCodeController.dispose();
    super.dispose();
  }
  void _createLocation() async {
    final result = await Navigator.push<Location?>(context,
    MaterialPageRoute(builder: (_) => const LocationRegisterForm()),);
  }
  Future<void> _downloadPDF() async {
  // TODO: Implement PDF download logic
  print("Downloading PDF...");
  
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Downloading PDF...'),
      duration: Duration(seconds: 2),
    ),
  );
}

  Future<void> _loadAllGridData() async {
  try {
    setState(() => _isLoading = true);
    
    final results = await Future.wait([
      _apiService.fetchLocations(), 
      _apiService.fetchCountries()
    ]);
    
    // Data ရလာပြီဆိုတာ သေချာအောင် ခဏစစ်ပါ
    List<Location> locs = results[0] as List<Location>;
    List<Country> couns = results[1] as List<Country>;
    
    print("DEBUG: Fetched ${couns.length} countries"); // ဒီမှာ 0 ထွက်နေရင် API က Data မလာတာပါ
    
    setState(() {
      _locations = locs;
      _countries = couns;
      // Data ရောက်မှပဲ Table ကို ဆောက်ပါ
      _updateMainGridRows(); 
      _isLoading = false;
    });
    
  } catch (e) {
    print("DEBUG: Error: $e");
    setState(() => _isLoading = false);
  }
}
  
  

  void _updateMainGridRows() {
    List<PlutoRow> fetchedRows = _locations.map((loc) {
      return PlutoRow(cells: {
        'code': PlutoCell(value: loc.locationCode ?? '-'),
        'name': PlutoCell(value: loc.locationName ?? '-'),
        'city': PlutoCell(value: loc.city ?? '-'),
        'country': PlutoCell(value: _getCountryName(loc.countryId)),
        'status': PlutoCell(value: loc.isActive ?? true),
        'action': PlutoCell(value: loc.locationId?.toString() ?? '-'),
      });
    }).toList();

    setState(() {
      mainRows = fetchedRows;
      _isLoading = false;
    });
  }

String _getCountryName(int? country_id) {
  if (country_id == null) return 'N/A';

  for (var c in _countries) {
    if (c.id == country_id) {
      return c.countryName ?? 'N/A';
    }
  }
  return 'N/A'; // Loading... အစား N/A ကိုပဲ ပြပါ
}
  void _buildMainGridColumns() {
    const TextStyle blueStyle = TextStyle(color: Color(0xFF1B51C4), fontWeight: FontWeight.bold);

    mainColumns = [
      PlutoColumn(title: 'Location Code', field: 'code', type: PlutoColumnType.text(), enableContextMenu: false, enableSorting: false, enableDropToResize: false),
      PlutoColumn(title: 'Location Name', field: 'name', type: PlutoColumnType.text(), enableContextMenu: false, enableSorting: false, enableDropToResize: false),
      PlutoColumn(title: 'City', field: 'city', type: PlutoColumnType.text(), enableContextMenu: false, enableSorting: false, enableDropToResize: false),
      PlutoColumn(title: 'Country', field: 'country', type: PlutoColumnType.text(), enableContextMenu: false, enableSorting: false, enableDropToResize: false),
      PlutoColumn(
        title: 'Status', field: 'status', type: PlutoColumnType.text(), enableContextMenu: false, enableSorting: false, enableDropToResize: false,
        renderer: (ctx) => Transform.scale(scale: 0.75, child: Switch(value: ctx.cell.value, activeColor: primaryBlue, onChanged: (v) {})),
      ),
      PlutoColumn(
  title: 'Action',
  field: 'action',
  type: PlutoColumnType.text(),
  // အကယ်၍ အလိုအလျောက်ချဲ့ခြင်း (Auto-scale) ကြောင့် နေရာကျဉ်းနေပါက width သတ်မှတ်ပေးပါ
  width: 150, 
  enableContextMenu: false,
  enableSorting: false,
  enableDropToResize: false,
  renderer: (ctx) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
       
        Flexible(
          child: TextButton(
            onPressed: () async {
              final location = _locations[ctx.rowIdx];
              final result = await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => LocationRegisterForm(location: location),
                ),
              );
              if (result == true) {
                _loadAllGridData();
              }
            },
            child: const Text('Edit', style: blueStyle, overflow: TextOverflow.ellipsis),
          ),
        ),
        const Text('/', style: TextStyle(color: Colors.grey)),
        Flexible(
  // LocationList.dart ထဲတွင် ...
child: TextButton(
  // LocationList.dart ထဲက Detail ခလုတ် onPressed ထဲမှာ ဒီလိုပြင်လိုက်ပါ
onPressed: () {
  final location = _locations[ctx.rowIdx];
  
  // Data အကုန်လုံးကို Map အနေနဲ့ သေချာစုစည်းပြီး ပို့ပါ
  final Map<String, dynamic> detailData = {
    'name': location.locationName,
    'code': location.locationCode,
    'type': location.locationType ?? '-', // သင့် model မှာရှိတဲ့ နာမည်အတိုင်းစစ်ပါ
    'parent_location': location.parentLocation ?? '-', 
    'is_active': location.isActive,
    'country': _getCountryName(location.countryId),
    'region': location.region ?? '-',
    'city': location.city ?? '-',
    'line1': location.line1 ?? '-',
    'gps_map_reference': location.gpsMapReference ?? '-',
    'created_at': location.createdAt?.toString(),
    'created_by': location.createdBy ?? 'System',
  };
  
// Location object တွေကို တိုက်ရိုက်ပို့ပါ
  // ✅ မှန်ကန်တဲ့ပုံစံ
Navigator.of(context).push(
  MaterialPageRoute(
    builder: (context) => LocationDetailsScreen(
      locationData: {
        'location_id': location.locationId,
        'name': location.locationName,
        'location_name': location.locationName,
        'code': location.locationCode,
        'location_code': location.locationCode,
        'location_type': location.locationType ?? 'Warehouse',
        'parent_location': location.parentLocation,
        'parentLocation': location.parentLocation,
        'is_active': location.isActive ?? true,
        'country_id': location.countryId,
        'region': location.region ?? '-',
        'city': location.city ?? '-',
        'line1': location.line1 ?? '-',
        'line2': location.line2 ?? '-',
        'street': location.line1 ?? '-',
        'additional': location.line2 ?? '-',
        'gps_map_reference': location.gpsMapReference ?? '-',
        'map_ref': location.gpsMapReference ?? '-',
        'created_at': location.createdAt?.toString(),
        'created_by': location.createdBy ?? 'System',
        'permissions': 'Customer View Only',
        'hierarchy': ['Main Office', 'Department', 'Warehouses'],
      },
      allLocations: _locations,
      countries: _countries,
    ),
  ),
);
},
  child: const Text('Detail', style: blueStyle, overflow: TextOverflow.ellipsis),
),
    
),
      ],
    );
  },
)
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      body: Container(
        margin: const EdgeInsets.all(24),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.grey.shade300)),
        child: Column(
          children: [
            const Center(child: Text('Location List', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold))),
            const SizedBox(height: 20),
            // ... (Search Row code)
            Row(
  children: [
    const Text("Status: ", style: TextStyle(fontWeight: FontWeight.bold)),
    // 1. Status Dropdown
    Container(
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(4),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedStatus,
          
          items: ['Active', 'Inactive'].map((String value) {
            return DropdownMenuItem<String>(value: value, child: Text(value));
          }).toList(),
          onChanged: (newValue) => setState(() => _selectedStatus = newValue!),
        ),
      ),
    ),
    const SizedBox(width: 15),

    // 2. Search Bar
    Expanded(
      child: TextField(
        controller: _searchCodeController,
        decoration: InputDecoration(
          hintText: "Search...",
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(4)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
        ),
      ),
    ),
    const SizedBox(width: 15),

    // 3. Advance Search Checkbox
    Row(
      children: [
        Checkbox(
          value: _isAdvanceSearchChecked,
          onChanged: (val) => setState(() => _isAdvanceSearchChecked = val!),
        ),
        const Text("Advance Search"),
      ],
    ),
  ],
),
const SizedBox(height: 15),
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,  // ဘယ်ညာ ခွာဖို့ spaceBetween ထားပါ
  children: [
    ElevatedButton.icon(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LocationRegisterForm()),
        );
        if (result != null && mounted) {
          _loadAllGridData();
        }
      },
      icon: const Icon(Icons.add, size: 18),
      label: const Text("Add New"),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
    ElevatedButton.icon(
      onPressed: _downloadPDF,
      icon: const Icon(Icons.picture_as_pdf, size: 18),
      label: const Text("Download PDF"),
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryBlue,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      ),
    ),
  ],
),
  

  

            const SizedBox(height: 20),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : PlutoGrid(
                      columns: mainColumns,
                      rows: mainRows,
                      onLoaded: (e) => mainStateManager = e.stateManager,
                      configuration: const PlutoGridConfiguration(
                        columnSize: PlutoGridColumnSizeConfig(autoSizeMode: PlutoAutoSizeMode.scale),
                        style: PlutoGridStyleConfig(iconSize: 0),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}