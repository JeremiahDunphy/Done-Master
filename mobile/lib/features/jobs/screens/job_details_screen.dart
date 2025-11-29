import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import '../../shared/models/models.dart';
import '../../shared/services/api_service.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import '../../chat/screens/chat_screen.dart';

class JobDetailsScreen extends StatelessWidget {
  final Job job;

  const JobDetailsScreen({super.key, required this.job});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;
    final ApiService apiService = ApiService();

    return Scaffold(
      appBar: AppBar(title: Text(job.title)),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Photos
            if (job.photos.isNotEmpty)
              SizedBox(
                height: 250,
                child: PageView.builder(
                  itemCount: job.photos.length,
                  itemBuilder: (context, index) {
                    return Image.network(
                      'http://localhost:3000${job.photos[index]}',
                      fit: BoxFit.cover,
                      errorBuilder: (ctx, err, stack) => const Center(child: Icon(Icons.error, size: 50)),
                    );
                  },
                ),
              ),
            
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          job.title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Text(
                        '\$${job.price.toStringAsFixed(2)}/day',
                        style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Description',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(job.description),
                  const SizedBox(height: 24),
                  
                  Text(
                    'Location',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 200,
                    child: FlutterMap(
                      options: MapOptions(
                        initialCenter: LatLng(job.latitude, job.longitude),
                        initialZoom: 13.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.example.mobile',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: LatLng(job.latitude, job.longitude),
                              width: 80,
                              height: 80,
                              child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  if (user?.role == 'PROVIDER' && job.status == 'OPEN')
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () async {
                          try {
                            await apiService.applyForJob(job.id, user!.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Application submitted!')),
                              );
                              Navigator.pop(context);
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Failed to apply: $e')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(16)),
                        child: const Text('Apply Now'),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            if (job.status == 'COMPLETED')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _handlePayment(context),
                child: const Text('Pay Now'),
              ),
            if (job.status == 'PAID')
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                onPressed: () => _showReviewModal(context),
                child: const Text('Leave Review'),
              ),
            
            // Messaging Buttons
            if (user != null && user.id != job.clientId && job.client != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            apiService: apiService,
                            otherUser: job.client!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message Client'),
                  ),
                ),
              ),

            if (user != null && user.id == job.clientId && job.providerId != null && job.provider != null)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ChatScreen(
                            apiService: apiService,
                            otherUser: job.provider!,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.message),
                    label: const Text('Message Provider'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  void _showReviewModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom,
          left: 16,
          right: 16,
          top: 16,
        ),
        child: ReviewForm(job: job),
      ),
    );
  }

  Future<void> _handlePayment(BuildContext context) async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      final data = await api.createPaymentIntent(job.id, job.price);
      
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: data['clientSecret'],
          merchantDisplayName: 'Done App',
        ),
      );

      await Stripe.instance.presentPaymentSheet();
      
      await api.updateJobStatus(job.id, 'PAID');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment Successful!')),
      );
      Navigator.pop(context); // Go back to refresh
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Payment failed: $e')),
      );
    }
  }
}

class ReviewForm extends StatefulWidget {
  final Job job;
  const ReviewForm({super.key, required this.job});

  @override
  State<ReviewForm> createState() => _ReviewFormState();
}

class _ReviewFormState extends State<ReviewForm> {
  double _rating = 5;
  final _commentController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('Leave a Review', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        const SizedBox(height: 20),
        RatingBar.builder(
          initialRating: 5,
          minRating: 1,
          direction: Axis.horizontal,
          allowHalfRating: true,
          itemCount: 5,
          itemBuilder: (context, _) => const Icon(Icons.star, color: Colors.amber),
          onRatingUpdate: (rating) => _rating = rating,
        ),
        const SizedBox(height: 20),
        TextField(
          controller: _commentController,
          decoration: const InputDecoration(labelText: 'Comment', border: OutlineInputBorder()),
          maxLines: 3,
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _submitReview,
          child: const Text('Submit Review'),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _submitReview() async {
    try {
      final api = Provider.of<ApiService>(context, listen: false);
      // Assuming providerId is available on job, or we review the other party
      // For simplicity, if I am client, I review provider.
      if (widget.job.providerId != null) {
        await api.createReview(widget.job.id, widget.job.providerId!, _rating.toInt(), _commentController.text);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Review Submitted!')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to submit review')));
    }
  }
}
