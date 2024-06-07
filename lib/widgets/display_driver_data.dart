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

  void _acceptDriver(BuildContext context) async {
    if (onAccepted != null) {
      await databaseRef.child(driverData['id']).update({'blockStatus': 'no'});
      onAccepted!();
    }
    Navigator.of(context).pop();
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
              const SizedBox(height: 20),
              Row(
                children: [
                  const Text('Model:'),
                  Text(driverData['vehicleModel']),
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
          child: const Text('Reject'),
          onPressed: () {
            // Implement reject logic
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Accept'),
          onPressed: () => _acceptDriver(context),
        ),
      ]
          : null,
    );
  }
}
