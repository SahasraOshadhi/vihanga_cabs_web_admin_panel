import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/athentication/login_screen.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/accepted_requests.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/company_details.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/completed_rides.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/driver_details.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/edit_rates.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/rejected_requests.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/ride_requests.dart';
import 'package:vihanga_cabs_web_admin_panel/pages/temporary_driver_accounts.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)
    // Navigate to the login screen
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LoginScreen()));
  }

  void _goToDashboardPage(BuildContext context) {
    // Navigate to the dashboard page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardPage()));
  }

  void _goToRideRequestsPage(BuildContext context) {
    // Navigate to the ride requests page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => RideRequestPage()));
  }

  void _goToAcceptedRidesPage(BuildContext context) {
    // Navigate to the accepted rides page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => AcceptedRequestsPage()));
  }

  void _goToRejectedRidesPage(BuildContext context) {
    // Navigate to the rejected rides page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  RejectedRequestPage()));
  }

  void _goToCompletedRidesPage(BuildContext context) {
    // Navigate to the completed rides page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) =>  CompletedRidesPage()));
  }

  void _goToTempDriverAccountsPage(BuildContext context) {
    // Navigate to the temporary driver accounts page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TemporaryDriverAccounts()));
  }

  void _goToDriverDetailsPage(BuildContext context) {
    // Navigate to the driver details page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DriverDetails()));
  }

  void _goToCompanyDetailsPage(BuildContext context) {
    // Navigate to the company details page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => CompanyDetails()));
  }

  void _goToEditRatesPage(BuildContext context) {
    // Navigate to the company details page
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => EditRates()));
  }


  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Padding(
        padding: const EdgeInsets.only(top: 8.0),
        child: ListView(
          padding: EdgeInsets.only(top: 5),
          children: [
            Container(
              height: 200,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/images/startup.jpg'),
                  fit: BoxFit.cover,
                ),
              ),
            ),

            SizedBox(width: 20,),

            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => _goToDashboardPage(context),
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ride_requests')
                  .where('assigned', isEqualTo: 'no') // Only fetch unassigned requests
                  .snapshots(),
              builder: (context, snapshot) {
                int requestCount = 0;
                if (snapshot.hasData) {
                  requestCount = snapshot.data!.docs.length;
                }
                return ListTile(
                  leading: Icon(Icons.notifications),
                  title: Text('Ride Requests'),
                  onTap: () => _goToRideRequestsPage(context),
                  trailing: ClipOval(
                    child: Container(
                      color: Colors.amber,
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Text(
                          requestCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ride_requests')
                  .where('acceptedByDriver', isEqualTo: 'yes')
                  .where('rideCompletedByUser' , isEqualTo: 'no')
                  .snapshots(),
              builder: (context, snapshot) {
                int requestCount = 0;
                if (snapshot.hasData) {
                  requestCount = snapshot.data!.docs.length;
                }
                return ListTile(
                  leading: Icon(Icons.check_circle),
                  title: Text('Accepted Rides'),
                  onTap: () => _goToAcceptedRidesPage(context),
                  trailing: ClipOval(
                    child: Container(
                      color: Colors.green,
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Text(
                          requestCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('ride_requests')
                  .where('acceptedByDriver', isEqualTo: 'no')
                  .snapshots(),
              builder: (context, snapshot) {
                int requestCount = 0;
                if (snapshot.hasData) {
                  requestCount = snapshot.data!.docs.length;
                }
                return ListTile(
                  leading: Icon(Icons.cancel),
                  title: Text('Rejected Rides'),
                  onTap: () => _goToRejectedRidesPage(context),
                  trailing: ClipOval(
                    child: Container(
                      color: Colors.red,
                      width: 20,
                      height: 20,
                      child: Center(
                        child: Text(
                          requestCount.toString(),
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.add_task),
              title: Text('Completed Rides'),
              onTap: () => _goToCompletedRidesPage(context),
            ),
            ListTile(
              leading: Icon(Icons.person_add),
              title: Text('Temporary Driver Accounts'),
              onTap: () => _goToTempDriverAccountsPage(context),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Driver Details'),
              onTap: () => _goToDriverDetailsPage(context),
            ),

            ListTile(
              leading: Icon(Icons.business),
              title: Text('Company Details'),
              onTap: () => _goToCompanyDetailsPage(context),
            ),

            ListTile(
              leading: Icon(Icons.money),
              title: Text('Edit Rates'),
              onTap: () => _goToEditRatesPage(context),
            ),

            ListTile(
              leading: Icon(Icons.exit_to_app),
              title: Text('Log Out'),
              onTap: () => _logOut(context),
            ),
          ],
        ),
      ),
    );
  }
}
