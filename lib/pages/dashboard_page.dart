import 'package:flutter/material.dart';
import '../bank_logic.dart';
import 'pin_setup_or_login_page.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});
  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

// ...move the rest of your _DashboardPageState code here...

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
                        amount = billsToPay[i][1].toDouble(); // cap at due amount
                      }
                      setState(() {                     
                        money -= amount;
                        billsToPay[i][1] -= amount.toInt();
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

  void _logout(BuildContext context) {
    // Reset global state
    loggedIn = false;

    // Navigate back to the login/setup page and remove all previous routes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const PinSetupOrLoginPage()),
      (route) => false,
    );
  }

  

  @override
  Widget build(BuildContext context) {
    final cardTextStyle = const TextStyle(fontSize: 20, fontWeight: FontWeight.bold);
    final cardSubTextStyle = const TextStyle(fontSize: 10);
    final cardBalanceStyle = TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: const Color.fromARGB(179, 0, 0, 0));
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bank Dashboard"),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0, top: 5.0),
            child: IconButton(
              icon: const Icon(Icons.logout),
              tooltip: "Logout",
              onPressed: () => _logout(context),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Balance Inquiry Card (full width)
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
            const SizedBox(height: 16),
            // The rest of the cards in a 2-column grid
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
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
          ],
        ),
      ),
    );
  }
}