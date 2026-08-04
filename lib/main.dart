import 'package:flutter/material.dart';

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

class MasterCalculatorPage extends StatefulWidget {
  const MasterCalculatorPage({super.key});

  @override
  State<MasterCalculatorPage> createState() =>
      _MasterCalculatorPageState();
}

class _MasterCalculatorPageState
    extends State<MasterCalculatorPage> {
  final TextEditingController customerNameController =
  TextEditingController();

  final TextEditingController vehicleController =
  TextEditingController();

  final TextEditingController serviceCallController =
  TextEditingController(text: '125.00');

  final TextEditingController companyPartsCostController =
  TextEditingController();

  final TextEditingController taxRateController =
  TextEditingController(text: '10.00');

  String selectedService = 'Tire Replacement';

  double markupPercentage = 80;

  double companyPartsCost = 0;
  double markupAmount = 0;
  double customerPartsPrice = 0;
  double serviceCall = 0;
  double subtotal = 0;
  double taxAmount = 0;
  double customerTotal = 0;
  double partsProfit = 0;
  double totalProfit = 0;

  final List<String> services = [
    'Tire Replacement',
    'Tire Change',
    'Jump Start',
    'Battery Replacement',
    'Vehicle Lockout',
    'Fuel Delivery',
    'Other Roadside Service',
  ];

  double parseNumber(TextEditingController controller) {
    return double.tryParse(controller.text.trim()) ?? 0;
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
      markupPercentage = 80;

      companyPartsCost = 0;
      markupAmount = 0;
      customerPartsPrice = 0;
      serviceCall = 0;
      subtotal = 0;
      taxAmount = 0;
      customerTotal = 0;
      partsProfit = 0;
      totalProfit = 0;
    });
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
            child: Text(
              label,
              style: style,
            ),
          ),
          const SizedBox(width: 12),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: style,
          ),
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
              label:
              '${markupPercentage.toStringAsFixed(0)}%',
              onChanged: (value) {
                setState(() {
                  markupPercentage = value;
                });
              },
            ),
            const Row(
              mainAxisAlignment:
              MainAxisAlignment.spaceBetween,
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

  void showCustomerReceiptPreview() {
    calculatePrice();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Customer Receipt Preview'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
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
                  Text(
                    'Customer: '
                        '${customerNameController.text.isEmpty ? 'Not provided' : customerNameController.text}',
                  ),
                  Text(
                    'Vehicle: '
                        '${vehicleController.text.isEmpty ? 'Not provided' : vehicleController.text}',
                  ),
                  Text('Service: $selectedService'),
                  const Divider(height: 28),

                  // Customer receipt does not show
                  // company cost, markup, or profit.
                  buildPriceRow(
                    'Parts Price',
                    customerPartsPrice,
                  ),
                  buildPriceRow(
                    'Service Call',
                    serviceCall,
                  ),
                  buildPriceRow(
                    'Subtotal',
                    subtotal,
                  ),
                  buildPriceRow(
                    'Sales Tax',
                    taxAmount,
                  ),

                  const Divider(height: 28),

                  buildPriceRow(
                    'Customer Total',
                    customerTotal,
                    emphasize: true,
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
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  void showInternalReport() {
    calculatePrice();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Internal Pricing Report'),
          content: SizedBox(
            width: 500,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Customer: '
                        '${customerNameController.text.isEmpty ? 'Not provided' : customerNameController.text}',
                  ),
                  Text(
                    'Vehicle: '
                        '${vehicleController.text.isEmpty ? 'Not provided' : vehicleController.text}',
                  ),
                  Text('Service: $selectedService'),

                  const Divider(height: 28),

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
                    'Subtotal',
                    subtotal,
                  ),
                  buildPriceRow(
                    'Sales Tax',
                    taxAmount,
                  ),

                  const Divider(height: 28),

                  buildPriceRow(
                    'Customer Total',
                    customerTotal,
                    emphasize: true,
                  ),

                  const Divider(height: 28),

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
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    customerNameController.dispose();
    vehicleController.dispose();
    serviceCallController.dispose();
    companyPartsCostController.dispose();
    taxRateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jiffy Master Calculator'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(
                maxWidth: 760,
              ),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.stretch,
                children: [
                  const Icon(
                    Icons.car_repair,
                    size: 75,
                  ),

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
                    style: TextStyle(
                      fontSize: 17,
                    ),
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
                    items: services.map((service) {
                      return DropdownMenuItem<String>(
                        value: service,
                        child: Text(service),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          selectedService = value;
                        });
                      }
                    },
                  ),

                  const SizedBox(height: 15),

                  buildMoneyField(
                    label: 'Company Parts Cost',
                    controller:
                    companyPartsCostController,
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

                  OutlinedButton.icon(
                    onPressed: clearCalculator,
                    icon: const Icon(Icons.refresh),
                    label:
                    const Text('Clear Calculator'),
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
                          onPressed:
                          showCustomerReceiptPreview,
                          icon:
                          const Icon(Icons.receipt_long),
                          label: const Text(
                            'Customer Receipt',
                          ),
                        ),
                      ),

                      const SizedBox(width: 10),

                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: showInternalReport,
                          icon:
                          const Icon(Icons.analytics),
                          label: const Text(
                            'Internal Report',
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  const Text(
                    'Back-office pricing tool. Customer receipts hide company cost, markup, and profit.',
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
