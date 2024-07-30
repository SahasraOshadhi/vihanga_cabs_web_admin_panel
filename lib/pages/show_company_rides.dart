// show_company_rides.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ShowCompanyRides extends StatefulWidget {
  final String companyId;

  const ShowCompanyRides({Key? key, required this.companyId}) : super(key: key);

  @override
  _ShowCompanyRidesState createState() => _ShowCompanyRidesState();
}

class _ShowCompanyRidesState extends State<ShowCompanyRides> {
  late Future<List<RideDetail>> _rideDetailsFuture;
  double _totalFare = 0.0;

  @override
  void initState() {
    super.initState();
    _rideDetailsFuture = _fetchRideDetails();
  }

  Future<List<RideDetail>> _fetchRideDetails() async {
    List<RideDetail> rideDetails = [];
    double totalFare = 0.0;

    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('companyId', isEqualTo: widget.companyId)
          .get();

      for (var doc in ridesSnapshot.docs) {
        var rideData = doc.data() as Map<String, dynamic>;

        var customerData = await FirebaseFirestore.instance
            .collection('company_users')
            .doc(rideData['cUserId'])
            .get();

        var driverData = await FirebaseFirestore.instance
            .collection('drivers')
            .doc(rideData['driverId'])
            .get();

        var rideReqData = await FirebaseFirestore.instance
            .collection('ride_requests')
            .doc(rideData['rideRequestId'])
            .get();

        double rideFare = rideData['totalRideFare'];
        totalFare += rideFare;

        rideDetails.add(RideDetail(
          customerName: customerData['name'],
          driverName: "${driverData['firstName']} ${driverData['lastName']}",
          driverContact: driverData['telNum'],
          totalFare: rideFare,
          rideDate: rideReqData['date'],
          pickup: rideReqData['pickupLocation'],
          destination: rideReqData['destination'],
        ));
      }

      setState(() {
        _totalFare = totalFare;
      });
    } catch (e) {
      print('Error fetching ride details: $e');
      rethrow;
    }

    return rideDetails;
  }

  Future<void> _clearRideDetails() async {
    try {
      QuerySnapshot ridesSnapshot = await FirebaseFirestore.instance
          .collection('rides')
          .where('companyId', isEqualTo: widget.companyId)
          .get();

      for (var doc in ridesSnapshot.docs) {
        await doc.reference.delete();
      }

      setState(() {
        _totalFare = 0.0;
        _rideDetailsFuture = _fetchRideDetails();
      });
    } catch (e) {
      print('Error clearing ride details: $e');
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ride History'),
        backgroundColor: Colors.amber,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: EdgeInsets.all(16.0),
                  color: Colors.deepPurpleAccent,
                  child: Text(
                    'Total Amount to Pay: Rs. ${_totalFare.toStringAsFixed(2)}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () async {
                    await _clearRideDetails();
                  },
                  child: Text('Paid'),
                  style: ElevatedButton.styleFrom(primary: Colors.white),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<RideDetail>>(
              future: _rideDetailsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }
                if (snapshot.hasError) {
                  return Center(child: Text('Error loading ride details'));
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(child: Text('No ride details found'));
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    var rideDetail = snapshot.data![index];
                    return Card(
                      margin: EdgeInsets.all(10.0),
                      child: Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Customer Name: ${rideDetail.customerName}"),
                            SizedBox(height: 5),
                            Text("Driver Name: ${rideDetail.driverName}"),
                            SizedBox(height: 5),
                            Text("Driver Contact: ${rideDetail.driverContact}"),
                            SizedBox(height: 5),
                            Text("Total Fare: Rs. ${rideDetail.totalFare.toStringAsFixed(2)}"),
                            SizedBox(height: 5),
                            Text("Ride Date: ${rideDetail.rideDate}"),
                            SizedBox(height: 5),
                            Text("Pickup Location: ${rideDetail.pickup}"),
                            SizedBox(height: 5),
                            Text("Destination: ${rideDetail.destination}"),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class RideDetail {
  final String customerName;
  final String driverName;
  final String driverContact;
  final double totalFare;
  final String rideDate;
  final String pickup;
  final String destination;

  RideDetail({
    required this.customerName,
    required this.driverName,
    required this.driverContact,
    required this.totalFare,
    required this.rideDate,
    required this.pickup,
    required this.destination,
  });
}
