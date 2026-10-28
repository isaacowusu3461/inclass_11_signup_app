
import 'package:flutter/material.dart';
import 'success_screen.dart';

// Fixed local tips. No form information is used here.
class LocalSignupCoach {
  static const String category = 'password_help';

  static const Map<String, List<String>> tips = {
    'password_help': [
      'Use a password with at least 8 characters.',
      'Avoid using your name or birthday in a password.',
      'Use a unique password for each account.',
    ],
  };

  static String getTip({
    bool simulateError = false,
    bool simulateEmpty = false,
  }) {
    if (simulateError) {
      throw Exception('Simulated local error');
    }

    final List<String> availableTips =
        simulateEmpty ? [] : (tips[category] ?? []);

    if (availableTips.isEmpty) {
      throw StateError('No local tips available');
    }

    // Fixed selection makes the result repeatable.
    return availableTips.first;
  }
}

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  // Form validation key
  final _formKey = GlobalKey<FormState>();

  // Form controllers
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _dateController = TextEditingController();

  DateTime? _birthDate;

  bool _showPassword = false;
  bool _isLoading = false;
  bool _tipFailed = false;
  bool _submitting = false;

  String? _tipMessage;

  // Local test modes for the signup coach
  String _testMode = 'normal';

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(_updatePasswordFeedback);
  }

  void _updatePasswordFeedback() {
    setState(() {});
  }

  @override
  void dispose() {
    _passwordController.removeListener(_updatePasswordFeedback);
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _dateController.dispose();
    super.dispose();
  }

  // Password strength guidance
  String get _passwordFeedback {
    final password = _passwordController.text;

    if (password.isEmpty) {
      return 'No password entered yet.';
    }

    if (password.length < 8) {
      return 'Weak: Use at least 8 characters.';
    }

    return 'Good length: Consider using letters, numbers, '
        'and symbols.';
  }

  Color get _passwordFeedbackColor {
    final password = _passwordController.text;

    if (password.isEmpty) {
      return Colors.grey.shade700;
    }

    if (password.length < 8) {
      return Colors.red;
    }

    return Colors.green.shade700;
  }

  // Open the birth-date picker.
  Future<void> _pickBirthDate() async {
    final now = DateTime.now();
    final firstDate = DateTime(1920);

    final picked = await showDatePicker(
      context: context,
      initialDate: _birthDate ?? DateTime(2000),
      firstDate: firstDate,
      lastDate: now,
    );

    if (!mounted || picked == null) return;

    setState(() {
      _birthDate = picked;
      _dateController.text =
          '${picked.month}/${picked.day}/${picked.year}';
    });

    _formKey.currentState?.validate();
  }

  // Validate first, then simulate signup.
  Future<void> _submitForm() async {
    // This guard also prevents duplicate submissions.
    if (_submitting) return;

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final guestName = _nameController.text.trim();

    setState(() {
      _submitting = true;
    });

    await Future<void>.delayed(
      const Duration(seconds: 2),
    );

    // Do not navigate if this screen was removed.
    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => SuccessScreen(
          userName: guestName,
        ),
      ),
    );
  }

  // Simulate getting a local tip.
  Future<void> _getSignupTip() async {
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
      _tipFailed = false;
      _tipMessage = null;
    });

    // Simulated loading. No network request is made.
    await Future<void>.delayed(
      const Duration(milliseconds: 700),
    );

    if (!mounted) return;

    try {
      final tip = LocalSignupCoach.getTip(
        simulateError: _testMode == 'error',
        simulateEmpty: _testMode == 'empty',
      );

      setState(() {
        _tipMessage =
            tip.length > 240 ? tip.substring(0, 240) : tip;
        _isLoading = false;
      });
    } catch (_) {
      setState(() {
        _tipFailed = true;
        _isLoading = false;
        _tipMessage = _testMode == 'empty'
            ? 'No preset tips are available. Please retry.'
            : 'Could not load the local tip. Please retry.';
      });
    }
  }

  // Retry using normal local data.
  void _retryTip() {
    setState(() {
      _testMode = 'normal';
    });

    _getSignupTip();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Guest Registration'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Icon(
                  Icons.auto_awesome,
                  size: 42,
                  color: Colors.deepPurple,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Join the Guestbook',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'A few details before you enter.',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),

                // Name field
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Full Name',
                    prefixIcon: Icon(Icons.person),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Email field
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(
                    labelText: 'Email Address',
                    prefixIcon: Icon(Icons.email),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null ||
                        value.trim().isEmpty) {
                      return 'Please enter your email';
                    }

                    final email = value.trim();
                    final emailPattern =
                        RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');

                    if (!emailPattern.hasMatch(email)) {
                      return 'Please enter a valid email';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // Password field
                TextFormField(
                  controller: _passwordController,
                  obscureText: !_showPassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock),
                    border: const OutlineInputBorder(),
                    suffixIcon: IconButton(
                      tooltip: _showPassword
                          ? 'Hide password'
                          : 'Show password',
                      icon: Icon(
                        _showPassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _showPassword = !_showPassword;
                        });
                      },
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a password';
                    }

                    if (value.length < 8) {
                      return 'Password must be at least 8 characters';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 10),

                // Task B from Activity 10: Password Coach
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _passwordFeedbackColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _passwordFeedback,
                        style: TextStyle(
                          color: _passwordFeedbackColor,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'Password feedback is local guidance, '
                  'not a security guarantee.',
                  style: TextStyle(fontSize: 12),
                ),
                const SizedBox(height: 16),

                // Birth-date picker
                TextFormField(
                  controller: _dateController,
                  readOnly: true,
                  decoration: const InputDecoration(
                    labelText: 'Birth Date',
                    prefixIcon: Icon(Icons.cake_outlined),
                    suffixIcon: Icon(Icons.calendar_month),
                    border: OutlineInputBorder(),
                  ),
                  onTap: _pickBirthDate,
                  validator: (_) {
                    if (_birthDate == null) {
                      return 'Please select your birth date';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),

                // Signup button with loading state
                ElevatedButton(
                  onPressed: _submitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.deepPurple,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.all(16),
                  ),
                  child: _submitting
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Join the Mansion',
                          style: TextStyle(fontSize: 18),
                        ),
                ),
                const SizedBox(height: 32),

                // Task A from Activity 10: Local Signup Coach
                const Divider(),
                const SizedBox(height: 12),
                const Text(
                  'Local Signup Coach',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'These are preset demo tips stored in the app. '
                  'No live AI model or server is used.',
                ),
                const SizedBox(height: 16),

                // Test mode selector
                DropdownButtonFormField<String>(
                  initialValue: _testMode,
                  decoration: const InputDecoration(
                    labelText: 'Local Test Mode',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'normal',
                      child: Text('Normal tip'),
                    ),
                    DropdownMenuItem(
                      value: 'error',
                      child: Text('Simulate error'),
                    ),
                    DropdownMenuItem(
                      value: 'empty',
                      child: Text('Simulate empty tips'),
                    ),
                  ],
                  onChanged: _isLoading
                      ? null
                      : (value) {
                          if (value != null) {
                            setState(() {
                              _testMode = value;
                              _tipMessage = null;
                              _tipFailed = false;
                            });
                          }
                        },
                ),
                const SizedBox(height: 16),

                ElevatedButton.icon(
                  onPressed:
                      _isLoading ? null : _getSignupTip,
                  icon: const Icon(Icons.lightbulb_outline),
                  label: const Text('Get a signup tip'),
                ),
                const SizedBox(height: 16),

                if (_isLoading)
                  const Column(
                    children: [
                      CircularProgressIndicator(),
                      SizedBox(height: 8),
                      Text('Loading local demo tip...'),
                    ],
                  ),

                if (_tipMessage != null && !_isLoading)
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Text(
                            _tipFailed
                                ? 'Local Demo Error'
                                : 'Preset Demo Tip',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(_tipMessage!),
                          if (_tipFailed) ...[
                            const SizedBox(height: 12),
                            TextButton.icon(
                              onPressed: _retryTip,
                              icon: const Icon(Icons.refresh),
                              label: const Text('Retry'),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),
                const Text(
                  'Privacy: This coach uses only a fixed local '
                  'category. It does not read your name, '
                  'email, or password.',
                  style: TextStyle(fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
