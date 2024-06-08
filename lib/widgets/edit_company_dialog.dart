import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/pdf_picker.dart';
import 'change_company_password.dart';

class EditCompanyDialog extends StatefulWidget {
  final Map<String, dynamic> companyData;

  EditCompanyDialog({required this.companyData});

  @override
  _EditCompanyDialogState createState() => _EditCompanyDialogState();
}

class _EditCompanyDialogState extends State<EditCompanyDialog> {
  late TextEditingController companyNameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController managerNameController;
  late TextEditingController managerContactController;
  late TextEditingController managerEmailController;
  late TextEditingController contractPdfController;
  String? contractPdfUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    companyNameController = TextEditingController(text: widget.companyData['companyName'] ?? '');
    addressController = TextEditingController(text: widget.companyData['address'] ?? '');
    emailController = TextEditingController(text: widget.companyData['email'] ?? '');
    managerNameController = TextEditingController(text: widget.companyData['managerName'] ?? '');
    managerContactController = TextEditingController(text: widget.companyData['managerContact'] ?? '');
    managerEmailController = TextEditingController(text: widget.companyData['managerEmail'] ?? '');
    contractPdfController = TextEditingController(text: widget.companyData['contractPdfUrl'] ?? '');
    contractPdfUrl = widget.companyData['contractPdfUrl'];
  }

  void _onPdfUploaded(String pdfUrl) {
    setState(() {
      contractPdfUrl = pdfUrl;
    });
  }

  Future<void> _saveCompany() async {
    if (companyNameController.text.isEmpty ||
        addressController.text.isEmpty ||
        emailController.text.isEmpty ||
        managerNameController.text.isEmpty ||
        managerContactController.text.isEmpty ||
        managerEmailController.text.isEmpty ||
        contractPdfUrl == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and upload the contract PDF.'),
      ));
      return;
    }

    setState(() {
      isUploading = true;
    });

    String companyId = widget.companyData['companyId'] as String;
    String managerEmail = widget.companyData['managerEmail'] as String;
    String managerPassword = widget.companyData['managerPassword'] as String;

    try {
      print('Attempting to sign in with email: $managerEmail and password: $managerPassword');

      // Authenticate the manager to update email
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: managerEmail,
        password: managerPassword,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Update email if it has changed
        if (emailController.text != managerEmail) {
          await user.updateEmail(emailController.text);

          // Re-authenticate with the new email and old password
          UserCredential newCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
            email: emailController.text,
            password: managerPassword,
          );
          user = newCredential.user;
        }

        // Update company details in Firestore
        await FirebaseFirestore.instance.collection('companies').doc(companyId).update({
          'companyName': companyNameController.text,
          'address': addressController.text,
          'email': emailController.text,
          'managerName': managerNameController.text,
          'managerContact': managerContactController.text,
          'managerEmail': managerEmailController.text,
          'contractPdfUrl': contractPdfUrl,
        });

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Company updated successfully.'),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      print('Error signing in: $e'); // Print the error for debugging
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update company: $e'),
      ));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _resetPassword() {
    Navigator.of(context).pop();
    showDialog(
      context: context,
      builder: (context) => ChangeCompanyPasswordDialog(
        companyId: widget.companyData['companyId'] ?? '',
        managerEmail: widget.companyData['managerEmail'] ?? '',
        managerPassword: widget.companyData['managerPassword'] ?? '',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Company'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: companyNameController,
              decoration: InputDecoration(labelText: 'Company Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: addressController,
              decoration: InputDecoration(labelText: 'Address'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Company Email'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: managerNameController,
              decoration: InputDecoration(labelText: 'Manager\'s Name'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: managerContactController,
              decoration: InputDecoration(labelText: 'Manager\'s Contact'),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: managerEmailController,
              decoration: InputDecoration(labelText: 'Manager\'s Email'),
            ),
            const SizedBox(height: 20),
            PdfPickerTextField(
              controller: contractPdfController,
              labelText: 'Contract PDF',
              helperText: 'Upload the contract PDF',
              onPdfUploaded: _onPdfUploaded,
              companyEmail: companyNameController.text,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        if (isUploading)
          CircularProgressIndicator()
        else
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
        const SizedBox(width: 10),
        if (!isUploading)
          TextButton(
            onPressed: _resetPassword,
            child: Text(
              'Reset Password',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.orange,
            ),
          ),
        const SizedBox(width: 10),
        if (!isUploading)
          ElevatedButton(
            onPressed: _saveCompany,
            child: Text(
              'Save',
              style: TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              backgroundColor: Colors.deepPurpleAccent,
            ),
          ),
      ],
    );
  }
}
