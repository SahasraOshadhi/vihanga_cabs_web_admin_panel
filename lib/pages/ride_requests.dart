import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class RideRequestPage extends StatefulWidget {
  @override
  _RideRequestPageState createState() => _RideRequestPageState();
}

class _RideRequestPageState extends State<RideRequestPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Ride Requests'),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_requests')
            .where('assigned', isEqualTo: 'no') // Only fetch unassigned requests
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot rideRequest = snapshot.data!.docs[index];
              return RideRequestCard(rideRequest: rideRequest);
            },
          );
        },
      ),
    );
  }
}

class RideRequestCard extends StatefulWidget {
  final DocumentSnapshot rideRequest;

  const RideRequestCard({Key? key, required this.rideRequest}) : super(key: key);

  @override
  _RideRequestCardState createState() => _RideRequestCardState();
}

class _RideRequestCardState extends State<RideRequestCard> {
  String? selectedDriver;
  List<DropdownMenuItem<String>> driverItems = [];

  @override
  void initState() {
    super.initState();
    _fetchDrivers();
  }

  Future<void> _fetchDrivers() async {
    QuerySnapshot snapshot = await FirebaseFirestore.instance.collection('drivers').get();
    setState(() {
      driverItems = snapshot.docs.map((doc) {
        var data = doc.data() as Map<String, dynamic>;
        String driverName = "${data['firstName']} ${data['lastName']}";
        return DropdownMenuItem<String>(
          value: doc.id, // Store driver ID as value
          child: Text(driverName),
        );
      }).toList();
    });
  }

  Future<Map<String, dynamic>> _fetchCompanyData(String companyUserId) async {
    DocumentSnapshot companySnapshot = await FirebaseFirestore.instance.collection('companies').doc(companyUserId).get();
    return companySnapshot.data() as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('company_users').doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>;
  }

  @override
  Widget build(BuildContext context) {
    var data = widget.rideRequest.data() as Map<String, dynamic>;

    return FutureBuilder<Map<String, dynamic>>(
      future: _fetchCompanyData(data['companyUserId']),
      builder: (context, companySnapshot) {
        if (!companySnapshot.hasData) {
          return Center(child: CircularProgressIndicator());
        }
        var companyData = companySnapshot.data!;

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchUserData(data['userId']),
          builder: (context, userSnapshot) {
            if (!userSnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var userData = userSnapshot.data!;

            return Card(
              margin: EdgeInsets.all(10.0),
              child: Padding(
                padding: const EdgeInsets.all(15.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Company Name: ${companyData['companyName']}", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 5),
                    Text("Name of the Customer: ${userData['name']}"),
                    SizedBox(height: 5),
                    Text("Date: ${data['date']}"),
                    SizedBox(height: 5),
                    Text("Time: ${data['time']}"),
                    SizedBox(height: 5),
                    Text("Pickup Location: ${data['pickupLocation']}"),
                    SizedBox(height: 5),
                    Text("Destination: ${data['destination']}"),
                    if (data['stop1'].isNotEmpty) SizedBox(height: 5),
                    if (data['stop1'].isNotEmpty) Text("Stop 1: ${data['stop1']}"),
                    if (data['stop2'].isNotEmpty) SizedBox(height: 5),
                    if (data['stop2'].isNotEmpty) Text("Stop 2: ${data['stop2']}"),
                    SizedBox(height: 5),
                    Text("No of Passengers: ${data['passengers']}"),
                    SizedBox(height: 5),
                    Text("Created Date: ${data['createdAt'].toDate()}"),
                    SizedBox(height: 20),

                    Row(
                      children: [
                        Text("Driver: "),
                        SizedBox(width: 20),
                        DropdownButton<String>(
                          value: selectedDriver,
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedDriver = newValue;
                            });
                          },
                          items: driverItems,
                          hint: Text("Select Driver"),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () {
                        if (selectedDriver != null) {
                          _assignDriver(widget.rideRequest.id, selectedDriver!);
                        }
                      },
                      child: Text("Assign Driver"),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _assignDriver(String rideRequestId, String driverId) {
    FirebaseFirestore.instance.collection('ride_requests').doc(rideRequestId).update({
      'assignedDriver': driverId,
      'assigned': 'yes' // Update the assigned field to yes
    }).then((_) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Driver assigned successfully')));
    }).catchError((error) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Failed to assign driver: $error')));
    });
  }
}
