import 'package:flutter/material.dart';
import '../api/data.dart';
import '../api/api_service.dart';
class CurrencyDetailScreen extends StatefulWidget {
  final Currency currency;
  const CurrencyDetailScreen({Key? key, required this.currency}) : super(key: key);

  @override
  State<CurrencyDetailScreen> createState() => _CurrencyDetailScreenState();
}
class _CurrencyDetailScreenState extends State<CurrencyDetailScreen> {
  late Currency _currency;
  final ApiService _apiService = ApiService();
  bool _isLoading = false;
  late TextEditingController _exchangeRateController;
  late TextEditingController _transactionCurrencyController;
  late TextEditingController _amountRoundingPrecisionController;
  late TextEditingController _depreciationRoundingController;
  late TextEditingController _depreciationRoundingAlternateController;
  late bool _isFunctionalCurrency;
  late bool _isPresentationCurrency;
  late bool _allowTransactionCurrency;
  late bool _allowExchangeRateEntry;
  late bool _isActive;

  @override
  void initState() {
    super.initState();
    _currency = widget.currency;
    _initializeControllers();
  }

  void _initializeControllers() {
    _exchangeRateController = TextEditingController(
      text: _currency.exchangeRate?.toStringAsFixed(2) ?? "2100.00",
    );
    _transactionCurrencyController = TextEditingController(
      text: _currency.transactionCurrency ?? "MYR",
    );
    
    _amountRoundingPrecisionController = TextEditingController(
      text: _currency.amountRoundingPrecision?.toStringAsFixed(2) ?? "1.00",
    );
    _depreciationRoundingController = TextEditingController(
      text: _currency.depreciationRounding?.toStringAsFixed(2) ?? "1.00",
    );
    _depreciationRoundingAlternateController = TextEditingController(
      text: _currency.depreciationRoundingAlternate?.toStringAsFixed(2) ?? "1.00",
    );
    
    _isFunctionalCurrency = _currency.isFunctionalCurrency ?? false;
    _isPresentationCurrency = _currency.isPresentationCurrency ?? false;
    _allowTransactionCurrency = _currency.allowTransactionCurrency ?? false;
    _allowExchangeRateEntry = true;
    _isActive = _currency.isActive ?? true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Currency Details"),
        backgroundColor: const Color(0xFF1E56A0),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12.0),
              child: Center(
          
              child: Container(
                  width: 800,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade400, width: 1.5),
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.shade200,
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                          border: Border(
                            bottom: BorderSide(
                              color: Colors.grey.shade300,
                              width: 1,
                            ),
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            "Currencies Detail",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E56A0),
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(14.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  flex: 1,
                                  child: Padding(
                                    padding: const EdgeInsets.only(right: 8.0),
                                    child: _buildCurrencyInfoSection(),
                                  ),
                                ),
                                Expanded(
                                  flex: 1,
                                  child: Column(
                                    children: [
                                      _buildAmountPrecisionSection(),
                                      const SizedBox(height: 12),
                                      _buildExchangeRateSection(),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Center(
                              child: ElevatedButton.icon(
                                onPressed: () => Navigator.pop(context),
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 16),
                                label: const Text(
                                  "Back to List",
                                  style: TextStyle(color: Colors.white, fontSize: 13),
                                ),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1E56A0),
                                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
    );
  }
  Future<void> _refreshData() async {
    setState(() => _isLoading = true);
    final currencies = await _apiService.fetchCurrencies();
    final latestCurrency = currencies.firstWhere(
      (c) => c.currencyId == _currency.currencyId,
      orElse: () => _currency,
    );
    setState(() {
      _currency = latestCurrency;
      _initializeControllers();
      _isLoading = false;
    });
  }
  Widget _buildCurrencyInfoSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              "Currency & Core Info",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 14, 55, 126)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildInfoRow("Currency Code:", _currency.currencyCode ?? "MMK"),
                const SizedBox(height: 6),
                _buildInfoRow("Currency Name:", _currency.currencyName ?? "Myanmar Kyat"),
                const SizedBox(height: 6),
                _buildInfoRow("Currency Symbol:", _currency.currencySymbol ?? "Ks"),
                const SizedBox(height: 6),
                _buildInfoRow("Decimal Places:", _currency.decimalPlaces?.toString() ?? "0"),
                const SizedBox(height: 6),
                _buildStatusRow("Is Functional Currency?", _isFunctionalCurrency),
                const SizedBox(height: 6),
                _buildStatusRow("Is Presentation Currency?", _isPresentationCurrency),
                const SizedBox(height: 6),
                _buildStatusRow("Allow Transaction Currency?", _allowTransactionCurrency),
                const SizedBox(height: 6),
                _buildStatusRow("Allow Exchange Rate Entry?", _allowExchangeRateEntry),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildAmountPrecisionSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              "Amounts & Precision",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 10, 58, 139)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildEditableRow("Amount Rounding Precision:", _amountRoundingPrecisionController),
                const SizedBox(height: 6),
                _buildEditableRow("Depreciation Rounding:", _depreciationRoundingController),
                const SizedBox(height: 6),
                _buildEditableRow("Depreciation Rounding (alternate):", _depreciationRoundingAlternateController),
                const SizedBox(height: 6),
                _buildEditableRow("Functional Currency (Exchange):", _exchangeRateController),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildExchangeRateSection() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300, width: 1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(6),
                topRight: Radius.circular(6),
              ),
            ),
            child: const Text(
              "Exchange Rate",
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: Color.fromARGB(255, 9, 53, 128)),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                _buildInfoRow("Exchange Rate (Multiplier):", "1"),
                const SizedBox(height: 6),
                _buildEditableRow("Transaction Currency:", _transactionCurrencyController),
                const SizedBox(height: 6),
                _buildStatusRow("Active Status:", _isActive),
              ],
            ),
          ),
        ],
      ),
    );
  }
  Widget _buildInfoRow(String label, String value) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(fontSize: 12)),
        ),
      ],
    );
  }
  Widget _buildEditableRow(String label, TextEditingController controller) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 12)),
        ),
        Expanded(
          child: TextFormField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              isDense: true,
            ),
            style: const TextStyle(fontSize: 12),
          ),
        ),
      ],
    );
  }
  Widget _buildStatusRow(String label, bool value) {
    return Row(
      children: [
        SizedBox(
          width: 150,
          child: Text(label, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11)),
        ),
        IgnorePointer(
          ignoring: true,
          child: Transform.scale(
            scale: 0.6,
            child: Switch(
              value: value,
              onChanged: null,
              activeColor: Colors.white,
              activeTrackColor: Colors.blue,
              inactiveThumbColor: const Color.fromARGB(255, 244, 245, 247),
              inactiveTrackColor: const Color.fromARGB(255, 76, 158, 240),
            ),
          ),
        ),
        const SizedBox(width: 4),
              ],
    );
  }

  @override
  void dispose() {
    _exchangeRateController.dispose();
    _transactionCurrencyController.dispose();
    _amountRoundingPrecisionController.dispose();
    _depreciationRoundingController.dispose();
    _depreciationRoundingAlternateController.dispose();
    super.dispose();
  }
}
