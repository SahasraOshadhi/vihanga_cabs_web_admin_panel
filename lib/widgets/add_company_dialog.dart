import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/pdf_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddCompanyDialog extends StatefulWidget {
  @override
  _AddCompanyDialogState createState() => _AddCompanyDialogState();
}

class _AddCompanyDialogState extends State<AddCompanyDialog> {
  late TextEditingController companyNameController;
  late TextEditingController addressController;
  late TextEditingController emailController;
  late TextEditingController managerNameController;
  late TextEditingController managerContactController;
  late TextEditingController managerEmailController;
  late TextEditingController contractPdfController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  String? contractPdfUrl;
  bool isUploading = false;

  @override
  void initState() {
    super.initState();
    companyNameController = TextEditingController();
    addressController = TextEditingController();
    emailController = TextEditingController();
    managerNameController = TextEditingController();
    managerContactController = TextEditingController();
    managerEmailController = TextEditingController();
    contractPdfController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
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
        contractPdfUrl == null ||
        passwordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill all fields and upload the contract PDF.'),
      ));
      return;
    }

    if (passwordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match.'),
      ));
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Create a new user in Firebase Authentication
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text,
        password: passwordController.text,
      );

      // Save company details in Firestore
      await FirebaseFirestore.instance.collection('companies').add({
        'companyName': companyNameController.text,
        'address': addressController.text,
        'email': emailController.text,
        'managerName': managerNameController.text,
        'managerContact': managerContactController.text,
        'managerEmail': managerEmailController.text,
        'contractPdfUrl': contractPdfUrl,
        'userId': userCredential.user!.uid,
        'createdAt': Timestamp.now(),// Store the user ID for deletion later
      });

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to add company: $e'),
      ));
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Add New Company'),
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
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmPasswordController,
              decoration: InputDecoration(labelText: 'Confirm Password'),
              obscureText: true,
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
