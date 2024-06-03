import 'package:flutter/material.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  void _logOut(BuildContext context) {
    // Perform any necessary clean-up tasks here (e.g., clear user data, tokens, etc.)
    // Navigate to the login screen
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const LogInScreen()));
  }

  void _goToDashboardPage(BuildContext context) {
    // Navigate to the dashboard page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DashboardPage()));
  }

  void _goToRideRequestsPage(BuildContext context) {
    // Navigate to the ride requests page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RideRequestsPage()));
  }

  void _goToAcceptedRidesPage(BuildContext context) {
    // Navigate to the accepted rides page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const AcceptedRidesPage()));
  }

  void _goToRejectedRidesPage(BuildContext context) {
    // Navigate to the rejected rides page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const RejectedRidesPage()));
  }

  void _goToCompletedRidesPage(BuildContext context) {
    // Navigate to the completed rides page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const CompletedRidesPage()));
  }

  void _goToTempDriverAccountsPage(BuildContext context) {
    // Navigate to the temporary driver accounts page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const TempDriverAccountsPage()));
  }

  void _goToDriverDetailsPage(BuildContext context) {
    // Navigate to the driver details page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const DriverDetailsPage()));
  }

  void _goToCompanyDetailsPage(BuildContext context) {
    // Navigate to the company details page
    //Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (context) => const CompanyDetailsPage()));
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
            ListTile(
              leading: Icon(Icons.dashboard),
              title: Text('Dashboard'),
              onTap: () => _goToDashboardPage(context),
            ),
            ListTile(
              leading: Icon(Icons.notifications),
              title: Text('Ride Requests'),
              onTap: () => _goToRideRequestsPage(context),
              trailing: ClipOval(
                child: Container(
                  color: Colors.red,
                  width: 20,
                  height: 20,
                  child: Center(
                    child: Text(
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
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
                      '8',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.cancel),
              title: Text('Rejected Rides'),
              onTap: () => _goToRejectedRidesPage(context),
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
