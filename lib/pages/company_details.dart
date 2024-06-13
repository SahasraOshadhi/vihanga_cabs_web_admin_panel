import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:intl/intl.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/add_company_dialog.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/edit_company_dialog.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/nav_bar.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/pdf_view_dialog.dart';

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

  Future<void> _deleteCompany(BuildContext context, QueryDocumentSnapshot company) async {
    try {
      String userId = company['userId'];
      String email = company['email'];

      await FirebaseFirestore.instance.collection('companies').doc(company.id).delete();

      HttpsCallable callable = FirebaseFunctions.instance.httpsCallable('deleteUserByEmail');
      await callable.call(<String, dynamic>{
        'email': email,
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Company and associated user deleted successfully.'),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete company: $e'),
        ),
      );
    }
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
              final company = companies[index];
              return CompanyCard(company: company, deleteCompany: _deleteCompany);
            },
          );
        },
      ),
    );
  }
}

class CompanyCard extends StatelessWidget {
  final QueryDocumentSnapshot company;
  final Future<void> Function(BuildContext context, QueryDocumentSnapshot company) deleteCompany;

  CompanyCard({required this.company, required this.deleteCompany});

  @override
  Widget build(BuildContext context) {
    final companyData = company.data() as Map<String, dynamic>?;

    return Padding(
      padding: const EdgeInsets.all(20.0),
      child: Card(
        margin: EdgeInsets.all(10),
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                companyData?['companyName'] ?? 'No Company Name',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 10),
              Text('Address: ${companyData?['address'] ?? 'No Address'}'),
              SizedBox(height: 10),
              Text('Company Email: ${companyData?['email'] ?? 'No Email'}'),
              SizedBox(height: 10),
              Text('Manager Name: ${companyData?['managerName'] ?? 'No Manager Name'}'),
              SizedBox(height: 10),
              Text('Manager Contact: ${companyData?['managerContact'] ?? 'No Manager Contact'}'),
              SizedBox(height: 10),
              Text('Manager Email: ${companyData?['managerEmail'] ?? 'No Manager Email'}'),
              SizedBox(height: 10),
              Text('Account Created: ${companyData?['createdAt'] != null ? DateFormat.yMMMd().add_jm().format(companyData!['createdAt'].toDate()) : 'No Date'}'),
              SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (companyData?.containsKey('contractPdfUrl') == true && companyData!['contractPdfUrl'] != null) {
                        String pdfUrl = companyData['contractPdfUrl'];
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return PdfViewDialog(pdfUrl: pdfUrl);
                          },
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('No contract available for this company.')),
                        );
                      }
                    },
                    child: Text('View Contract'),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return EditCompanyDialog(
                                companyData: companyData!,
                                companyId: company.id,
                              );
                            },
                          );
                        },
                      ),

                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          await deleteCompany(context, company);
                        },
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
