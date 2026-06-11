import 'package:flutter/material.dart';
import 'package:far_project_frontend/api/data.dart';
import 'package:far_project_frontend/forms/branch_form.dart'; 

class BranchDetailScreen extends StatefulWidget {
  final Branch branch;

  const BranchDetailScreen({Key? key, required this.branch}) : super(key: key);

  @override
  State<BranchDetailScreen> createState() => _BranchDetailScreenState();
}

class _BranchDetailScreenState extends State<BranchDetailScreen> {
  late Branch currentBranch;

  @override
  void initState() {
    super.initState();
    currentBranch = widget.branch; 
  }

  String _formatDate(String? dateTimeStr) {
    if (dateTimeStr == null || dateTimeStr.isEmpty) return '-';
    try {
      return dateTimeStr.split('T')[0];
    } catch (e) {
      return dateTimeStr;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), 
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Branch Details Title Card
                      _buildCard(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                        children: [
                          const Text(
                            'Branch Details', 
                            style: TextStyle(
                              color: Colors.black87, 
                              fontWeight: FontWeight.bold, 
                              fontSize: 16, 
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4), 

                      // Header Card (Icon + Title + Status)
                      _buildHeaderCard(),
                      const SizedBox(height: 4),

                      // Branch Information Card
                      _buildBranchInfoCard(),
                      const SizedBox(height: 4),

                      // Address & Contact Information Card 
                      IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch, 
                          children: [
                            Expanded(
                              child: _buildSectionCard('Address', [
                                _buildInfoTile('Address', currentBranch.address ?? '-'),
                              ]),
                            ),
                            const SizedBox(width: 4), 
                            Expanded(
                              child: _buildSectionCard('Contact Information', [
                                _buildInfoTile('Phone Number', currentBranch.phone ?? '-'),
                                const SizedBox(height: 4), 
                                _buildInfoTile('Email Address', currentBranch.email ?? '-'),
                              ]),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Status Card
                      _buildStatusCard(),
                      const SizedBox(height: 4), 

                      // Action Buttons (Edit & Go Back )
                      _buildActionButtons(context),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // Common Card Builder 
  Widget _buildCard({required List<Widget> children, EdgeInsetsGeometry? padding}) {
    return Container(
      width: double.infinity,
      padding: padding ?? const EdgeInsets.all(16.0), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6), 
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.01),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: children,
      ),
    );
  }

  // Section Card Builder
  Widget _buildSectionCard(String title, List<Widget> content) {
    return Container(
      padding: const EdgeInsets.all(16.0), 
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start, 
        children: [
          Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), 
          const SizedBox(height: 4), 
        ],
      ),
    );
  }

  // Info Tile Builder 
  Widget _buildInfoTile(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: TextStyle(color: Colors.grey.shade500, fontSize: 11, fontWeight: FontWeight.w500)), 
        const SizedBox(height: 2), 
        Text(value, style: const TextStyle(color: Colors.black87, fontSize: 13, fontWeight: FontWeight.w600, height: 1.2)), 
      ],
    );
  }

  //Header Card Widget
  Widget _buildHeaderCard() {
    bool isActive = currentBranch.isActive ?? false;
    return _buildCard(
      padding: const EdgeInsets.all(16.0),
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 20, 
              backgroundColor: const Color(0xFF4A3AFF), 
              child: const Icon(Icons.storefront, color: Colors.white, size: 20), 
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        currentBranch.branchName ?? 'Unknown Branch', 
                        style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.black87) 
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                        decoration: BoxDecoration(
                          color: isActive ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          isActive ? 'Active' : 'Inactive',
                          style: TextStyle(
                            color: isActive ? const Color(0xFF137333) : const Color(0xFFC5221F), 
                            fontSize: 10, 
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Branch Code: ${currentBranch.branchCode ?? "-"}', 
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12, fontWeight: FontWeight.w500) 
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Added on ${_formatDate(currentBranch.createdAt)}  •  Last updated on ${_formatDate(currentBranch.updatedAt)}',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 11), 
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Branch Information Card Widget
  Widget _buildBranchInfoCard() {
    return _buildCard(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Branch Information', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)), 
        const SizedBox(height: 4),
        Table(
          columnWidths: const {
            0: FlexColumnWidth(),
            1: FlexColumnWidth(),
          },
          children: [
            TableRow(
              children: [
                
                Padding(padding: const EdgeInsets.only(bottom: 6), child: _buildInfoTile('Branch Code', currentBranch.branchCode ?? '-')),
                Padding(padding: const EdgeInsets.only(bottom: 6), child: _buildInfoTile('Branch Name', currentBranch.branchName ?? '-')),
              ],
            ),
            TableRow(
              children: [
              
                Padding(padding: const EdgeInsets.only(bottom: 6), child: _buildInfoTile('Country', currentBranch.countryName ?? '-')),
                Padding(padding: const EdgeInsets.only(bottom: 6), child: _buildInfoTile('Region/State', currentBranch.region ?? '-')),
              ],
            ),
            TableRow(
              children: [
                _buildInfoTile('City / Township', currentBranch.city ?? '-'),
                _buildInfoTile('Postal Code', currentBranch.postalCode?.toString() ?? '-'),
              ],
            ),
          ],
        ),
      ],
    );
  }

  //Status Card Widget
  Widget _buildStatusCard() {
    bool isActive = currentBranch.isActive ?? false;
    return _buildCard(
      padding: const EdgeInsets.all(16.0),
      children: [
        const Text('Status', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.black87)),
        const Divider(height: 12, thickness: 1), 
        Row(
          children: [
            Text('Status', style: TextStyle(color: Colors.grey.shade500, fontSize: 12, fontWeight: FontWeight.w500)),
            const SizedBox(width: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: isActive ? const Color(0xFFE6F4EA) : const Color(0xFFFCE8E6),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                isActive ? 'Active' : 'Inactive',
                style: TextStyle(
                  color: isActive ? const Color(0xFF137333) : const Color(0xFFC5221F), 
                  fontSize: 10, 
                  fontWeight: FontWeight.bold
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // Action Buttons Widget (Edit & Go Back)
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center, 
      children: [
        ElevatedButton.icon(
          onPressed: () async {
            final result = await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => AddBranchForm(branch: currentBranch),
              ),
            );
            
            if (result != null && result is Branch) {
              setState(() {
                currentBranch = result;
              });
            }
          },
          icon: const Icon(Icons.edit, size: 14),
          label: const Text('Edit Branch', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), 
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF4A3AFF), 
            foregroundColor: Colors.white,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
        const SizedBox(width: 12),
        OutlinedButton.icon(
          onPressed: () {
            Navigator.of(context).pop(currentBranch); 
          },
          icon: const Icon(Icons.arrow_back, size: 14, color: Colors.black87),
          label: const Text('Go Back to List', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.black87)), 
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: Colors.grey.shade300),
            backgroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12), 
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
          ),
        ),
      ],
    );
  }
}