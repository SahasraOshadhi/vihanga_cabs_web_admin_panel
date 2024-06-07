import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/add_company_dialog.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/edit_company_dialog.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';
import 'package:intl/intl.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vihanga_cabs_web_admin_panel/methods/non_web_iframe.dart' if (dart.library.html) 'package:vihanga_cabs_web_admin_panel/methods/web_iframe.dart';

class CompanyDetails extends StatefulWidget {
  @override
  _CompanyDetailsState createState() => _CompanyDetailsState();
}

class _CompanyDetailsState extends State<CompanyDetails> {
  void _showAddCompanyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddCompanyDialog();
      },
    );
  }

  Future<void> _editCompany(Map<String, dynamic> companyData) async {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return EditCompanyDialog(companyData: companyData);
      },
    );
  }

  Future<void> _deleteCompany(String companyId) async {
    await FirebaseFirestore.instance.collection('companies').doc(companyId).delete();
  }

  void _showPdfDialog(String pdfUrl) {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(10),
                alignment: Alignment.topRight,
                child: IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () async {
                    if (await canLaunch(pdfUrl)) {
                      await launch(pdfUrl);
                    } else {
                      print("Could not launch $pdfUrl");
                    }
                  },
                ),
              ),
              Expanded(
                child: Container(
                  width: double.infinity,
                  height: 400,
                  child: iframeView(pdfUrl), // Using the iframeView here
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        title: Text('Company Details'),
        backgroundColor: Colors.amber,
        actions: [
          TextButton(
            child: Text(
              'Add New Company',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            onPressed: _showAddCompanyDialog,
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
            ),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('companies').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          final companies = snapshot.data!.docs;

          return ListView.builder(
            itemCount: companies.length,
            itemBuilder: (context, index) {
              final company = companies[index].data() as Map<String, dynamic>;
              final companyId = companies[index].id;
              final createdDate = company['createdDate'] != null
                  ? DateFormat.yMMMd().format(company['createdDate'].toDate())
                  : 'N/A';

              return Card(
                margin: const EdgeInsets.all(10.0),
                child: FractionallySizedBox(
                  widthFactor: 0.90,
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.deepPurpleAccent,
                      borderRadius: const BorderRadius.all(Radius.circular(30)),
                    ),
                    child: ListTile(
                      title: Text(company['companyName'], style: TextStyle(color: Colors.white)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Address: ${company['address']}', style: TextStyle(color: Colors.white)),
                          Text('Email: ${company['email']}', style: TextStyle(color: Colors.white)),
                          Text('Manager: ${company['managerName']}', style: TextStyle(color: Colors.white)),
                          Text('Manager Contact: ${company['managerContact']}', style: TextStyle(color: Colors.white)),
                          Text('Manager Email: ${company['managerEmail']}', style: TextStyle(color: Colors.white)),
                          Text('Account Created: $createdDate', style: TextStyle(color: Colors.white)), // Display account creation date
                          SizedBox(height: 10),
                          ElevatedButton(
                            onPressed: () => _showPdfDialog(company['contractPdfUrl']),
                            child: Text('View Contract'),
                            style: ElevatedButton.styleFrom(
                              primary: Colors.deepOrange,
                            ),
                          ),
                        ],
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: Icon(Icons.edit, color: Colors.white),
                            onPressed: () => _editCompany(company),
                          ),
                          IconButton(
                            icon: Icon(Icons.delete, color: Colors.white),
                            onPressed: () => _deleteCompany(companyId),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
