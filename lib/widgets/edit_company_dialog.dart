import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditCompanyDialog extends StatefulWidget {
  final Map<String, dynamic> companyData;
  final String companyId;

  EditCompanyDialog({required this.companyData, required this.companyId});

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

  @override
  void initState() {
    super.initState();
    companyNameController = TextEditingController(text: widget.companyData['companyName']);
    addressController = TextEditingController(text: widget.companyData['address']);
    emailController = TextEditingController(text: widget.companyData['email']);
    managerNameController = TextEditingController(text: widget.companyData['managerName']);
    managerContactController = TextEditingController(text: widget.companyData['managerContact']);
    managerEmailController = TextEditingController(text: widget.companyData['managerEmail']);
  }

  Future<void> _saveChanges() async {
    try {
      await FirebaseFirestore.instance.collection('companies').doc(widget.companyId).update({
        'companyName': companyNameController.text,
        'address': addressController.text,
        'email': emailController.text,
        'managerName': managerNameController.text,
        'managerContact': managerContactController.text,
        'managerEmail': managerEmailController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Company details updated successfully.'),
      ));
      Navigator.of(context).pop();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update company details: $e'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Edit Company Details'),
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
          ],
        ),
      ),
      actions: [
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
        ElevatedButton(
          onPressed: _saveChanges,
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
