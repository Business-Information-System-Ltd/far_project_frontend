  
import 'package:far_project_frontend/api/data.dart';
import 'package:flutter/material.dart';

class LocationDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> locationData;
  final List<dynamic> allLocations;
  final dynamic countries;

  const LocationDetailsScreen({super.key,
    required this.locationData, 
    required this.allLocations,
    required this.countries,
  });
   
  String _getParentName(int? parentLocation) {
  print("DEBUG: Looking for parentLocation ID: $parentLocation");
  print("DEBUG: All locations count: ${allLocations.length}");
  
  if (parentLocation == null) return 'None';
  
  try {
    final parent = allLocations.firstWhere(
      (loc) {
        // Location object ဖြစ်နေရင်
        if (loc is Location) {
          print("Comparing Location ID: ${loc.locationId} == $parentLocation ? ${loc.locationId == parentLocation}");
          return loc.locationId == parentLocation;
        }
        // Map ဖြစ်နေရင်
        else {
          int locId = loc['location_id'] ?? loc['id'] ?? -1;
          print("Comparing Map ID: $locId == $parentLocation ? ${locId == parentLocation}");
          return locId == parentLocation;
        }
      },
    );
    
    print("DEBUG: Found parent!");
    if (parent is Location) {
      print("DEBUG: Parent name: ${parent.locationName}");
      return parent.locationName ?? 'Unknown';
    } else {
      print("DEBUG: Parent name: ${parent['location_name'] ?? parent['name']}");
      return parent['location_name'] ?? parent['name'] ?? 'Unknown';
    }
  } catch (e) {
    print("DEBUG: Parent not found! Error: $e");
    return 'None';
  }
}
  
  String _getCountryName(int? countryId) {
    if (countryId == null) return 'N/A';
    for (var country in countries) {
      if (country.id == countryId) {
        return country.countryName ?? 'N/A';
      }
    }
    return 'N/A';
  }
  
  // Helper method to safely get string value
  String _getStringValue(dynamic value, {String defaultValue = '-'}) {
    if (value == null) return defaultValue;
    if (value is String) return value.isEmpty ? defaultValue : value;
    if (value is int) return value.toString();
    if (value is double) return value.toString();
    if (value is bool) return value.toString();
    return defaultValue;
  }

  // Helper method to safely get bool value
  bool _getBoolValue(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    return defaultValue;
  }

  // Helper method to safely get list
  List<String> _getListValue(dynamic value) {
    if (value == null) return ["Main Office", "Department", "Warehouses"];
    if (value is List) {
      return value.map((item) => item.toString()).toList();
    }
    return ["Main Office", "Department", "Warehouses"];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.3),
                    spreadRadius: 2,
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Location Details Title (centered above location name)
                    Center(
                      child: Text(
                        "Location Details",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.purple[700],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildHeaderSection(),
                    const SizedBox(height: 8),
                    _buildTypeParentSection(),
                    const SizedBox(height: 24),

                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          flex: 1,
                          child: _buildAddressSection(),
                        ),
                        const SizedBox(width: 20),
                        Expanded(
                          flex: 1,
                          child: Column(
                            children: [
                              _buildHierarchySection(),
                              const SizedBox(height: 20),
                              _buildCompanyRootSection(),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    _buildPermissionsAndCreatedBySection(),
                    const SizedBox(height: 20),

                    _buildKamayutBadge(),
                    const SizedBox(height: 32),

                    _buildActionButtons(context),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ==================== HEADER SECTION ====================
  Widget _buildHeaderSection() {
    String locationName = _getStringValue(
      locationData['name'] ?? locationData['location_name'],
      defaultValue: 'Yangon Main Warehouse (HQ-01-W01)',
    );
    
    bool isActive = _getBoolValue(locationData['is_active']);
    
    String locationCode = _getStringValue(
      locationData['location_code'] ?? locationData['code'],
      defaultValue: 'LOC-2026-001',
    );

    return Row(
      children: [
        Expanded(
          child: Text(
            locationName,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ),
        Text(
          isActive ? "ACTIVE" : "INACTIVE",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 14,
            color: isActive ? Colors.green[700] : Colors.red[700],
          ),
        ),
        const SizedBox(width: 16),
        Text(
          locationCode,
          style: TextStyle(
            fontSize: 14,
            fontFamily: 'monospace',
            color: Colors.grey[600],
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTypeParentSection() {
    String locationType = _getStringValue(locationData['location_type'], defaultValue: 'Warehouse');
    String parentName = _getParentName(locationData['parent_location']);

    return Text(
      "Type: $locationType | Parent: $parentName",
      style: TextStyle(color: Colors.grey[600], fontSize: 14),
    );
  }

  // ==================== ADDRESS DETAILS SECTION ====================
  Widget _buildAddressSection() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, size: 20, color: Colors.purple[400]),
                const SizedBox(width: 8),
                const Text(
                  "Address Details",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              "Location Address",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Country
            _buildVerticalInfoRow("Country", _getCountryName(locationData['country_id'])),
            const SizedBox(height: 12),
            // Region and City Labels (တစ်တန်းတည်း)
            Row(
              children: [
                Expanded(
                  child: Text(
                    "Region",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
                Expanded(
                  child: Text(
                    "City",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 4),
            // Region and City Data (အောက်မှာ - တစ်တန်းတည်း)
            Row(
              children: [
                Expanded(
                  child: Text(
                    _getStringValue(locationData['region']),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
                Expanded(
                  child: Text(
                    _getStringValue(locationData['city']),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // Street
            _buildVerticalInfoRow("Street", locationData['line1'] ?? locationData['street']),
            const SizedBox(height: 12),
            // Additional
            _buildVerticalInfoRow("Additional", locationData['line2'] ?? locationData['additional']),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 12),
            const Text(
              "Map & Directions",
              style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
            ),
            const SizedBox(height: 12),
            // Map Ref
            _buildVerticalInfoRow("Map Ref", locationData['gps_map_reference'] ?? locationData['map_ref']),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () {},
              child: Row(
                children: [
                  Text(
                    "View Map & Directions",
                    style: TextStyle(color: const Color.fromARGB(255, 171, 91, 196), fontSize: 13),
                  ),
                  const SizedBox(width: 6),
                  Icon(Icons.arrow_forward, size: 16, color: const Color.fromARGB(255, 171, 91, 196)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerticalInfoRow(String label, dynamic value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(color: Colors.grey[600], fontSize: 13),
        ),
        const SizedBox(height: 4),
        Text(
          _getStringValue(value),
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  //  LOCATION HIERARCHY SECTION 
  Widget _buildHierarchySection() {
    List<String> hierarchyItems = _getListValue(locationData['hierarchy']);
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.account_tree, size: 20, color: Colors.purple[400]),
                const SizedBox(width: 8),
                const Text(
                  "Location Hierarchy",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            // (horizontal scroll)
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: hierarchyItems.asMap().entries.map((entry) {
                  int index = entry.key;
                  String item = entry.value;
                  bool isLast = index == hierarchyItems.length - 1;
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.folder, size: 14, color: Colors.amber[600]),
                      const SizedBox(width: 4),
                      Text(item, style: const TextStyle(fontSize: 14)),
                      if (!isLast) const SizedBox(width: 8),
                      if (!isLast) const Text("›", style: TextStyle(fontSize: 16, color: Colors.grey)),
                    ],
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  //  COMPANY ROOT SECTION 
  Widget _buildCompanyRootSection() {
    int? parentLocationValue;
    dynamic parentData = locationData['parent_location'] ?? locationData['parentLocation'];
    
    if (parentData != null) {
      if (parentData is int) {
        parentLocationValue = parentData;
      } else if (parentData is String) {
        parentLocationValue = int.tryParse(parentData);
      }
    }
    
    String parentName = _getParentName(parentLocationValue);
    String locationName = _getStringValue(
      locationData['name'] ?? locationData['location_name'],
      defaultValue: 'HQ-01-W01 - Warehouse 1',
    );
    
    String parentBase = parentName.split(' (')[0];
    String locationBase = locationName.split(' (')[0];
    
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.business, size: 20, color: Colors.purple[400]),
                const SizedBox(width: 8),
                const Text(
                  "Company Root",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Icon(Icons.folder_open, size: 16, color: Colors.blue[600]),
                const SizedBox(width: 8),
                Text(parentName, style: const TextStyle(fontSize: 14)),
              ],
            ),
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.only(left: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildTreeItem("$parentBase - Sales"),
                  const SizedBox(height: 4),
                  _buildTreeItem("$parentBase - Logistics"),
                  const SizedBox(height: 4),
                  _buildTreeItem(locationBase),
                  const SizedBox(height: 4),
                  _buildTreeItem("$parentBase - HR"),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTreeItem(String text) {
    return Row(
      children: [
        Icon(Icons.folder, size: 14, color: Colors.amber[600]),
        const SizedBox(width: 8),
        Text(text, style: const TextStyle(fontSize: 14)),
      ],
    );
  }

  //  PERMISSIONS AND CREATED 
  Widget _buildPermissionsAndCreatedBySection() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock_outline, size: 20, color: Colors.purple[400]),
                      const SizedBox(width: 8),
                      const Text(
                        "Permissions",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getStringValue(locationData['permissions'], defaultValue: 'Customer View Only'),
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.person_outline, size: 20, color: Colors.purple[400]),
                      const SizedBox(width: 8),
                      const Text(
                        "Created by",
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "${_getStringValue(locationData['created_by'], defaultValue: 'Admin')} on ${_formatDate(locationData['created_at'])}",
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  //  KAMAYUT BADGE 
  Widget _buildKamayutBadge() {
    String city = _getStringValue(locationData['city'], defaultValue: 'KAMAYUT').toUpperCase();
    String region = _getStringValue(locationData['region'], defaultValue: 'YANGON').toUpperCase();
    
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.purple[50],
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.purple[100]!),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.location_on, size: 14, color: Colors.purple[400]),
            const SizedBox(width: 6),
            Text(
              "$city • $region",
              style: TextStyle(fontSize: 11, color: Colors.purple[700], fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(dynamic dateValue) {
    if (dateValue == null) return '2026-06-01';
    String dateStr = _getStringValue(dateValue);
    if (dateStr.contains(' ')) {
      return dateStr.split(' ')[0];
    }
    return dateStr;
  }

  // ACTION BUTTONS 
  Widget _buildActionButtons(BuildContext context) {
    return Center(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color.fromARGB(255, 171, 91, 196),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text("Edit Location"),
          ),
          const SizedBox(width: 12),
          OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              textStyle: const TextStyle(fontSize: 13),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
            ),
            child: const Text("Go Back to List"),
          ),
        ],
      ),
    );
  }
}