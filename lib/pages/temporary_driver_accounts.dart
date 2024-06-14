import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/display_driver_data.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class TemporaryDriverAccounts extends StatefulWidget {
  const TemporaryDriverAccounts({super.key});

  @override
  State<TemporaryDriverAccounts> createState() =>
      _TemporaryDriverAccountsState();
}

class _TemporaryDriverAccountsState extends State<TemporaryDriverAccounts> {
  final DatabaseReference _databaseRef =
  FirebaseDatabase.instance.ref().child('drivers');

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
        if (value['blockStatus'] == 'yes') {
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

  void _showDriverDetails(
      BuildContext context, Map<String, dynamic> driverData) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return DisplayDriverData(
          driverData: driverData,
          databaseRef: _databaseRef,
          onAccepted: () {
            setState(() {
              _driversData = _fetchDriversData();
            });
          },
          showActions: true,
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Temporary Driver Accounts'),
        backgroundColor: Colors.amber,
      ),
      body: SafeArea(
        child: FutureBuilder<List<Map<String, dynamic>>>(
          future: _driversData,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error fetching driver data: ${snapshot.error}'));
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
                        child: Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15.0),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
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
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    ClipOval(
                                      child: Image.network(
                                        driver['selfPic'],
                                        width: 100,
                                        height: 100,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          return Icon(Icons.error,
                                              color: Colors.red);
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
                                          if (loadingProgress == null)
                                            return child;
                                          return Center(
                                            child: CircularProgressIndicator(
                                              value: loadingProgress
                                                  .expectedTotalBytes !=
                                                  null
                                                  ? loadingProgress
                                                  .cumulativeBytesLoaded /
                                                  loadingProgress
                                                      .expectedTotalBytes!
                                                  : null,
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'NIC: ${driver['nic']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Vehicle Model: ${driver['vehicleModel']}',
                                  style: const TextStyle(
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  'Vehicle Reg Number: ${driver['vehicleRegNum']}',
                                  style: const TextStyle(
                                    fontSize: 18,
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
