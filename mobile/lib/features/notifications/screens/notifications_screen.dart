import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../shared/models/models.dart';
import '../../../shared/services/api_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    try {
      final notifications = await Provider.of<ApiService>(context, listen: false).getNotifications();
      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAsRead(int id) async {
    await Provider.of<ApiService>(context, listen: false).markNotificationRead(id);
    _loadNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? const Center(child: Text('No notifications'))
              : ListView.builder(
                  itemCount: _notifications.length,
                  itemBuilder: (ctx, i) {
                    final n = _notifications[i];
                    return ListTile(
                      title: Text(n.message),
                      subtitle: Text(n.createdAt.toLocal().toString().split('.')[0]),
                      trailing: n.read ? null : const Icon(Icons.circle, color: Colors.red, size: 10),
                      onTap: () => _markAsRead(n.id),
                    );
                  },
                ),
    );
  }
}
