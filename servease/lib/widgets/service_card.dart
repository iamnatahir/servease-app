import 'package:flutter/material.dart';

class ServiceCard extends StatelessWidget {
  final String title;
  final String provider;
  final double rating;
  final String price;
  final String imageUrl;
  final String? providerImageUrl;
  final String? serviceImageUrl;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.title,
    required this.provider,
    required this.rating,
    required this.price,
    required this.imageUrl,
    this.providerImageUrl,
    this.serviceImageUrl, // Make it optional
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Display provider image if available, otherwise show category icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: _buildProviderImage(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Provider: $provider',
                      style: TextStyle(
                        color: Colors.grey[700],
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(
                          Icons.star,
                          color: Colors.amber,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          rating.toString(),
                          style: TextStyle(
                            color: Colors.grey[700],
                            fontSize: 14,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          price,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build the provider image
  Widget _buildProviderImage() {
    // First check if service image URL is available
    if (serviceImageUrl != null && serviceImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          serviceImageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          // Handle loading and errors
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Fallback to provider image or category icon
            return _buildFallbackImage();
          },
        ),
      );
    } else {
      // Fallback to provider image or category icon
      return _buildFallbackImage();
    }
  }

// Helper method for fallback images
  Widget _buildFallbackImage() {
    // Check if provider image URL is available
    if (providerImageUrl != null && providerImageUrl!.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          providerImageUrl!,
          width: 60,
          height: 60,
          fit: BoxFit.cover,
          // Handle loading and errors
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                value: loadingProgress.expectedTotalBytes != null
                    ? loadingProgress.cumulativeBytesLoaded /
                    loadingProgress.expectedTotalBytes!
                    : null,
                strokeWidth: 2,
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            // Final fallback to category icon
            return Center(
              child: Image.asset(
                imageUrl,
                width: 40,
                height: 40,
              ),
            );
          },
        ),
      );
    } else {
      // Use category icon as final fallback
      return Center(
        child: Image.asset(
          imageUrl,
          width: 40,
          height: 40,
        ),
      );
    }
  }
}
