import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/providers/auth_provider.dart';
import '../../../shared/services/api_service.dart';
import 'package:image_picker/image_picker.dart';

class CreateJobScreen extends StatefulWidget {
  const CreateJobScreen({super.key});

  @override
  State<CreateJobScreen> createState() => _CreateJobScreenState();
}

class _CreateJobScreenState extends State<CreateJobScreen> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();
  final _zipController = TextEditingController();
  late ApiService _apiService;
  // final ImagePicker _picker = ImagePicker();
  
  List<File> _photos = [];
  bool _isLoading = false;
  double? _price;
  DateTime? _scheduledDate;
  File? _image;
  bool _isUrgent = false;

  @override
  void initState() {
    super.initState();
    _apiService = Provider.of<ApiService>(context, listen: false);
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _scheduledDate) {
      setState(() {
        _scheduledDate = picked;
      });
    }
  }

  Future<void> _pickImage() async {
    if (_photos.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Maximum 5 photos allowed')),
      );
      return;
    }
    
    /*
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _photos.add(File(image.path));
      });
    }
    */
  }

  Future<void> _createJob() async {
    final user = Provider.of<AuthProvider>(context, listen: false).user;
    if (user == null) return;

    if (_zipController.text.length != 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a valid 5-digit zip code')),
      );
      return;
    }

    setState(() => _isLoading = true);
    
    try {
      // 1. Geocode Zip
      final coords = await _apiService.geocodeZip(_zipController.text);

      // 2. Create Job (Photos uploaded within)
      await _apiService.createJob(
        title: _titleController.text,
        description: _descriptionController.text,
        price: double.parse(_priceController.text),
        latitude: coords['latitude']!,
        longitude: coords['longitude']!,
        posterId: user.id,
        photos: _photos,
        zipCode: _zipController.text,
        isUrgent: _isUrgent,
      );
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Job created successfully!')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to create job: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Create Job')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _priceController,
                decoration: const InputDecoration(
                  labelText: 'Price per Day',
                  border: OutlineInputBorder(),
                  prefixText: '\$',
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _zipController,
                decoration: const InputDecoration(
                  labelText: 'Zip Code',
                  border: OutlineInputBorder(),
                  hintText: 'e.g. 94102',
                ),
                keyboardType: TextInputType.number,
                maxLength: 5,
              ),
              const SizedBox(height: 16),
              const SizedBox(height: 16),
              SwitchListTile(
                title: const Text('Flash Mode (Urgent)', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
                subtitle: const Text('Broadcast to nearby pros immediately. +20% surcharge.'),
                value: _isUrgent,
                onChanged: (val) => setState(() => _isUrgent = val),
                secondary: const Icon(Icons.flash_on, color: Colors.red),
              ),
              const SizedBox(height: 16),
              const Text('Photos (Max 5)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _photos.length + 1,
                  itemBuilder: (context, index) {
                    if (index == _photos.length) {
                      return GestureDetector(
                        onTap: _pickImage,
                        child: Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.add_a_photo),
                        ),
                      );
                    }
                    return Stack(
                      children: [
                        Container(
                          margin: const EdgeInsets.only(right: 8),
                          width: 100,
                          height: 100,
                          child: Image.file(_photos[index], fit: BoxFit.cover),
                        ),
                        Positioned(
                          right: 0,
                          top: 0,
                          child: IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () {
                              setState(() {
                                _photos.removeAt(index);
                              });
                            },
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createJob,
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : const Text('Create Job'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
