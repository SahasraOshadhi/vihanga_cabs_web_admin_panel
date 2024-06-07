import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:vihanga_cabs_web_admin_panel/widgets/pdf_picker.dart';

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
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  String? contractPdfUrl;
  bool isUploading = false;
  bool isEmailChanged = false;

  @override
  void initState() {
    super.initState();
    companyNameController = TextEditingController(text: widget.companyData['companyName']);
    addressController = TextEditingController(text: widget.companyData['address']);
    emailController = TextEditingController(text: widget.companyData['email']);
    managerNameController = TextEditingController(text: widget.companyData['managerName']);
    managerContactController = TextEditingController(text: widget.companyData['managerContact']);
    managerEmailController = TextEditingController(text: widget.companyData['managerEmail']);
    contractPdfController = TextEditingController(text: widget.companyData['contractPdfUrl']);
    contractPdfUrl = widget.companyData['contractPdfUrl'];
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  void _onPdfUploaded(String pdfUrl) {
    setState(() {
      contractPdfUrl = pdfUrl;
    });
  }

  Future<void> _updateCompany() async {
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

    if (isEmailChanged || passwordController.text.isNotEmpty) {
      if (passwordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Please fill both password fields.'),
        ));
        return;
      }
      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Passwords do not match.'),
        ));
        return;
      }
    }

    setState(() {
      isUploading = true;
    });

    String companyId = widget.companyData['id'];

    try {
      if (isEmailChanged || passwordController.text.isNotEmpty) {
        User? user = FirebaseAuth.instance.currentUser;

        // Update email and/or password
        if (isEmailChanged) {
          await user?.updateEmail(managerEmailController.text);
        }
        if (passwordController.text.isNotEmpty) {
          await user?.updatePassword(passwordController.text);
        }
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

      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update company: $e'),
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
              onChanged: (value) {
                setState(() {
                  isEmailChanged = true;
                });
              },
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
            onPressed: _updateCompany,
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
