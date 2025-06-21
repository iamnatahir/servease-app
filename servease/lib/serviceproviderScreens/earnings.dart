import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class EarningsPage extends StatefulWidget {
  const EarningsPage({super.key});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String selectedPeriod = 'This Month';

  // Sample earnings data
  final Map<String, dynamic> earningsData = {
    'total': 1248.00,
    'paid': 985.00,
    'pending': 263.00,
    'transactions': [
      {
        'id': 'TRX123456',
        'date': '2025-05-10',
        'amount': 85.00,
        'customer': 'Sarah Johnson',
        'service': 'Plumbing Repair',
        'status': 'paid',
      },
      {
        'id': 'TRX123457',
        'date': '2025-05-08',
        'amount': 120.00,
        'customer': 'Michael Brown',
        'service': 'Sink Installation',
        'status': 'paid',
      },
      {
        'id': 'TRX123458',
        'date': '2025-05-05',
        'amount': 75.00,
        'customer': 'Emily Davis',
        'service': 'Pipe Leakage',
        'status': 'pending',
      },
      {
        'id': 'TRX123459',
        'date': '2025-05-03',
        'amount': 60.00,
        'customer': 'Robert Wilson',
        'service': 'Drain Cleaning',
        'status': 'paid',
      },
      {
        'id': 'TRX123460',
        'date': '2025-04-29',
        'amount': 95.00,
        'customer': 'Jennifer Lee',
        'service': 'Toilet Repair',
        'status': 'paid',
      },
      {
        'id': 'TRX123461',
        'date': '2025-04-25',
        'amount': 70.00,
        'customer': 'David Miller',
        'service': 'Faucet Installation',
        'status': 'pending',
      },
      {
        'id': 'TRX123462',
        'date': '2025-04-22',
        'amount': 110.00,
        'customer': 'Lisa Anderson',
        'service': 'Water Heater Repair',
        'status': 'paid',
      },
      {
        'id': 'TRX123463',
        'date': '2025-04-18',
        'amount': 150.00,
        'customer': 'James Taylor',
        'service': 'Bathroom Plumbing',
        'status': 'paid',
      },
      {
        'id': 'TRX123464',
        'date': '2025-04-15',
        'amount': 118.00,
        'customer': 'Patricia Martinez',
        'service': 'Kitchen Sink Installation',
        'status': 'pending',
      },
    ],
  };

  List<String> periods = ['This Week', 'This Month', 'Last Month', 'Last 3 Months'];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ServEase green colors
    final Color primaryGreen = Theme.of(context).colorScheme.primary;
    const Color lighterGreen = Color(0xFFD7F0DB);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Earnings',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: primaryGreen,
          unselectedLabelColor: Colors.grey,
          indicatorColor: primaryGreen,
          tabs: const [
            Tab(text: 'Transactions'),
            Tab(text: 'Payouts'),
          ],
        ),
      ),
      body: Stack(
        children: [
          // Background curved shapes
          Positioned(
            top: -100,
            right: -50,
            child: Container(
              width: 180,
              height: 200,
              decoration: const BoxDecoration(
                color: lighterGreen,
                shape: BoxShape.circle,
              ),
            ),
          ),

          // Bottom right corner shape
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              width: 150,
              height: 150,
              decoration: const BoxDecoration(
                color: lighterGreen,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(100),
                ),
              ),
            ),
          ),

          // Main content
          SafeArea(
            child: Column(
              children: [
                // Earnings summary
                Container(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Period selector
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButton<String>(
                          value: selectedPeriod,
                          icon: const Icon(Icons.keyboard_arrow_down),
                          iconSize: 24,
                          elevation: 16,
                          style: TextStyle(
                            color: Colors.grey.shade800,
                            fontSize: 14,
                          ),
                          underline: Container(
                            height: 0,
                          ),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPeriod = newValue!;
                            });
                          },
                          items: periods.map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Earnings cards
                      Row(
                        children: [
                          // Total earnings
                          Expanded(
                            child: _buildEarningsCard(
                              context,
                              'Total Earnings',
                              '\$${earningsData['total'].toStringAsFixed(2)}',
                              primaryGreen,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Paid earnings
                          Expanded(
                            child: _buildEarningsCard(
                              context,
                              'Paid',
                              '\$${earningsData['paid'].toStringAsFixed(2)}',
                              Colors.blue,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Pending earnings
                          Expanded(
                            child: _buildEarningsCard(
                              context,
                              'Pending',
                              '\$${earningsData['pending'].toStringAsFixed(2)}',
                              Colors.orange,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Tab content
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // Transactions tab
                      _buildTransactionsTab(context),

                      // Payouts tab
                      _buildPayoutsTab(context),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEarningsCard(BuildContext context, String label, String amount, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            amount,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionsTab(BuildContext context) {
    final Color primaryGreen = Theme.of(context).colorScheme.primary;
    final transactions = earningsData['transactions'] as List<Map<String, dynamic>>;

    return transactions.isEmpty
        ? Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No transactions yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    )
        : ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        final DateTime date = DateTime.parse(transaction['date']);
        final String formattedDate = DateFormat('MMM d, yyyy').format(date);

        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 3,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Transaction ID and date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      transaction['id'],
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    Text(
                      formattedDate,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 12),

                // Customer and service
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: primaryGreen.withOpacity(0.2),
                      child: Text(
                        transaction['customer'].substring(0, 1),
                        style: TextStyle(
                          color: primaryGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            transaction['customer'],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            transaction['service'],
                            style: TextStyle(
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '\$${transaction['amount'].toStringAsFixed(2)}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: transaction['status'] == 'paid'
                                ? Colors.blue
                                : Colors.orange,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: transaction['status'] == 'paid'
                                ? Colors.blue.withOpacity(0.1)
                                : Colors.orange.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            transaction['status'].substring(0, 1).toUpperCase() +
                                transaction['status'].substring(1),
                            style: TextStyle(
                              fontSize: 12,
                              color: transaction['status'] == 'paid'
                                  ? Colors.blue
                                  : Colors.orange,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPayoutsTab(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.account_balance_wallet,
            size: 80,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No payouts yet',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Your payouts will appear here',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              // Setup payout method
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(30),
              ),
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Setup Payout Method'),
          ),
        ],
      ),
    );
  }
}