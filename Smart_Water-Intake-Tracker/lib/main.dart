import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const WaterTrackerApp());
}

class WaterTrackerApp extends StatelessWidget {
  const WaterTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Water Tracker',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.blue.shade50,
      ),
      home: const WaterTrackerHome(),
    );
  }
}

class WaterTrackerHome extends StatefulWidget {
  const WaterTrackerHome({super.key});

  @override
  State<WaterTrackerHome> createState() => _WaterTrackerHomeState();
}

class _WaterTrackerHomeState extends State<WaterTrackerHome> {
  final TextEditingController _intakeController = TextEditingController();
  final TextEditingController _goalController = TextEditingController();
  final GlobalKey<FormState> _intakeFormKey = GlobalKey<FormState>();
  final GlobalKey<FormState> _goalFormKey = GlobalKey<FormState>();

  int _totalIntake = 0;
  int _entryCount = 0;
  int _dailyGoal = 2000;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalIntake = prefs.getInt('totalIntake') ?? 0;
      _entryCount = prefs.getInt('entryCount') ?? 0;
      _dailyGoal = prefs.getInt('dailyGoal') ?? 2000;
      _goalController.text = _dailyGoal.toString();
    });
  }

  Future<void> _saveData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('totalIntake', _totalIntake);
    await prefs.setInt('entryCount', _entryCount);
    await prefs.setInt('dailyGoal', _dailyGoal);
  }

  void _updateGoal() {
    if (_goalFormKey.currentState!.validate()) {
      setState(() {
        _dailyGoal = int.parse(_goalController.text);
      });
      _saveData();
      FocusScope.of(context).unfocus();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Daily hydration goal updated successfully!')),
      );
    }
  }

  void _addWaterIntake() {
    if (_intakeFormKey.currentState!.validate()) {
      int addedAmount = int.parse(_intakeController.text);
      setState(() {
        _totalIntake += addedAmount;
        _entryCount += 1;
      });
      _saveData();
      _intakeController.clear();
      FocusScope.of(context).unfocus();
    }
  }

  void _showResetConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Reset Water Intake?'),
          content: const Text(
              'Are you sure you want to reset your daily water records? Your goal configuration will remain safe.'),
          actions: [
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Reset', style: TextStyle(color: Colors.red)),
              onPressed: () {
                Navigator.of(context).pop();
                _resetData();
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _resetData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('totalIntake');
    await prefs.remove('entryCount');
    setState(() {
      _totalIntake = 0;
      _entryCount = 0;
    });
  }

  Widget _infoColumn(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 13)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int remainingWater = (_dailyGoal - _totalIntake).clamp(0, _dailyGoal);
    double completionPercentage = 0.0;
    if (_dailyGoal > 0) {
      completionPercentage =
          ((_totalIntake / _dailyGoal) * 100).clamp(0.0, 100.0);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Water Tracker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Reset Intake Records',
            onPressed: _showResetConfirmation,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    const Text(
                      'Today\'s Progress',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.blueAccent),
                    ),
                    const SizedBox(height: 15),
                    Text(
                      '$_totalIntake ml / $_dailyGoal ml',
                      style: const TextStyle(
                          fontSize: 26, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                      value: completionPercentage / 100,
                      minHeight: 12,
                      backgroundColor: Colors.grey.shade300,
                      color: Colors.blue,
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _infoColumn('Completion',
                            '${completionPercentage.toStringAsFixed(1)}%'),
                        _infoColumn('Remaining', '$remainingWater ml'),
                        _infoColumn('Entries Logged', '$_entryCount'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _goalFormKey,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _goalController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: 'Modify Target Goal (ml)',
                            prefixIcon: Icon(Icons.flag_outlined),
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Goal cannot be blank';
                            }
                            final int? val = int.tryParse(value);
                            if (val == null) {
                              return 'Must be a number';
                            }
                            if (val <= 0) {
                              return 'Must be positive';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: ElevatedButton(
                          onPressed: _updateGoal,
                          style: ElevatedButton.styleFrom(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 16)),
                          child: const Text('Update'),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Form(
              key: _intakeFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _intakeController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Enter Water Amount (ml)',
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10)),
                      prefixIcon: const Icon(Icons.local_drink),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter a water amount';
                      }
                      final int? parsedValue = int.tryParse(value);
                      if (parsedValue == null) {
                        return 'Please enter a valid number';
                      }
                      if (parsedValue <= 0) {
                        return 'Amount must be greater than zero';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    onPressed: _addWaterIntake,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Intake',
                        style: TextStyle(fontSize: 16)),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
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
