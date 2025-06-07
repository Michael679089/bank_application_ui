import 'package:flutter/material.dart'; // Most Important package

void main() { // Driver Function
  WidgetsFlutterBinding.ensureInitialized(); // Ensures that the binding is initialized before running the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Banking App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color.fromARGB(255, 0, 0, 0)),
        useMaterial3: true,
      ),
      home: const PinSetupOrLoginPage(),
    );
  }
}

// ==== BANK LOGIC ====

String pincode = "";
int money = 0;
bool loggedIn = false;

List<List<dynamic>> billsToPay = [
  ["Electricity", 100],
  ["Water", 50],
  ["Internet", 75],
];

// ==== UI PAGES ====

class PinSetupOrLoginPage extends StatefulWidget {
  const PinSetupOrLoginPage({super.key});

  @override
  State<PinSetupOrLoginPage> createState() => _PinSetupOrLoginPageState();
}

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

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  double money = 0.00; 
  void _showAmountDialog(String title, Function(double) onSubmit) {
    final TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: amountController,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(hintText: "Enter amount"),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ElevatedButton(
            onPressed: () {
              final amt = double.tryParse(amountController.text);
              if (amt == null || amt <= 0) {
                _showError("Please enter a valid positive number.");
                return;
              }
              onSubmit(amt);
              Navigator.pop(context);
            },
            child: const Text("Submit"),
          ),
        ],
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  void _changePincode() {
    final TextEditingController currentPinController = TextEditingController();
    final TextEditingController newPinController = TextEditingController();
    final TextEditingController confirmNewPinController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Change Pincode"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: currentPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Current Pincode"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: newPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "New Pincode"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: confirmNewPinController,
                  obscureText: true,
                  decoration: const InputDecoration(labelText: "Confirm New Pincode"),
                  keyboardType: TextInputType.number,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
            ElevatedButton(
              onPressed: () {
                if (currentPinController.text != pincode) {
                  _showError("Incorrect current pincode.");
                  return;
                }
                if (newPinController.text.isEmpty || confirmNewPinController.text.isEmpty) {
                  _showError("New pincode cannot be empty.");
                  return;
                }
                if (newPinController.text != confirmNewPinController.text) {
                  _showError("New pincode does not match.");
                  return;
                }
                setState(() {
                  pincode = newPinController.text;
                });
                Navigator.pop(context);
                _showInfo("Pincode changed successfully.");
              },
              child: const Text("Change"),
            ),
          ],
        ),
      ),
    );
  }

  void _showPayBillsMenu() {
    showDialog(
      context: context,
      builder: (_) => StatefulBuilder(
        builder: (context, setStateDialog) => AlertDialog(
          title: const Text("Pay Bills"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              for (var i = 0; i < billsToPay.length; i++)
                ListTile(
                  title: Text("${billsToPay[i][0]} (Due: ${billsToPay[i][1]})"),
                  onTap: () {
                    Navigator.pop(context);
                    _showAmountDialog("Pay ${billsToPay[i][0]}", (amount) {
                      if (amount > money) {
                        _showError("Insufficient funds.");
                        return;
                      }
                      if (amount > billsToPay[i][1]) {
                        amount = billsToPay[i][1]; // cap at due amount
                      }
                      setState(() {
                        money -= amount;
                        billsToPay[i][1] -= amount;
                      });
                      _showInfo("Paid ${amount.toStringAsFixed(2)} for ${billsToPay[i][0]}. Remaining bill: ${billsToPay[i][1]}");
                    });
                  },
                ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ],
        ),
      ),
    );
  }

  void _showTransferDialog() {
    final TextEditingController amountController = TextEditingController();
    final TextEditingController recipientController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Transfer Money"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: recipientController,
                decoration: const InputDecoration(labelText: "Recipient"),
              ),
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: "Amount"),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Back")),
          ElevatedButton(
            onPressed: () {
              final amount = int.tryParse(amountController.text);
              if (amount == null || amount <= 0) {
                _showError("Please enter a valid positive amount.");
                return;
              }
              if (amount > money) {
                _showError("Insufficient funds.");
                return;
              }
              // For simplicity, we won't track recipient logic
              setState(() {
                money -= amount;
              });
              Navigator.pop(context);
              _showInfo("Transferred ${amount.toStringAsFixed(2)} successfully.");
            },
            child: const Text("Transfer"),
          ),
        ],
      ),
    );
  }

  void _showWithdrawDialog() {
    _showAmountDialog("Withdraw Cash", (amount) {
      if (amount > money) {
        _showError("Insufficient funds.");
        return;
      }
      setState(() {
        money -= amount;
      });
      _showInfo("Withdrawal successful. Remaining balance: ${money.toStringAsFixed(2)}");
    });
  }

  void _showDepositDialog() {
    _showAmountDialog("Deposit Money", (amount) {
      setState(() {
        money += amount;
      });
      _showInfo("Deposit successful. New balance: ${money.toStringAsFixed(2)}");
    });
  }

  void _logout() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Logout"),
        content: const Text("Are you sure you want to logout?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          ElevatedButton(
            onPressed: () {
              loggedIn = false;
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const PinSetupOrLoginPage()),
              );
            },
            child: const Text("Logout"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cardTextStyle = const TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
    final cardSubTextStyle = const TextStyle(fontSize: 20);
    final cardBalanceStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(179, 0, 0, 0));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Dashboard"),
        actions: [
          Padding(
             padding: const EdgeInsets.only(right: 20.0, top: 5.0),
          child:IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: _logout,
          ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          children: [
            Card(
              color: Colors.orange.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: () {
                  _showInfo("Your current balance is: ${money.toStringAsFixed(2)}");
                },
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Balance Inquiry", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("₱${money.toStringAsFixed(2)}", style: cardBalanceStyle,),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.red.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showWithdrawDialog,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Withdraw Money", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("Withdraw funds", style: cardSubTextStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.green.shade400,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showTransferDialog,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Transfer Money", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("Send money", style: cardSubTextStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.blue.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showDepositDialog,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Deposit Money", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("Add money to account", style: cardSubTextStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.purple.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _changePincode,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Change Pincode", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("Update security code", style: cardSubTextStyle),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Card(
              color: Colors.teal.shade300,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: InkWell(
                onTap: _showPayBillsMenu,
                borderRadius: BorderRadius.circular(12),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text("Pay Bills", style: cardTextStyle),
                        const SizedBox(height: 8),
                        Text("Electricity, Water, Internet", style: cardSubTextStyle),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}