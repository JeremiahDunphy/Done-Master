```
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shared/services/api_service.dart';
import '../../shared/models/models.dart';
import 'create_job_screen.dart';
import 'job_details_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geocoding/geocoding.dart';
import '../../notifications/screens/notifications_screen.dart';
import '../../profile/screens/profile_screen.dart';
import '../../chat/screens/chat_list_screen.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final ApiService _apiService = ApiService();
  List<Job> _allJobs = [];
  List<Job> _filteredJobs = [];
  List<int> _savedJobIds = [];
  final MapController _mapController = MapController();
  bool _isLoading = true;
  bool _isMapView = false;
  double _searchRadius = 50; // miles
  final TextEditingController _zipController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadJobs();
    _loadSavedJobs();
  }

  Future<void> _loadSavedJobs() async {
    final ids = await Provider.of<ApiService>(context, listen: false).getSavedJobIds();
    setState(() {
      _savedJobIds = ids;
    });
  }

  Future<void> _toggleSave(int jobId) async {
    await Provider.of<ApiService>(context, listen: false).toggleSaveJob(jobId);
    _loadSavedJobs();
  }

  Future<void> _loadJobs() async {
    try {
      final jobs = await _apiService.getJobs();
      setState(() {
        _allJobs = jobs;
        _filteredJobs = jobs;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to load jobs: $e')),
        );
      }
    }
  }

  Future<void> _searchJobs() async {
    if (_zipController.text.length != 5) {
      setState(() => _filteredJobs = _allJobs);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final coords = await _apiService.geocodeZip(_zipController.text);
      final searchLat = coords['latitude']!;
      final searchLon = coords['longitude']!;
      
      final Distance distance = const Distance();
      
      setState(() {
        _filteredJobs = _allJobs.where((job) {
          final jobDist = distance.as(
            LengthUnit.Mile,
            LatLng(searchLat, searchLon),
            LatLng(job.latitude, job.longitude),
          );
          return jobDist <= _searchDistance;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid zip code')),
        );
      }
    }
  }

  Future<void> _applyForJob(Job job) async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    try {
      await _apiService.applyForJob(job.id, user.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Application submitted!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to apply: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Done'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.pushNamed(context, '/create-job'),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ProfileScreen()),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.message),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ChatListScreen(apiService: _apiService),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _zipController,
                        decoration: const InputDecoration(
                          hintText: 'Zip Code',
                          border: InputBorder.none,
                        ),
                        keyboardType: TextInputType.number,
                        maxLength: 5,
                      ),
                    ),
                    DropdownButton<double>(
                      value: _searchDistance,
                      items: const [
                        DropdownMenuItem(value: 10.0, child: Text('10 mi')),
                        DropdownMenuItem(value: 25.0, child: Text('25 mi')),
                        DropdownMenuItem(value: 50.0, child: Text('50 mi')),
                        DropdownMenuItem(value: 100.0, child: Text('100 mi')),
                      ],
                      onChanged: (val) => setState(() => _searchDistance = val!),
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _searchJobs,
                    ),
                  ],
                ),
              ),
            ),
          ),
          
          // Content
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _showMap
                    ? FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(37.7749, -122.4194), // Default SF
                          initialZoom: 10.0,
                        ),
                        children: [
                          TileLayer(
                            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.mobile',
                          ),
                          MarkerLayer(
                            markers: _filteredJobs.map((job) => Marker(
                              point: LatLng(job.latitude, job.longitude),
                              width: 80,
                              height: 80,
                              child: GestureDetector(
                                onTap: () {
                                  showDialog(
                                    context: context,
                                    builder: (ctx) => AlertDialog(
                                      title: Text(job.title),
                                      content: Text('\$${job.price}/day\n${job.description}'),
                                      actions: [
                                        TextButton(
                                          onPressed: () => Navigator.pop(ctx),
                                          child: const Text('Close'),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                                child: const Icon(Icons.location_on, color: Colors.red, size: 40),
                              ),
                            )).toList(),
                          ),
                        ],
                      )
                    : RefreshIndicator(
                        onRefresh: _loadJobs,
                        child: ListView.builder(
                          itemCount: _filteredJobs.length,
                          itemBuilder: (context, index) {
                            final job = _filteredJobs[index];
                            return Card(
                              margin: const EdgeInsets.all(8.0),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => JobDetailsScreen(job: job),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    if (job.photos.isNotEmpty)
                                    SizedBox(
                                      height: 150,
                                      width: double.infinity,
                                      child: Image.network(
                                        'http://localhost:3000${job.photos[0]}',
                                        fit: BoxFit.cover,
                                        errorBuilder: (ctx, err, stack) => const Icon(Icons.error),
                                      ),
                                    ),
                                  ListTile(
                                    title: Text(job.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                                    subtitle: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(job.description, maxLines: 2, overflow: TextOverflow.ellipsis),
                                        const SizedBox(height: 8),
                                        Text('\$${job.price.toStringAsFixed(2)}/day', 
                                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                    trailing: user?.role == 'PROVIDER'
                                        ? ElevatedButton(
                                            onPressed: () => _applyForJob(job),
                                            child: const Text('Apply'),
                                          )
                                        : null,
                                  ),
                                ],
                              ),
                            ),
                          );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: user?.role == 'CLIENT' && !_showMap
          ? FloatingActionButton(
              onPressed: () {
                Navigator.pushNamed(context, '/create-job').then((_) => _loadJobs());
              },
              child: const Icon(Icons.add),
            )
          : null,
    );
  }
}
