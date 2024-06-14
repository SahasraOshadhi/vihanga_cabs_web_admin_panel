import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class EditRates extends StatefulWidget {
  @override
  _EditRatesState createState() => _EditRatesState();
}

class _EditRatesState extends State<EditRates> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _costPerKmController = TextEditingController();
  final TextEditingController _waitingRatePerMinController = TextEditingController();

  double? _currentCostPerKm;
  double? _currentWaitingRatePerMin;

  @override
  void initState() {
    super.initState();
    _loadCurrentRates();
  }

  Future<void> _loadCurrentRates() async {
    DocumentSnapshot ratesSnapshot = await FirebaseFirestore.instance.collection('rates').doc('KtlKvXsKVOOLTuAZIJG5').get();
    if (ratesSnapshot.exists) {
      Map<String, dynamic> ratesData = ratesSnapshot.data() as Map<String, dynamic>;
      setState(() {
        _currentCostPerKm = ratesData['costPerKm'];
        _currentWaitingRatePerMin = ratesData['waitingRatePerMin'];
        _costPerKmController.text = _currentCostPerKm.toString();
        _waitingRatePerMinController.text = _currentWaitingRatePerMin.toString();
      });
    }
  }

  Future<void> _updateRates() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance.collection('rates').doc('KtlKvXsKVOOLTuAZIJG5').update({
          'costPerKm': double.parse(_costPerKmController.text),
          'waitingRatePerMin': double.parse(_waitingRatePerMinController.text),
        });
        setState(() {
          _currentCostPerKm = double.parse(_costPerKmController.text);
          _currentWaitingRatePerMin = double.parse(_waitingRatePerMinController.text);
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Rates updated successfully.')));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to update rates: $e')));
      }
    }
  }

  @override
  void dispose() {
    _costPerKmController.dispose();
    _waitingRatePerMinController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Edit Rates'),
        backgroundColor: Colors.amber,
      ),
      body: Center(
        child: Container(
          padding: EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3),
              ),
            ],
          ),
          width: MediaQuery.of(context).size.width * 0.3,
          height: MediaQuery.of(context).size.height * 0.5,
          child: Column(
            children: [
              // Current Rates Display
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.amberAccent.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Current Rates",
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "Cost per km: ${_currentCostPerKm?.toStringAsFixed(2) ?? 'Loading...'}",
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 5),
                    Text(
                      "Waiting Rate per Minute: ${_currentWaitingRatePerMin?.toStringAsFixed(2) ?? 'Loading...'}",
                      style: TextStyle(fontSize: 16),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              // Form to Update Rates
              Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: _costPerKmController,
                      decoration: InputDecoration(labelText: 'Cost Per Km'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter cost per km';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),
                    TextFormField(
                      controller: _waitingRatePerMinController,
                      decoration: InputDecoration(labelText: 'Waiting Rate Per Minute'),
                      keyboardType: TextInputType.number,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter waiting rate per minute';
                        }
                        if (double.tryParse(value) == null) {
                          return 'Please enter a valid number';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 50),
                    ElevatedButton(
                      onPressed: _updateRates,
                      child: Text('Update Rates'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
