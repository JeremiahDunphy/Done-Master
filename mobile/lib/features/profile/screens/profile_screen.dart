import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/api_service.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  List<Review> _reviews = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadReviews();
  }

  Future<void> _loadReviews() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user != null) {
      final reviews = await Provider.of<ApiService>(context, listen: false).getUserReviews(user.id);
      setState(() {
        _reviews = reviews;
        _isLoading = false;
      });
    }
  }

  double get _averageRating {
    if (_reviews.isEmpty) return 0;
    final sum = _reviews.fold(0.0, (prev, Review r) => prev + r.rating);
    return sum / _reviews.length;
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) return const Scaffold(body: Center(child: Text('Not logged in')));

    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const CircleAvatar(radius: 50, child: Icon(Icons.person, size: 50)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(user.name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                if (user.isElite) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.amber,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.verified, size: 16, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Done Pro', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            Text(user.email, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 8),
            Chip(label: Text(user.role)),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(_averageRating.toStringAsFixed(1), style: const TextStyle(fontSize: 48, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RatingBarIndicator(
                      rating: _averageRating,
                      itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                      itemCount: 5,
                      itemSize: 20.0,
                    ),
                    Text('${_reviews.length} reviews', style: const TextStyle(color: Colors.grey)),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Align(alignment: Alignment.centerLeft, child: Text('Recent Reviews', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold))),
            const SizedBox(height: 10),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _reviews.isEmpty
                    ? const Text('No reviews yet')
                    : ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _reviews.length,
                        itemBuilder: (ctx, i) {
                          final r = _reviews[i];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            child: ListTile(
                              leading: const CircleAvatar(child: Icon(Icons.person)),
                              title: RatingBarIndicator(
                                rating: r.rating.toDouble(),
                                itemBuilder: (context, index) => const Icon(Icons.star, color: Colors.amber),
                                itemCount: 5,
                                itemSize: 15.0,
                              ),
                              subtitle: Text(r.comment),
                            ),
                          );
                        },
                      ),
          ],
        ),
      ),
    );
  }
}
