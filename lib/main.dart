import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const JiffyMasterApp());
}

class JiffyMasterApp extends StatelessWidget {
  const JiffyMasterApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Jiffy Master Calculator',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const MasterCalculatorPage(),
    );
  }
}

class SavedQuote {
  const SavedQuote({
    required this.receiptNumber,
    required this.createdAt,
    required this.customerName,
    required this.vehicleNotes,
    required this.service,
    required this.paymentMethod,
    required this.companyPartsCost,
    required this.markupPercentage,
    required this.markupAmount,
    required this.customerPartsPrice,
    required this.serviceCall,
    required this.taxRate,
    required this.taxAmount,
    required this.subtotal,
    required this.customerTotal,
    required this.partsProfit,
    required this.totalProfit,
  });

  final String receiptNumber;
  final DateTime createdAt;
  final String customerName;
  final String vehicleNotes;
  final String service;
  final String paymentMethod;
  final double companyPartsCost;
  final double markupPercentage;
  final double markupAmount;
  final double customerPartsPrice;
  final double serviceCall;
  final double taxRate;
  final double taxAmount;
  final double subtotal;
  final double customerTotal;
  final double partsProfit;
  final double totalProfit;

  Map<String, dynamic> toJson() {
    return {
      'receiptNumber': receiptNumber,
      'createdAt': createdAt.toIso8601String(),
      'customerName': customerName,
      'vehicleNotes': vehicleNotes,
      'service': service,
      'paymentMethod': paymentMethod,
      'companyPartsCost': companyPartsCost,
      'markupPercentage': markupPercentage,
      'markupAmount': markupAmount,
      'customerPartsPrice': customerPartsPrice,
      'serviceCall': serviceCall,
      'taxRate': taxRate,
      'taxAmount': taxAmount,
      'subtotal': subtotal,
      'customerTotal': customerTotal,
      'partsProfit': partsProfit,
      'totalProfit': totalProfit,
    };
  }

  factory SavedQuote.fromJson(Map<String, dynamic> json) {
    double number(String key) => (json[key] as num?)?.toDouble() ?? 0;

    return SavedQuote(
      receiptNumber: json['receiptNumber']?.toString() ?? '',
      createdAt:
      DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      customerName: json['customerName']?.toString() ?? '',
      vehicleNotes: json['vehicleNotes']?.toString() ?? '',
      service: json['service']?.toString() ?? 'Tire Replacement',
      paymentMethod: json['paymentMethod']?.toString() ?? 'Not Selected',
      companyPartsCost: number('companyPartsCost'),
      markupPercentage: number('markupPercentage'),
      markupAmount: number('markupAmount'),
      customerPartsPrice: number('customerPartsPrice'),
      serviceCall: number('serviceCall'),
      taxRate: number('taxRate'),
      taxAmount: number('taxAmount'),
      subtotal: number('subtotal'),
      customerTotal: number('customerTotal'),
      partsProfit: number('partsProfit'),
      totalProfit: number('totalProfit'),
    );
  }
}

class MasterCalculatorPage extends StatefulWidget {
  const MasterCalculatorPage({super.key});

  @override
  State<MasterCalculatorPage> createState() =>
      _MasterCalculatorPageState();
}

class _MasterCalculatorPageState extends State<MasterCalculatorPage> {
  static const String _quotesStorageKey = 'jiffy_master_saved_quotes';
  static const String _counterStorageKey = 'jiffy_master_receipt_counter';

  final TextEditingController customerNameController =
  TextEditingController();
  final TextEditingController vehicleController = TextEditingController();
  final TextEditingController serviceCallController =
  TextEditingController(text: '125.00');
  final TextEditingController companyPartsCostController =
  TextEditingController();
  final TextEditingController taxRateController =
  TextEditingController(text: '10.00');
  final TextEditingController searchController = TextEditingController();

  String selectedService = 'Tire Replacement';
  String selectedPaymentMethod = 'Not Selected';

