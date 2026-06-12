import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  final AuthService authService;

  const AuthScreen({super.key, required this.authService});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  final _loginIdCtrl = TextEditingController();
  final _loginPassCtrl = TextEditingController();

  final _registerUserCtrl = TextEditingController();
  final _registerEmailCtrl = TextEditingController();
  final _registerPassCtrl = TextEditingController();

  bool _loading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginIdCtrl.dispose();
    _loginPassCtrl.dispose();
    _registerUserCtrl.dispose();
    _registerEmailCtrl.dispose();
    _registerPassCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 16),
              const Text(
                'Roommates Apartment',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Chat, notices and calendar in one place',
                style: TextStyle(color: Colors.grey[600]),
              ),
              const SizedBox(height: 20),
              TabBar(
                controller: _tabController,
                tabs: const [Tab(text: 'Login'), Tab(text: 'Register')],
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildLoginTab(),
                    _buildRegisterTab(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoginTab() {
    return Column(
      children: [
        TextField(
          controller: _loginIdCtrl,
          decoration: const InputDecoration(
            labelText: 'Username or email',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _loginPassCtrl,
          obscureText: true,
          decoration: const InputDecoration(
            labelText: 'Password',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        _submitButton(
          label: 'Login',
          onPressed: _loading ? null : _login,
        ),
      ],
    );
  }

  Widget _buildRegisterTab() {
    return SingleChildScrollView(
      child: Column(
        children: [
          TextField(
            controller: _registerUserCtrl,
            decoration: const InputDecoration(
              labelText: 'Username',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _registerEmailCtrl,
            decoration: const InputDecoration(
              labelText: 'Email',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _registerPassCtrl,
            obscureText: true,
            decoration: const InputDecoration(
              labelText: 'Password',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          _submitButton(
            label: 'Create account',
            onPressed: _loading ? null : _register,
          ),
        ],
      ),
    );
  }

  Widget _submitButton({required String label, VoidCallback? onPressed}) {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: onPressed,
        child: _loading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(label),
      ),
    );
  }

  Future<void> _login() async {
    setState(() => _loading = true);
    final error = await widget.authService.login(
      identifier: _loginIdCtrl.text,
      password: _loginPassCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }

  Future<void> _register() async {
    setState(() => _loading = true);
    final error = await widget.authService.register(
      username: _registerUserCtrl.text,
      email: _registerEmailCtrl.text,
      password: _registerPassCtrl.text,
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
    }
  }
}
