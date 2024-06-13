import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';

class AcceptedRequestsPage extends StatefulWidget {
  @override
  _AcceptedRequestsPageState createState() => _AcceptedRequestsPageState();
}

class _AcceptedRequestsPageState extends State<AcceptedRequestsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: const Text('Accepted Ride Requests'),
        backgroundColor: Colors.amber,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('ride_requests')
            .where('acceptedByDriver', isEqualTo: 'yes') // Only fetch assigned requests
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, index) {
              DocumentSnapshot rideRequest = snapshot.data!.docs[index];
              return AcceptedRideRequestCard(rideRequest: rideRequest);
            },
          );
        },
      ),
    );
  }
}

class AcceptedRideRequestCard extends StatefulWidget {
  final DocumentSnapshot rideRequest;

  const AcceptedRideRequestCard({Key? key, required this.rideRequest}) : super(key: key);

  @override
  _AcceptedRideRequestCardState createState() => _AcceptedRideRequestCardState();
}

class _AcceptedRideRequestCardState extends State<AcceptedRideRequestCard> {
  late Stream<DocumentSnapshot> _rideRequestStream;

  @override
  void initState() {
    super.initState();
    _rideRequestStream = FirebaseFirestore.instance
        .collection('ride_requests')
        .doc(widget.rideRequest.id)
        .snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: _rideRequestStream,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: CircularProgressIndicator(),
            ),
          );
        }

        var rideData = snapshot.data!.data() as Map<String, dynamic>?;

        if (rideData == null) {
          return Card(
            margin: EdgeInsets.all(10.0),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text("Invalid ride request data."),
            ),
          );
        }

        return FutureBuilder<Map<String, dynamic>>(
          future: _fetchCompanyData(rideData['companyUserId'] ?? ''),
          builder: (context, companySnapshot) {
            if (!companySnapshot.hasData) {
              return Center(child: CircularProgressIndicator());
            }
            var companyData = companySnapshot.data!;

            return FutureBuilder<Map<String, dynamic>>(
              future: _fetchUserData(rideData['userId'] ?? ''),
              builder: (context, userSnapshot) {
                if (!userSnapshot.hasData) {
                  return Center(child: CircularProgressIndicator());
                }
                var userData = userSnapshot.data!;

                return FutureBuilder<Map<String, dynamic>>(
                  future: _fetchDriverData(rideData['assignedDriver'] ?? ''),
                  builder: (context, driverSnapshot) {
                    if (!driverSnapshot.hasData) {
                      return Center(child: CircularProgressIndicator());
                    }
                    var driverData = driverSnapshot.data!;

                    String status = rideData['rideStarted'] == 'yes' ? 'Ongoing' : (rideData['status'] ?? 'N/A');
                    Color statusColor = rideData['rideStarted'] == 'yes' ? Colors.green : Colors.grey;

                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Company Name: ${companyData['companyName'] ?? 'N/A'}", style: TextStyle(fontWeight: FontWeight.bold)),
                            SizedBox(height: 5),
                            Text("Name of the Customer: ${userData['name'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Date: ${rideData['date'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Time: ${rideData['time'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Pickup Location: ${rideData['pickupLocation'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Destination: ${rideData['destination'] ?? 'N/A'}"),
                            if ((rideData['stop1'] ?? '').isNotEmpty) SizedBox(height: 5),
                            if ((rideData['stop1'] ?? '').isNotEmpty) Text("Stop 1: ${rideData['stop1']}"),
                            if ((rideData['stop2'] ?? '').isNotEmpty) SizedBox(height: 5),
                            if ((rideData['stop2'] ?? '').isNotEmpty) Text("Stop 2: ${rideData['stop2']}"),
                            SizedBox(height: 5),
                            Text("No of Passengers: ${rideData['passengers'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Created Date: ${rideData['createdAt'] != null ? (rideData['createdAt'] as Timestamp).toDate().toString() : 'N/A'}"),
                            SizedBox(height: 20),
                            Text("Driver Name: ${driverData['firstName'] ?? 'N/A'} ${driverData['lastName'] ?? 'N/A'}"),
                            SizedBox(height: 5),
                            Text("Driver Contact: ${driverData['telNum'] ?? 'N/A'}"),
                            SizedBox(height: 20),
                            Row(
                              children: [
                                Text("Status: "),
                                SizedBox(width: 20),
                                ElevatedButton(
                                  onPressed: () {
                                  },
                                  child: Text(status),
                                  style: ElevatedButton.styleFrom(
                                    primary: statusColor,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  Future<Map<String, dynamic>> _fetchCompanyData(String companyUserId) async {
    if (companyUserId.isEmpty) return {};
    DocumentSnapshot companySnapshot = await FirebaseFirestore.instance.collection('companies').doc(companyUserId).get();
    return companySnapshot.data() as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> _fetchUserData(String userId) async {
    if (userId.isEmpty) return {};
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance.collection('company_users').doc(userId).get();
    return userSnapshot.data() as Map<String, dynamic>? ?? {};
  }

  Future<Map<String, dynamic>> _fetchDriverData(String driverId) async {
    if (driverId.isEmpty) return {};
    DocumentSnapshot driverSnapshot = await FirebaseFirestore.instance.collection('drivers').doc(driverId).get();
    return driverSnapshot.data() as Map<String, dynamic>? ?? {};
  }
}