  double markupPercentage = 80;
  double companyPartsCost = 0;
  double markupAmount = 0;
  double customerPartsPrice = 0;
  double serviceCall = 0;
  double taxRate = 0;
  double subtotal = 0;
  double taxAmount = 0;
  double customerTotal = 0;
  double partsProfit = 0;
  double totalProfit = 0;

  int nextReceiptCounter = 1;
  bool isLoadingSavedQuotes = true;
  List<SavedQuote> savedQuotes = [];

  final List<String> services = const [
    'Tire Replacement',
    'Tire Change',
    'Jump Start',
    'Battery Replacement',
    'Vehicle Lockout',
    'Fuel Delivery',
    'Other Roadside Service',
  ];

  final List<String> paymentMethods = const [
    'Not Selected',
    'Cash',
    'Zelle',
    'Cash App',
    'Apple Pay',
    'Credit Card',
    'Other',
  ];

  @override
  void initState() {
    super.initState();
    _loadSavedData();
    searchController.addListener(_refreshSearch);
  }

  void _refreshSearch() {
    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _loadSavedData() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final String? savedJson =
    preferences.getString(_quotesStorageKey);
    final int counter =
        preferences.getInt(_counterStorageKey) ?? 1;

    final List<SavedQuote> loadedQuotes = [];

    if (savedJson != null && savedJson.isNotEmpty) {
      try {
        final List<dynamic> decoded =
        jsonDecode(savedJson) as List<dynamic>;

        for (final dynamic item in decoded) {
          if (item is Map<String, dynamic>) {
            loadedQuotes.add(SavedQuote.fromJson(item));
          } else if (item is Map) {
            loadedQuotes.add(
              SavedQuote.fromJson(
                Map<String, dynamic>.from(item),
              ),
            );
          }
        }
      } catch (_) {
        // Keep the app running if old saved data is damaged.
      }
    }

    loadedQuotes.sort(
          (SavedQuote a, SavedQuote b) =>
          b.createdAt.compareTo(a.createdAt),
    );

    if (!mounted) {
      return;
    }

    setState(() {
      savedQuotes = loadedQuotes;
      nextReceiptCounter = counter;
      isLoadingSavedQuotes = false;
    });
  }

  Future<void> _saveData() async {
    final SharedPreferences preferences =
    await SharedPreferences.getInstance();

    final String encoded = jsonEncode(
      savedQuotes
          .map((SavedQuote quote) => quote.toJson())
          .toList(),
    );

    await preferences.setString(_quotesStorageKey, encoded);
    await preferences.setInt(
      _counterStorageKey,
      nextReceiptCounter,
    );
  }

  double parseNumber(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
  }

  String money(double amount) {
    return '\$${amount.toStringAsFixed(2)}';
  }

  String formatReceiptNumber(int counter) {
    final String year = DateTime.now().year.toString();
    final String sequence = counter.toString().padLeft(4, '0');
    return 'JRA-$year-$sequence';
  }

  String formatDate(DateTime value) {
    final DateTime local = value.toLocal();
    final String month = local.month.toString().padLeft(2, '0');
    final String day = local.day.toString().padLeft(2, '0');
    final String hour = local.hour.toString().padLeft(2, '0');
    final String minute = local.minute.toString().padLeft(2, '0');

    return '$month/$day/${local.year} $hour:$minute';
  }

  void calculatePrice() {
    final double enteredPartsCost =
    parseNumber(companyPartsCostController);
    final double enteredServiceCall =
    parseNumber(serviceCallController);
    final double enteredTaxRate =
    parseNumber(taxRateController);

    final double calculatedMarkup =
        enteredPartsCost * (markupPercentage / 100);
    final double calculatedCustomerPartsPrice =
        enteredPartsCost + calculatedMarkup;
    final double calculatedSubtotal =
        calculatedCustomerPartsPrice + enteredServiceCall;
    final double calculatedTax =
        calculatedSubtotal * (enteredTaxRate / 100);

    setState(() {
      companyPartsCost = enteredPartsCost;
      markupAmount = calculatedMarkup;
      customerPartsPrice = calculatedCustomerPartsPrice;
      serviceCall = enteredServiceCall;
      taxRate = enteredTaxRate;
      subtotal = calculatedSubtotal;
      taxAmount = calculatedTax;
      customerTotal = calculatedSubtotal + calculatedTax;
      partsProfit = calculatedMarkup;
      totalProfit = calculatedMarkup + enteredServiceCall;
    });

    FocusScope.of(context).unfocus();
  }

