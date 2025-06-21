import 'package:flutter/material.dart';

class ReviewsPage extends StatelessWidget {
  const ReviewsPage({super.key});

  // Sample reviews data
  final List<Map<String, dynamic>> reviews = const [
    {
      'id': 1,
      'customerName': 'Sarah Johnson',
      'rating': 5,
      'comment': 'Great service! Fixed my sink quickly and professionally.',
      'date': 'May 10, 2025',
      'service': 'Plumbing Repair',
    },
    {
      'id': 2,
      'customerName': 'Michael Brown',
      'rating': 4,
      'comment': 'Very professional and knowledgeable. Would recommend!',
      'date': 'May 8, 2025',
      'service': 'Sink Installation',
    },
    {
      'id': 3,
      'customerName': 'Emily Davis',
      'rating': 5,
      'comment': 'Excellent work! Arrived on time and fixed the issue quickly.',
      'date': 'May 5, 2025',
      'service': 'Pipe Leakage',
    },
    {
      'id': 4,
      'customerName': 'Robert Wilson',
      'rating': 3,
      'comment': 'Good service but arrived a bit late. Work quality was good though.',
      'date': 'May 3, 2025',
      'service': 'Drain Cleaning',
    },
    {
      'id': 5,
      'customerName': 'Jennifer Lee',
      'rating': 5,
      'comment': 'Amazing service! Very thorough and professional.',
      'date': 'April 29, 2025',
      'service': 'Toilet Repair',
    },
  ];

  @override
  Widget build(BuildContext context) {
    // ServEase green colors
    final Color primaryGreen = Theme.of(context).colorScheme.primary;
    const Color lighterGreen = Color(0xFFD7F0DB);

    // Calculate average rating
    double averageRating = 0;
    if (reviews.isNotEmpty) {
      int totalRating = 0;
      for (var review in reviews) {
        totalRating += review['rating'] as int;
      }
      averageRating = totalRating / reviews.length;
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Reviews',
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating summary card
                  Container(
                    padding: const EdgeInsets.all(16),
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
                    child: Row(
                      children: [
                        // Average rating
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: primaryGreen.withOpacity(0.1),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  averageRating.toStringAsFixed(1),
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: primaryGreen,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: List.generate(5, (index) {
                                    return Icon(
                                      index < averageRating.floor() ? Icons.star : Icons.star_border,
                                      color: Colors.amber,
                                      size: 12,
                                    );
                                  }),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Rating breakdown
                        Expanded(
                          child: Column(
                            children: [
                              _buildRatingBar(context, 5, _countRatingsByStars(5), reviews.length),
                              const SizedBox(height: 8),
                              _buildRatingBar(context, 4, _countRatingsByStars(4), reviews.length),
                              const SizedBox(height: 8),
                              _buildRatingBar(context, 3, _countRatingsByStars(3), reviews.length),
                              const SizedBox(height: 8),
                              _buildRatingBar(context, 2, _countRatingsByStars(2), reviews.length),
                              const SizedBox(height: 8),
                              _buildRatingBar(context, 1, _countRatingsByStars(1), reviews.length),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Reviews count
                  Text(
                    '${reviews.length} Reviews',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey.shade800,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Reviews list
                  ...reviews.map((review) => _buildReviewCard(context, review)),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  int _countRatingsByStars(int stars) {
    return reviews.where((review) => review['rating'] == stars).length;
  }

  Widget _buildRatingBar(BuildContext context, int stars, int count, int total) {
    final double percentage = total > 0 ? count / total : 0;

    return Row(
      children: [
        Text(
          '$stars',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 4),
        Icon(
          Icons.star,
          size: 12,
          color: Colors.amber,
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Stack(
            children: [
              // Background bar
              Container(
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              // Filled bar
              Container(
                height: 4,
                width: MediaQuery.of(context).size.width * 0.5 * percentage,
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        Text(
          count.toString(),
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildReviewCard(BuildContext context, Map<String, dynamic> review) {
    final Color primaryGreen = Theme.of(context).colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Customer info and rating
          Row(
            children: [
              CircleAvatar(
                radius: 20,
                backgroundColor: primaryGreen.withOpacity(0.2),
                child: Text(
                  review['customerName'].substring(0, 1),
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
                      review['customerName'],
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      review['date'],
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (index) {
                  return Icon(
                    index < review['rating'] ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                    size: 16,
                  );
                }),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Service name
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: primaryGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              review['service'],
              style: TextStyle(
                fontSize: 12,
                color: primaryGreen,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 12),

          // Review comment
          Text(
            review['comment'],
            style: TextStyle(
              color: Colors.grey.shade700,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}