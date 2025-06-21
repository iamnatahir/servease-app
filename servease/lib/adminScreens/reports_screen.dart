import 'package:flutter/material.dart';
import 'package:servease/services/admin_api_service.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  bool isLoading = false;
  String selectedReportType = 'revenue';
  String selectedTimeframe = 'month';
  Map<String, dynamic> reportData = {};

  @override
  void initState() {
    super.initState();
    _generateReport();
  }

  Future<void> _generateReport() async {
    setState(() => isLoading = true);
    try {
      final response = await AdminApiService.generateReport(
        selectedReportType,
        selectedTimeframe,
      );
      if (response['success'] == true) {
        setState(() {
          reportData = response['data'] ?? {};
        });
      }
    } catch (e) {
      print('Error generating report: $e');
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports',style: TextStyle(color: Colors.white),),
        backgroundColor: const Color(0xFF0C7210),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildReportControls(),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : _buildReportContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildReportControls() {
    return Container(
      padding: const EdgeInsets.all(16),
      color: Colors.grey[50],
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Generate Reports',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedReportType,
                  decoration: const InputDecoration(
                    labelText: 'Report Type',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'revenue', child: Text('Revenue')),
                    DropdownMenuItem(value: 'bookings', child: Text('Bookings')),
                    DropdownMenuItem(value: 'users', child: Text('User Growth')),
                    DropdownMenuItem(value: 'services', child: Text('Services')),
                    DropdownMenuItem(value: 'ratings', child: Text('Ratings')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedReportType = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: DropdownButtonFormField<String>(
                  value: selectedTimeframe,
                  decoration: const InputDecoration(
                    labelText: 'Timeframe',
                    border: OutlineInputBorder(),
                    contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                  ),
                  items: [
                    DropdownMenuItem(value: 'week', child: Text('Last Week')),
                    DropdownMenuItem(value: 'month', child: Text('Last Month')),
                    DropdownMenuItem(value: 'quarter', child: Text('Last Quarter')),
                    DropdownMenuItem(value: 'year', child: Text('Last Year')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTimeframe = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _generateReport,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Generate Report'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0C7210),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportContent() {
    if (reportData.isEmpty) {
      return const Center(
        child: Text(
          'No report data available',
          style: TextStyle(fontSize: 16, color: Colors.grey),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildReportHeader(),
          const SizedBox(height: 20),
          _buildChartPlaceholder(),
          const SizedBox(height: 20),
          _buildReportSummary(),
          const SizedBox(height: 20),
          _buildReportDetails(),
          const SizedBox(height: 20),
          _buildExportOptions(),
        ],
      ),
    );
  }

  Widget _buildReportHeader() {
    String reportTitle = '';
    String reportDescription = '';

    switch (selectedReportType) {
      case 'revenue':
        reportTitle = 'Revenue Report';
        reportDescription = 'Financial performance analysis';
        break;
      case 'bookings':
        reportTitle = 'Bookings Report';
        reportDescription = 'Booking activity and trends';
        break;
      case 'users':
        reportTitle = 'User Growth Report';
        reportDescription = 'User acquisition and retention';
        break;
      case 'services':
        reportTitle = 'Services Report';
        reportDescription = 'Service performance and popularity';
        break;
      case 'ratings':
        reportTitle = 'Ratings Report';
        reportDescription = 'Customer satisfaction analysis';
        break;
    }

    String timeframeText = '';
    switch (selectedTimeframe) {
      case 'week':
        timeframeText = 'Last 7 days';
        break;
      case 'month':
        timeframeText = 'Last 30 days';
        break;
      case 'quarter':
        timeframeText = 'Last 3 months';
        break;
      case 'year':
        timeframeText = 'Last 12 months';
        break;
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reportTitle,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    reportDescription,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0xFF0C7210).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  timeframeText,
                  style: const TextStyle(
                    color: Color(0xFF0C7210),
                    fontWeight: FontWeight.w600,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.calendar_today, size: 14, color: Colors.grey[600]),
              const SizedBox(width: 4),
              Text(
                'Generated on: ${DateTime.now().toString().substring(0, 16)}',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildChartPlaceholder() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Data Visualization',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 200,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, size: 64, color: Colors.grey[400]),
                  const SizedBox(height: 8),
                  Text(
                    'Chart Placeholder',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Integrate with chart library for detailed analytics',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReportSummary() {
    final metrics = _getReportMetrics();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 1.5,
            ),
            itemCount: metrics.length,
            itemBuilder: (context, index) {
              final metric = metrics[index];
              return Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (metric['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      metric['title'] as String,
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      metric['value'] as String,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(
                          (metric['change'] as double) >= 0
                              ? Icons.arrow_upward
                              : Icons.arrow_downward,
                          size: 14,
                          color: (metric['change'] as double) >= 0
                              ? Colors.green
                              : Colors.red,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${(metric['change'] as double).abs()}% vs previous',
                          style: TextStyle(
                            color: (metric['change'] as double) >= 0
                                ? Colors.green
                                : Colors.red,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getReportMetrics() {
    switch (selectedReportType) {
      case 'revenue':
        return [
          {
            'title': 'Total Revenue',
            'value': '\$${reportData['totalRevenue'] ?? '0'}',
            'change': reportData['revenueChange'] ?? 0.0,
            'color': Colors.green,
          },
          {
            'title': 'Platform Fee',
            'value': '\$${reportData['platformFee'] ?? '0'}',
            'change': reportData['feeChange'] ?? 0.0,
            'color': Colors.purple,
          },
          {
            'title': 'Avg. Transaction',
            'value': '\$${reportData['avgTransaction'] ?? '0'}',
            'change': reportData['avgTransactionChange'] ?? 0.0,
            'color': Colors.blue,
          },
          {
            'title': 'Refunds',
            'value': '\$${reportData['refunds'] ?? '0'}',
            'change': reportData['refundsChange'] ?? 0.0,
            'color': Colors.red,
          },
        ];
      case 'bookings':
        return [
          {
            'title': 'Total Bookings',
            'value': reportData['totalBookings']?.toString() ?? '0',
            'change': reportData['bookingsChange'] ?? 0.0,
            'color': Colors.blue,
          },
          {
            'title': 'Completed',
            'value': reportData['completedBookings']?.toString() ?? '0',
            'change': reportData['completedChange'] ?? 0.0,
            'color': Colors.green,
          },
          {
            'title': 'Cancelled',
            'value': reportData['cancelledBookings']?.toString() ?? '0',
            'change': reportData['cancelledChange'] ?? 0.0,
            'color': Colors.red,
          },
          {
            'title': 'Avg. Response Time',
            'value': '${reportData['avgResponseTime'] ?? '0'} min',
            'change': reportData['responseTimeChange'] ?? 0.0,
            'color': Colors.orange,
          },
        ];
      case 'users':
        return [
          {
            'title': 'New Users',
            'value': reportData['newUsers']?.toString() ?? '0',
            'change': reportData['userGrowthRate'] ?? 0.0,
            'color': Colors.blue,
          },
          {
            'title': 'Active Users',
            'value': reportData['activeUsers']?.toString() ?? '0',
            'change': reportData['activeUsersChange'] ?? 0.0,
            'color': Colors.green,
          },
          {
            'title': 'New Providers',
            'value': reportData['newProviders']?.toString() ?? '0',
            'change': reportData['providerGrowthRate'] ?? 0.0,
            'color': Colors.purple,
          },
          {
            'title': 'Retention Rate',
            'value': '${reportData['retentionRate'] ?? '0'}%',
            'change': reportData['retentionChange'] ?? 0.0,
            'color': Colors.orange,
          },
        ];
      case 'services':
        return [
          {
            'title': 'Total Services',
            'value': reportData['totalServices']?.toString() ?? '0',
            'change': reportData['servicesChange'] ?? 0.0,
            'color': Colors.blue,
          },
          {
            'title': 'New Services',
            'value': reportData['newServices']?.toString() ?? '0',
            'change': reportData['newServicesChange'] ?? 0.0,
            'color': Colors.green,
          },
          {
            'title': 'Avg. Price',
            'value': '\$${reportData['avgPrice'] ?? '0'}',
            'change': reportData['priceChange'] ?? 0.0,
            'color': Colors.purple,
          },
          {
            'title': 'Popular Category',
            'value': reportData['popularCategory'] ?? 'N/A',
            'change': 0.0,
            'color': Colors.orange,
          },
        ];
      case 'ratings':
        return [
          {
            'title': 'Avg. Rating',
            'value': '${reportData['avgRating'] ?? '0'}/5',
            'change': reportData['ratingChange'] ?? 0.0,
            'color': Colors.amber,
          },
          {
            'title': 'Total Reviews',
            'value': reportData['totalReviews']?.toString() ?? '0',
            'change': reportData['reviewsChange'] ?? 0.0,
            'color': Colors.blue,
          },
          {
            'title': '5-Star Reviews',
            'value': '${reportData['fiveStarPercentage'] ?? '0'}%',
            'change': reportData['fiveStarChange'] ?? 0.0,
            'color': Colors.green,
          },
          {
            'title': 'Low Ratings',
            'value': reportData['lowRatings']?.toString() ?? '0',
            'change': reportData['lowRatingsChange'] ?? 0.0,
            'color': Colors.red,
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildReportDetails() {
    final details = _getReportDetails();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Detailed Analysis',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...details.map((detail) => _buildDetailItem(detail)).toList(),
        ],
      ),
    );
  }

  Widget _buildDetailItem(Map<String, dynamic> detail) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            detail['title'] as String,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            detail['description'] as String,
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 14,
              height: 1.5,
            ),
          ),
          if (detail['data'] != null) ...[
            const SizedBox(height: 12),
            _buildDetailData(detail['data'] as List<Map<String, dynamic>>),
          ],
        ],
      ),
    );
  }

  Widget _buildDetailData(List<Map<String, dynamic>> data) {
    return Column(
      children: data.map((item) {
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: Text(
                  item['name'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  item['value'] as String,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (item['change'] != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ((item['change'] as double) >= 0 ? Colors.green : Colors.red).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        (item['change'] as double) >= 0 ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 12,
                        color: (item['change'] as double) >= 0 ? Colors.green : Colors.red,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${(item['change'] as double).abs()}%',
                        style: TextStyle(
                          color: (item['change'] as double) >= 0 ? Colors.green : Colors.red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        );
      }).toList(),
    );
  }

  List<Map<String, dynamic>> _getReportDetails() {
    switch (selectedReportType) {
      case 'revenue':
        return [
          {
            'title': 'Revenue Breakdown',
            'description': 'Analysis of revenue sources and trends over the selected period.',
            'data': [
              {'name': 'Service Bookings', 'value': '\$${reportData['serviceRevenue'] ?? '0'}', 'change': 5.2},
              {'name': 'Platform Fees', 'value': '\$${reportData['platformFee'] ?? '0'}', 'change': 3.8},
              {'name': 'Premium Listings', 'value': '\$${reportData['premiumRevenue'] ?? '0'}', 'change': 12.5},
              {'name': 'Refunds', 'value': '-\$${reportData['refunds'] ?? '0'}', 'change': -2.1},
            ],
          },
          {
            'title': 'Top Performing Categories',
            'description': 'Categories generating the highest revenue in the platform.',
            'data': [
              {'name': 'Home Cleaning', 'value': '\$${reportData['topCategory1Revenue'] ?? '0'}', 'change': 8.3},
              {'name': 'Plumbing', 'value': '\$${reportData['topCategory2Revenue'] ?? '0'}', 'change': 5.7},
              {'name': 'Electrical', 'value': '\$${reportData['topCategory3Revenue'] ?? '0'}', 'change': 4.2},
              {'name': 'Gardening', 'value': '\$${reportData['topCategory4Revenue'] ?? '0'}', 'change': 3.1},
            ],
          },
        ];
      case 'bookings':
        return [
          {
            'title': 'Booking Status Distribution',
            'description': 'Overview of booking statuses across the platform.',
            'data': [
              {'name': 'Completed', 'value': '${reportData['completedPercentage'] ?? '0'}%', 'change': 3.2},
              {'name': 'In Progress', 'value': '${reportData['inProgressPercentage'] ?? '0'}%', 'change': 1.5},
              {'name': 'Cancelled', 'value': '${reportData['cancelledPercentage'] ?? '0'}%', 'change': -2.1},
              {'name': 'Pending', 'value': '${reportData['pendingPercentage'] ?? '0'}%', 'change': -0.8},
            ],
          },
          {
            'title': 'Peak Booking Times',
            'description': 'Analysis of when most bookings are made during the day.',
            'data': [
              {'name': 'Morning (6AM-12PM)', 'value': '${reportData['morningBookings'] ?? '0'}%', 'change': null},
              {'name': 'Afternoon (12PM-5PM)', 'value': '${reportData['afternoonBookings'] ?? '0'}%', 'change': null},
              {'name': 'Evening (5PM-10PM)', 'value': '${reportData['eveningBookings'] ?? '0'}%', 'change': null},
              {'name': 'Night (10PM-6AM)', 'value': '${reportData['nightBookings'] ?? '0'}%', 'change': null},
            ],
          },
        ];
      case 'users':
        return [
          {
            'title': 'User Acquisition Channels',
            'description': 'Sources of new user registrations during the period.',
            'data': [
              {'name': 'Direct', 'value': '${reportData['directUsers'] ?? '0'}%', 'change': null},
              {'name': 'Referrals', 'value': '${reportData['referralUsers'] ?? '0'}%', 'change': 5.3},
              {'name': 'Social Media', 'value': '${reportData['socialUsers'] ?? '0'}%', 'change': 8.7},
              {'name': 'Search', 'value': '${reportData['searchUsers'] ?? '0'}%', 'change': 2.1},
            ],
          },
          {
            'title': 'User Demographics',
            'description': 'Breakdown of user base by demographic information.',
            'data': [
              {'name': 'Age 18-24', 'value': '${reportData['age1824'] ?? '0'}%', 'change': null},
              {'name': 'Age 25-34', 'value': '${reportData['age2534'] ?? '0'}%', 'change': null},
              {'name': 'Age 35-44', 'value': '${reportData['age3544'] ?? '0'}%', 'change': null},
              {'name': 'Age 45+', 'value': '${reportData['age45plus'] ?? '0'}%', 'change': null},
            ],
          },
        ];
      case 'services':
        return [
          {
            'title': 'Most Popular Services',
            'description': 'Services with the highest booking rates on the platform.',
            'data': [
              {'name': reportData['topService1'] ?? 'N/A', 'value': '${reportData['topService1Bookings'] ?? '0'} bookings', 'change': null},
              {'name': reportData['topService2'] ?? 'N/A', 'value': '${reportData['topService2Bookings'] ?? '0'} bookings', 'change': null},
              {'name': reportData['topService3'] ?? 'N/A', 'value': '${reportData['topService3Bookings'] ?? '0'} bookings', 'change': null},
              {'name': reportData['topService4'] ?? 'N/A', 'value': '${reportData['topService4Bookings'] ?? '0'} bookings', 'change': null},
            ],
          },
          {
            'title': 'Service Price Analysis',
            'description': 'Price distribution across service categories.',
            'data': [
              {'name': 'Budget (<\$50)', 'value': '${reportData['budgetServices'] ?? '0'}%', 'change': null},
              {'name': 'Mid-range (\$50-\$100)', 'value': '${reportData['midRangeServices'] ?? '0'}%', 'change': null},
              {'name': 'Premium (\$100-\$200)', 'value': '${reportData['premiumServices'] ?? '0'}%', 'change': null},
              {'name': 'Luxury (>\$200)', 'value': '${reportData['luxuryServices'] ?? '0'}%', 'change': null},
            ],
          },
        ];
      case 'ratings':
        return [
          {
            'title': 'Rating Distribution',
            'description': 'Breakdown of ratings received across all services.',
            'data': [
              {'name': '5 Stars', 'value': '${reportData['fiveStarPercentage'] ?? '0'}%', 'change': 2.3},
              {'name': '4 Stars', 'value': '${reportData['fourStarPercentage'] ?? '0'}%', 'change': 1.1},
              {'name': '3 Stars', 'value': '${reportData['threeStarPercentage'] ?? '0'}%', 'change': -0.5},
              {'name': '1-2 Stars', 'value': '${reportData['lowStarPercentage'] ?? '0'}%', 'change': -2.9},
            ],
          },
          {
            'title': 'Top Rated Providers',
            'description': 'Service providers with the highest customer satisfaction.',
            'data': [
              {'name': reportData['topProvider1'] ?? 'N/A', 'value': '${reportData['topProvider1Rating'] ?? '0'}/5', 'change': null},
              {'name': reportData['topProvider2'] ?? 'N/A', 'value': '${reportData['topProvider2Rating'] ?? '0'}/5', 'change': null},
              {'name': reportData['topProvider3'] ?? 'N/A', 'value': '${reportData['topProvider3Rating'] ?? '0'}/5', 'change': null},
              {'name': reportData['topProvider4'] ?? 'N/A', 'value': '${reportData['topProvider4Rating'] ?? '0'}/5', 'change': null},
            ],
          },
        ];
      default:
        return [];
    }
  }

  Widget _buildExportOptions() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Export Report',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportReport('pdf'),
                  icon: const Icon(Icons.picture_as_pdf, size: 16),
                  label: const Text('Export as PDF'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.red,
                    side: const BorderSide(color: Colors.red),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () => _exportReport('excel'),
                  icon: const Icon(Icons.table_chart, size: 16),
                  label: const Text('Export as Excel'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.green,
                    side: const BorderSide(color: Colors.green),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: () => _shareReport(),
            icon: const Icon(Icons.share, size: 16),
            label: const Text('Share Report'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.blue,
              side: const BorderSide(color: Colors.blue),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  void _exportReport(String format) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exporting report as ${format.toUpperCase()}...'),
        backgroundColor: Colors.blue,
      ),
    );

    // In a real app, this would call an API to generate and download the report
  }

  void _shareReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sharing report...'),
        backgroundColor: Colors.blue,
      ),
    );

    // In a real app, this would open a share dialog
  }
}