  void clearCalculator() {
    setState(() {
      customerNameController.clear();
      vehicleController.clear();
      serviceCallController.text = '125.00';
      companyPartsCostController.clear();
      taxRateController.text = '10.00';

      selectedService = 'Tire Replacement';
      selectedPaymentMethod = 'Not Selected';
      markupPercentage = 80;

      companyPartsCost = 0;
      markupAmount = 0;
      customerPartsPrice = 0;
      serviceCall = 0;
      taxRate = 0;
      subtotal = 0;
      taxAmount = 0;
      customerTotal = 0;
      partsProfit = 0;
      totalProfit = 0;
    });
  }

  SavedQuote _buildCurrentQuote(String receiptNumber) {
    return SavedQuote(
      receiptNumber: receiptNumber,
      createdAt: DateTime.now(),
      customerName: customerNameController.text.trim(),
      vehicleNotes: vehicleController.text.trim(),
      service: selectedService,
      paymentMethod: selectedPaymentMethod,
      companyPartsCost: companyPartsCost,
      markupPercentage: markupPercentage,
      markupAmount: markupAmount,
      customerPartsPrice: customerPartsPrice,
      serviceCall: serviceCall,
      taxRate: taxRate,
      taxAmount: taxAmount,
      subtotal: subtotal,
      customerTotal: customerTotal,
      partsProfit: partsProfit,
      totalProfit: totalProfit,
    );
  }

