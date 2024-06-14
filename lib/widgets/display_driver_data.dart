import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

class DisplayDriverData extends StatelessWidget {
  final Map<String, dynamic> driverData;
  final DatabaseReference databaseRef;
  final VoidCallback? onAccepted;
  final bool showActions;

  const DisplayDriverData({
    Key? key,
    required this.driverData,
    required this.databaseRef,
    this.onAccepted,
    this.showActions = false,
  }) : super(key: key);

  Future<void> _promptCommissionRate(BuildContext context) async {
    final TextEditingController _commissionRateController = TextEditingController();
    final _formKey = GlobalKey<FormState>();

    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Enter Commission Rate'),
          content: Form(
            key: _formKey,
            child: TextFormField(
              controller: _commissionRateController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Commission rate (%)'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a commission rate';
                }
                final rate = int.tryParse(value);
                if (rate == null || rate < 1 || rate > 100) {
                  return 'Please enter a valid number between 1 and 100';
                }
                return null;
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Submit'),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  final rate = int.parse(_commissionRateController.text);
                  await _updateDriverData(rate);
                  Navigator.of(context).pop();
                  if (onAccepted != null) {
                    onAccepted!();
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateDriverData(int rate) async {
    final driverId = driverData['id'];
    final driverUpdateData = {
      'commissionRate': rate,
      'blockStatus': 'no',
    };

    // Update in Firebase Realtime Database
    await databaseRef.child(driverId).update(driverUpdateData);

    // Update in Firestore
    final firestore = FirebaseFirestore.instance;
    await firestore.collection('drivers').doc(driverId).update(driverUpdateData);
  }

  void _acceptDriver(BuildContext context) {
    _promptCommissionRate(context);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${driverData['firstName']} ${driverData['lastName']}'),
      content: SizedBox(
        width: double.maxFinite,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage: NetworkImage(driverData['selfPic']),
                    radius: 30,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    '${driverData['firstName']} ${driverData['lastName']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Address:'),
                  Text('${driverData['houseNumAddress']} ${driverData['cityAddress']}'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Province:'),
                  Text(driverData['provinceAddress']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Contact:'),
                  Text(driverData['telNum']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Email:'),
                  Text(driverData['email']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Date of Birth:'),
                  Text(driverData['dob']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('NIC:'),
                  Text(driverData['nic']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('NIC Pictures:'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['nicPicFront'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['nicPicBack'], fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('License Number:'),
                  Text(driverData['licenceNum']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('License Pictures:'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['licensePicFront'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['licensePicBack'], fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text(
                    'Vehicle Details',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Vehicle Pictures:'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['vehicleInsidePic'], fit: BoxFit.cover),
                  ),
                  const SizedBox(width: 10),
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['vehicleOutsidePic'], fit: BoxFit.cover),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Registration Number:'),
                  Text(driverData['vehicleRegNum']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Manufactured Year:'),
                  Text(driverData['manufacturedYear']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Last Service Date:'),
                  Text(driverData['lastServiceDate']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Mileage:'),
                  Text(driverData['mileage']),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  const Text('Emission Test:'),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Container(
                    width: 200,
                    height: 200,
                    child: Image.network(driverData['emissionTest'], fit: BoxFit.cover),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      actions: showActions
          ? <Widget>[
        TextButton(
          child: const Text('Accept'),
          onPressed: () {
            _acceptDriver(context);
          },
        ),
        TextButton(
          child: const Text('Reject'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ]
          : null,
    );
  }
}
