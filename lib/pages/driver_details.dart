// driver_details.dart

import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/display_driver_data.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class DriverDetails extends StatefulWidget {
  const DriverDetails({super.key});

  @override
  State<DriverDetails> createState() => _DriverDetailsState();
}

class _DriverDetailsState extends State<DriverDetails> {
  final DatabaseReference _databaseRef = FirebaseDatabase.instance.ref().child('drivers');

  late Future<List<Map<String, dynamic>>> _driversData;

  @override
  void initState() {
    super.initState();
    _driversData = _fetchDriversData();
  }

  Future<List<Map<String, dynamic>>> _fetchDriversData() async {
    DataSnapshot snapshot = await _databaseRef.get();
    if (snapshot.exists) {
      List<Map<String, dynamic>> driversList = [];
      Map<dynamic, dynamic> data = snapshot.value as Map;
      data.forEach((key, value) {
        if (value['blockStatus'] == 'no') {
          driversList.add({
            'id': key,
            'firstName': value['firstName'] ?? '',
            'lastName': value['lastName'] ?? '',
            'nic': value['nic'] ?? '',
            'vehicleModel': value['vehicleModel'] ?? '',
            'vehicleRegNum': value['vehicleRegNum'] ?? '',
            'selfPic': value['selfPic'] ?? '',
            'nicPicFront': value['nicPicFront'] ?? '',
            'nicPicBack': value['nicPicBack'] ?? '',
            'licensePicFront': value['licensePicFront'] ?? '',
            'licensePicBack': value['licensePicBack'] ?? '',
            'vehicleInsidePic': value['vehicleInsidePic'] ?? '',
            'vehicleOutsidePic': value['vehicleOutsidePic'] ?? '',
            'emissionTest': value['emissionTest'] ?? '',
            'houseNumAddress': value['houseNumAddress'] ?? '',
            'cityAddress': value['cityAddress'] ?? '',
            'provinceAddress': value['provinceAddress'] ?? '',
            'telNum': value['telNum'] ?? '',
            'email': value['email'] ?? '',
            'dob': value['dob'] ?? '',
            'licenceNum': value['licenceNum'] ?? '',
            'manufacturedYear': value['manufacturedYear'] ?? '',
            'lastServiceDate': value['lastServiceDate'] ?? '',
            'mileage': value['mileage'] ?? '',
            'blockStatus': value['blockStatus'] ?? '',
          });
        }
      });
      return driversList;
    } else {
      return [];
    }
  }

  void _showDriverDetails(BuildContext context, Map<String, dynamic> driverData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DisplayDriverData(
          driverData: driverData,
          databaseRef: _databaseRef,
          showActions: false, // Do not show Accept and Reject buttons here
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Driver Details'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _driversData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error fetching driver data: ${snapshot.error}'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No driver data available'));
            } else {
              final List<Map<String, dynamic>> driversData = snapshot.data!;

              return Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListView.builder(
                  itemCount: driversData.length,
                  itemBuilder: (context, index) {
                    final driver = driversData[index];
                    return GestureDetector(
                      onTap: () => _showDriverDetails(context, driver),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: FractionallySizedBox(
                          widthFactor: 0.90,
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.deepPurpleAccent,
                              borderRadius: const BorderRadius.all(Radius.circular(30)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      '${driver['firstName']} ${driver['lastName']}',
                                      style: const TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    CircleAvatar(
                                      backgroundImage: NetworkImage(driver['selfPic']),
                                      radius: 20,
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'NIC: ${driver['nic']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Vehicle Model: ${driver['vehicleModel']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Vehicle Reg Number: ${driver['vehicleRegNum']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            }
          },
        ),
      ),
    );
  }
}