  Future<void> saveQuote() async {
    calculatePrice();

    final String receiptNumber =
    formatReceiptNumber(nextReceiptCounter);
    final SavedQuote quote = _buildCurrentQuote(receiptNumber);

    setState(() {
      savedQuotes.insert(0, quote);
      nextReceiptCounter += 1;
    });

    await _saveData();

    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Saved quote $receiptNumber'),
      ),
    );
  }

  Future<void> deleteQuote(SavedQuote quote) async {
    setState(() {
      savedQuotes.removeWhere(
            (SavedQuote item) =>
        item.receiptNumber == quote.receiptNumber,
      );
    });

    await _saveData();
  }

  void loadQuote(SavedQuote quote) {
    setState(() {
      customerNameController.text = quote.customerName;
      vehicleController.text = quote.vehicleNotes;
      serviceCallController.text =
          quote.serviceCall.toStringAsFixed(2);
      companyPartsCostController.text =
          quote.companyPartsCost.toStringAsFixed(2);
      taxRateController.text = quote.taxRate.toStringAsFixed(2);

      selectedService = quote.service;
      selectedPaymentMethod = quote.paymentMethod;
      markupPercentage = quote.markupPercentage;

      companyPartsCost = quote.companyPartsCost;
      markupAmount = quote.markupAmount;
      customerPartsPrice = quote.customerPartsPrice;
      serviceCall = quote.serviceCall;
      taxRate = quote.taxRate;
      subtotal = quote.subtotal;
      taxAmount = quote.taxAmount;
      customerTotal = quote.customerTotal;
      partsProfit = quote.partsProfit;
      totalProfit = quote.totalProfit;
    });

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Loaded ${quote.receiptNumber} into the calculator',
        ),
      ),
    );
  }

  List<SavedQuote> get filteredQuotes {
    final String query = searchController.text.trim().toLowerCase();

    if (query.isEmpty) {
      return savedQuotes;
    }

    return savedQuotes.where((SavedQuote quote) {
      return quote.receiptNumber.toLowerCase().contains(query) ||
          quote.customerName.toLowerCase().contains(query) ||
          quote.vehicleNotes.toLowerCase().contains(query) ||
          quote.service.toLowerCase().contains(query) ||
          quote.paymentMethod.toLowerCase().contains(query);
    }).toList();
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
  }) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildMoneyField({
    required String label,
    required TextEditingController controller,
    String? prefix,
    String? suffix,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(
        decimal: true,
      ),
      decoration: InputDecoration(
        labelText: label,
        prefixText: prefix,
        suffixText: suffix,
        border: const OutlineInputBorder(),
      ),
    );
  }

  Widget buildPriceRow(
      String label,
      double amount, {
        bool emphasize = false,
        bool profit = false,
      }) {
    final TextStyle style = TextStyle(
      fontSize: emphasize ? 24 : 17,
      fontWeight:
      emphasize ? FontWeight.bold : FontWeight.normal,
      color: profit ? Colors.greenAccent : null,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Text(label, style: style),
          ),
          const SizedBox(width: 12),
          Text(money(amount), style: style),
        ],
      ),
    );
  }

  Widget buildMarkupCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Markup Percentage: '
                  '${markupPercentage.toStringAsFixed(0)}%',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            Slider(
              value: markupPercentage,
              min: 0,
              max: 100,
              divisions: 100,
              label: '${markupPercentage.toStringAsFixed(0)}%',
              onChanged: (double value) {
                setState(() {
                  markupPercentage = value;
                });
              },
            ),
            const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('0%'),
                Text('100%'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildQuoteDetails(
      SavedQuote quote, {
        required bool showInternalNumbers,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('Receipt: ${quote.receiptNumber}'),
        Text('Date: ${formatDate(quote.createdAt)}'),
        Text(
          'Customer: '
              '${quote.customerName.isEmpty ? 'Not provided' : quote.customerName}',
        ),
        Text(
          'Vehicle / Notes: '
              '${quote.vehicleNotes.isEmpty ? 'Not provided' : quote.vehicleNotes}',
        ),
        Text('Service: ${quote.service}'),
        Text('Payment: ${quote.paymentMethod}'),
        const Divider(height: 28),
        if (showInternalNumbers) ...[
          buildPriceRow(
            'Company Parts Cost',
            quote.companyPartsCost,
          ),
          buildPriceRow(
            'Markup Amount '
                '(${quote.markupPercentage.toStringAsFixed(0)}%)',
            quote.markupAmount,
            profit: true,
          ),
        ],
        buildPriceRow(
          showInternalNumbers
              ? 'Customer Parts Price'
              : 'Parts Price',
          quote.customerPartsPrice,
        ),
        buildPriceRow('Service Call', quote.serviceCall),
        buildPriceRow('Subtotal', quote.subtotal),
        buildPriceRow('Sales Tax', quote.taxAmount),
        const Divider(height: 28),
        buildPriceRow(
          'Customer Total',
          quote.customerTotal,
          emphasize: true,
        ),
        if (showInternalNumbers) ...[
          const Divider(height: 28),
          buildPriceRow(
            'Parts Profit',
            quote.partsProfit,
            profit: true,
          ),
          buildPriceRow(
            'Total Profit Including Service',
            quote.totalProfit,
            profit: true,
          ),
        ],
      ],
    );
  }

  void showCustomerReceiptPreview({SavedQuote? savedQuote}) {
    calculatePrice();

    final SavedQuote quote = savedQuote ??
        _buildCurrentQuote(
          'Preview — ${formatReceiptNumber(nextReceiptCounter)}',
        );

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Customer Receipt Preview'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.car_repair, size: 55),
                  const Text(
                    'Jiffy Roadside Assistance Corporation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Text(
                    '313-952-5266',
                    textAlign: TextAlign.center,
                  ),
                  const Divider(height: 28),
                  buildQuoteDetails(
                    quote,
                    showInternalNumbers: false,
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Thank you for choosing Jiffy Roadside Assistance Corporation!',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showInternalReport({SavedQuote? savedQuote}) {
    calculatePrice();

    final SavedQuote quote = savedQuote ??
        _buildCurrentQuote(
          'Preview — ${formatReceiptNumber(nextReceiptCounter)}',
        );

    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Internal Pricing Report'),
          content: SizedBox(
            width: 520,
            child: SingleChildScrollView(
              child: buildQuoteDetails(
                quote,
                showInternalNumbers: true,
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showSavedQuotesPage() {
    showDialog<void>(
      context: context,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (
              BuildContext context,
              StateSetter setDialogState,
              ) {
            final List<SavedQuote> quotes = filteredQuotes;

            return AlertDialog(
              title: Text(
                'Saved Quotes (${savedQuotes.length})',
              ),
              content: SizedBox(
                width: 760,
                height: 620,
                child: Column(
                  children: [
                    TextField(
                      controller: searchController,
                      decoration: const InputDecoration(
                        labelText:
                        'Search name, receipt, vehicle, or service',
                        prefixIcon: Icon(Icons.search),
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (_) => setDialogState(() {}),
                    ),
                    const SizedBox(height: 12),
                    Expanded(
                      child: isLoadingSavedQuotes
                          ? const Center(
                        child: CircularProgressIndicator(),
                      )
                          : quotes.isEmpty
                          ? const Center(
                        child: Text(
                          'No matching saved quotes.',
                        ),
                      )
                          : ListView.builder(
                        itemCount: quotes.length,
                        itemBuilder: (
                            BuildContext context,
                            int index,
                            ) {
                          final SavedQuote quote =
                          quotes[index];

                          return Card(
                            child: ExpansionTile(
                              title: Text(
                                quote.customerName.isEmpty
                                    ? quote.receiptNumber
                                    : '${quote.customerName} — ${quote.receiptNumber}',
                              ),
                              subtitle: Text(
                                '${quote.service} • '
                                    '${formatDate(quote.createdAt)} • '
                                    '${money(quote.customerTotal)}',
                              ),
                              childrenPadding:
                              const EdgeInsets.fromLTRB(
                                16,
                                0,
                                16,
                                14,
                              ),
                              children: [
                                buildPriceRow(
                                  'Customer Total',
                                  quote.customerTotal,
                                  emphasize: true,
                                ),
                                buildPriceRow(
                                  'Total Profit',
                                  quote.totalProfit,
                                  profit: true,
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: [
                                    FilledButton.icon(
                                      onPressed: () =>
                                          loadQuote(quote),
                                      icon: const Icon(
                                        Icons.edit,
                                      ),
                                      label: const Text(
                                        'Load',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          showCustomerReceiptPreview(
                                            savedQuote: quote,
                                          ),
                                      icon: const Icon(
                                        Icons.receipt_long,
                                      ),
                                      label: const Text(
                                        'Receipt',
                                      ),
                                    ),
                                    OutlinedButton.icon(
                                      onPressed: () =>
                                          showInternalReport(
                                            savedQuote: quote,
                                          ),
                                      icon: const Icon(
                                        Icons.analytics,
                                      ),
                                      label: const Text(
                                        'Internal',
                                      ),
                                    ),
                                    TextButton.icon(
                                      onPressed: () async {
                                        await deleteQuote(quote);
                                        setDialogState(() {});
                                      },
                                      icon: const Icon(
                                        Icons.delete_outline,
                                      ),
                                      label: const Text(
                                        'Delete',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    searchController.clear();
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('Close'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    searchController.removeListener(_refreshSearch);
    customerNameController.dispose();
    vehicleController.dispose();
    serviceCallController.dispose();
    companyPartsCostController.dispose();
    taxRateController.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jiffy Master Calculator'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Saved Quotes',
            onPressed: showSavedQuotesPage,
            icon: const Icon(Icons.folder_open),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 760),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Icon(Icons.car_repair, size: 75),
                  const SizedBox(height: 10),
                  const Text(
                    'Jiffy Roadside Assistance Corporation',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  const Text(
                    '313-952-5266',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 17),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Next receipt: '
                        '${formatReceiptNumber(nextReceiptCounter)}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 25),
                  buildTextField(
                    label: 'Customer Name',
                    controller: customerNameController,
                  ),
                  const SizedBox(height: 15),
                  buildTextField(
                    label: 'Vehicle / Notes',
                    controller: vehicleController,
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: selectedService,
                    decoration: const InputDecoration(
                      labelText: 'Service Type',
                      border: OutlineInputBorder(),
                    ),
                    items: services.map((String service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedService = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  DropdownButtonFormField<String>(
                    initialValue: selectedPaymentMethod,
                    decoration: const InputDecoration(
                      labelText: 'Payment Method',
                      border: OutlineInputBorder(),
                    ),
                    items: paymentMethods.map((String method) {
                      return DropdownMenuItem<String>(
                        value: method,
                        child: Text(method),
                      );
                    }).toList(),
                    onChanged: (String? value) {
                      if (value != null) {
                        setState(() {
                          selectedPaymentMethod = value;
                        });
                      }
                    },
                  ),
                  const SizedBox(height: 15),
                  buildMoneyField(
                    label: 'Company Parts Cost',
                    controller: companyPartsCostController,
                    prefix: '\$ ',
                  ),
                  const SizedBox(height: 15),
                  buildMarkupCard(),
                  const SizedBox(height: 15),
                  buildMoneyField(
                    label: 'Service Call',
                    controller: serviceCallController,
                    prefix: '\$ ',
                  ),
                  const SizedBox(height: 15),
                  buildMoneyField(
                    label: 'Sales Tax Rate',
                    controller: taxRateController,
                    suffix: ' %',
                  ),
                  const SizedBox(height: 20),
                  FilledButton.icon(
                    onPressed: calculatePrice,
                    icon: const Icon(Icons.calculate),
                    label: const Padding(
                      padding:
                      EdgeInsets.symmetric(vertical: 14),
                      child: Text(
                        'Calculate Customer Total',
                        style: TextStyle(fontSize: 17),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: saveQuote,
                          icon: const Icon(Icons.save),
                          label: const Text('Save Quote'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: showSavedQuotesPage,
                          icon: const Icon(Icons.folder_open),
                          label: Text(
                            'Saved Quotes (${savedQuotes.length})',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: clearCalculator,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Clear Calculator'),
                  ),
                  const SizedBox(height: 25),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          Text(
                            selectedService,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Divider(height: 25),
                          buildPriceRow(
                            'Company Parts Cost',
                            companyPartsCost,
                          ),
                          buildPriceRow(
                            'Markup Amount '
                                '(${markupPercentage.toStringAsFixed(0)}%)',
                            markupAmount,
                            profit: true,
                          ),
                          buildPriceRow(
                            'Customer Parts Price',
                            customerPartsPrice,
                          ),
                          buildPriceRow(
                            'Service Call',
                            serviceCall,
                          ),
                          buildPriceRow(
                            'Subtotal Before Tax',
                            subtotal,
                          ),
                          buildPriceRow(
                            'Sales Tax',
                            taxAmount,
                          ),
                          const Divider(height: 25),
                          buildPriceRow(
                            'Customer Total',
                            customerTotal,
                            emphasize: true,
                          ),
                          const Divider(height: 25),
                          buildPriceRow(
                            'Parts Profit',
                            partsProfit,
                            profit: true,
                          ),
                          buildPriceRow(
                            'Total Profit Including Service',
                            totalProfit,
                            profit: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: FilledButton.icon(
                          onPressed: () =>
                              showCustomerReceiptPreview(),
                          icon: const Icon(Icons.receipt_long),
                          label: const Text('Customer Receipt'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => showInternalReport(),
                          icon: const Icon(Icons.analytics),
                          label: const Text('Internal Report'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Phase 2 saves quotes on this device. Customer receipts hide company cost, markup, and profit.',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}