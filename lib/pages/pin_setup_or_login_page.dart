import 'package:flutter/material.dart';
import '../../bank_logic.dart';
import 'dashboard_page.dart';

class PinSetupOrLoginPage extends StatefulWidget {
  const PinSetupOrLoginPage({super.key});
  @override
  State<PinSetupOrLoginPage> createState() => _PinSetupOrLoginPageState();
}

// ...move the rest of your _PinSetupOrLoginPageState code here...

class _PinSetupOrLoginPageState extends State<PinSetupOrLoginPage> {
  final TextEditingController _pinController = TextEditingController();
  final TextEditingController _pinConfirmController = TextEditingController();

  int attempts = 0;

  @override
  Widget build(BuildContext context) {
    if (pincode.isEmpty) {
      // Show PIN setup screen
      return Scaffold(
        appBar: AppBar(title: const Text("Create Your Pincode")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter new pincode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _pinConfirmController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Confirm pincode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_pinController.text.isEmpty || _pinConfirmController.text.isEmpty) {
                    _showErrorDialog(context, "Pincode cannot be empty.");
                    return;
                  }
                  if (_pinController.text != _pinConfirmController.text) {
                    _showErrorDialog(context, "Pincode does not match. Please try again.");
                    return;
                  }
                  setState(() {
                    pincode = _pinController.text;
                  });
                  _showSuccessDialog(context, "Pincode has been set successfully.");
                },
                child: const Text("Save Pincode"),
              ),
            ],
          ),
        ),
      );
    } else {
      // Show login screen
      return Scaffold(
        appBar: AppBar(title: const Text("Login with Pincode")),
        body: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _pinController,
                obscureText: true,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Enter your pincode',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (_pinController.text == pincode) {
                    setState(() {
                      loggedIn = true;
                      attempts = 0;
                    });
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (context) => const DashboardPage()),
                    );
                  } else {
                    attempts++;
                   if (attempts >= 3) {
                    _showErrorDialog(context, "Too many attempts. Exiting app.");
                    Future.delayed(const Duration(seconds: 2), () {
                       if (!mounted) return; // Ensure widget is still in the tree
                      // ignore: use_build_context_synchronously
                      Navigator.of(context).pop();
                    });
                  } else {
                    _showErrorDialog(context, "Incorrect pincode. Attempts left: ${3 - attempts}");
                  }
                  }
                },
                child: const Text("Login"),
              ),
            ],
          ),
        ),
      );
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Error"),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("OK")),
        ],
      ),
    );
  }

  void _showSuccessDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Success"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PinSetupOrLoginPage()),
              );
            },
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }
}
