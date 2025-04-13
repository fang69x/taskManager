import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:taskmanager/service/api_service.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final ApiService _apiService = ApiService();
  List<dynamic> _tasks = [];
  bool _isLoading = true;
  Map<String, dynamic> _userProfile = {};
  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });
    final profileFuture = _apiService.getUserProfile();
    final tasksFuture = _apiService.getAllTasks();

    final profile = await profileFuture;
    final tasks = await tasksFuture;
    setState(() {
      _userProfile = profile.containsKey('user') ? profile['user'] : {};
      _tasks = tasks;
      _isLoading = false;
    });
  }

  Future<void> _logout() async {
    await _apiService.clearToken();
    Navigator.pushReplacementNamed(context, '/login');
  }

  void _createNewTask() {
    Navigator.pushNamed(context, '/createTask').then((_) => _loadData());
  }

  void _editTask(dynamic task) {
    Navigator.pushNamed(
      context,
      '/editTask',
      arguments: task,
    ).then((_) => _loadData());
  }

  Future<void> _deleteTask(String id) async {
    final result = await _apiService.deleteTask(id);
    if (result.containsKey('message') &&
        result['message'] == 'Task deleted successfully') {
      _loadData();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Task deleted successfully')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete task')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('My Tasks'),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            UserAccountsDrawerHeader(
              accountName: Text(_userProfile['name'] ?? 'User'),
              accountEmail: Text(_userProfile['email'] ?? ''),
              currentAccountPicture: CircleAvatar(
                backgroundImage: _userProfile['avatar'] != null &&
                        _userProfile['avatar'] is Map &&
                        _userProfile['avatar']['url'] != null
                    ? CachedNetworkImageProvider(_userProfile['avatar']['url'])
                    : null,
                child: (_userProfile['avatar'] == null ||
                        !(_userProfile['avatar'] is Map) ||
                        _userProfile['avatar']['url'] == null)
                    ? Text(
                        (_userProfile['name'] ?? 'U')[0].toUpperCase(),
                        style: TextStyle(fontSize: 24),
                      )
                    : null,
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.pop(context);
                Navigator.pushNamed(context, '/profile')
                    .then((_) => _loadData());
              },
            ),
            ListTile(
              leading: Icon(Icons.task),
              title: Text('Tasks'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            Divider(),
            ListTile(
              leading: Icon(Icons.logout),
              title: Text('Logout'),
              onTap: _logout,
            ),
          ],
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _tasks.isEmpty
              ? Center(child: Text('No tasks found. Create one!'))
              : ListView.builder(
                  itemCount: _tasks.length,
                  itemBuilder: (context, index) {
                    final task = _tasks[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        title: Text(task['title'] ?? 'Untitled Task'),
                        subtitle: Text(task['description'] ?? 'No description'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: Icon(Icons.edit),
                              onPressed: () => _editTask(task),
                            ),
                            IconButton(
                              icon: Icon(Icons.delete),
                              onPressed: () => _deleteTask(task['_id']),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewTask,
        child: Icon(Icons.add),
      ),
    );
  }
}
