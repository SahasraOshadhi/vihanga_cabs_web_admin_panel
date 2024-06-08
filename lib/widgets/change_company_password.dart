import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChangeCompanyPasswordDialog extends StatefulWidget {
  final String companyId;
  final String managerEmail;
  final String managerPassword;

  ChangeCompanyPasswordDialog({
    required this.companyId,
    required this.managerEmail,
    required this.managerPassword,
  });

  @override
  _ChangeCompanyPasswordDialogState createState() => _ChangeCompanyPasswordDialogState();
}

class _ChangeCompanyPasswordDialogState extends State<ChangeCompanyPasswordDialog> {
  late TextEditingController newPasswordController;
  late TextEditingController confirmNewPasswordController;
  bool isUpdating = false;

  @override
  void initState() {
    super.initState();
    newPasswordController = TextEditingController();
    confirmNewPasswordController = TextEditingController();
  }

  Future<void> _updatePassword() async {
    if (newPasswordController.text.isEmpty || confirmNewPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Please fill both password fields.'),
      ));
      return;
    }

    if (newPasswordController.text != confirmNewPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Passwords do not match.'),
      ));
      return;
    }

    setState(() {
      isUpdating = true;
    });

    try {
      // Authenticate the manager to update password
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: widget.managerEmail,
        password: widget.managerPassword,
      );
      User? user = userCredential.user;

      if (user != null) {
        // Update password
        await user.updatePassword(newPasswordController.text);

        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Password updated successfully.'),
        ));
        Navigator.of(context).pop();
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Failed to update password: $e'),
      ));
    } finally {
      setState(() {
        isUpdating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Reset Password'),
      content: SingleChildScrollView(
        child: Column(
          children: [
            TextField(
              controller: newPasswordController,
              decoration: InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: confirmNewPasswordController,
              decoration: InputDecoration(labelText: 'Confirm New Password'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      actions: [
        if (isUpdating)
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
        if (!isUpdating)
          ElevatedButton(
            onPressed: _updatePassword,
            child: Text(
              'Update',
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
