import 'dart:io'; // For handling file operations
import 'package:firebase_storage/firebase_storage.dart'; // For uploading files to Firebase Storage
import 'package:flutter/material.dart'; // Flutter framework for building UI
import 'package:file_picker/file_picker.dart'; // For picking files from the device
import 'package:flutter/foundation.dart' show kIsWeb; // To check if the platform is web
import 'package:path/path.dart' as path; // For handling file paths

class PdfPickerTextField extends StatefulWidget {
  final TextEditingController controller; // Controller for the text field
  final String labelText; // Label text for the text field
  final String helperText; // Helper text for the text field
  final Function(String) onPdfUploaded; // Callback function for when the PDF is uploaded
  final String companyEmail; // Company email to be used in the file name

  const PdfPickerTextField({
    required this.controller,
    required this.labelText,
    required this.helperText,
    required this.onPdfUploaded,
    required this.companyEmail,
  });

  @override
  _PdfPickerTextFieldState createState() => _PdfPickerTextFieldState();
}

class _PdfPickerTextFieldState extends State<PdfPickerTextField> {
  File? _pdfFile; // Variable to hold the selected PDF file
  bool isUploading = false; // Flag to indicate whether the file is being uploaded

  // Method to pick a PDF file
  Future<void> _pickPdf() async {
    print('File picker opened');
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf'], // Restrict to PDF files only
    );

    if (result != null) {
      if (kIsWeb) {
        // Handle file picking for web
        PlatformFile file = result.files.first;
        String originalFileName = file.name; // Extract the original file name

        print('File selected: $originalFileName');

        setState(() {
          isUploading = true; // Set the uploading flag
        });

        try {
          // URL encode the company's email to make it safe for use in the path
          String encodedEmail = Uri.encodeComponent(widget.companyEmail);

          // Upload the file to Firebase Storage with the company email as a subfolder
          UploadTask uploadTask = FirebaseStorage.instance
              .ref('contracts/$encodedEmail/$originalFileName')
              .putData(file.bytes!);

          print('Upload task started');

          // Wait for the upload to complete
          TaskSnapshot taskSnapshot = await uploadTask;
          String pdfUrl = await taskSnapshot.ref.getDownloadURL(); // Get the download URL of the uploaded file

          print('Upload task completed: $pdfUrl');

          setState(() {
            isUploading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF upload successful!')), // Show success message
            );
          });

          // Call the callback with the pdfUrl
          widget.onPdfUploaded(pdfUrl);
          widget.controller.text = originalFileName; // Set the text field with the original file name
        } catch (e) {
          print('Error during PDF upload: $e');
          setState(() {
            isUploading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF upload failed!')), // Show error message
            );
          });
        }
      } else {
        // Handle file picking for mobile
        File file = File(result.files.single.path!); // Get the selected file
        String originalFileName = path.basename(file.path); // Extract the original file name

        print('File selected: $originalFileName');

        setState(() {
          _pdfFile = file;
          isUploading = true; // Set the uploading flag
        });

        try {
          // URL encode the company's email to make it safe for use in the path
          String encodedEmail = Uri.encodeComponent(widget.companyEmail);

          // Upload the file to Firebase Storage with the company email as a subfolder
          UploadTask uploadTask = FirebaseStorage.instance
              .ref('contracts/$encodedEmail/$originalFileName')
              .putFile(file);

          print('Upload task started');

          // Wait for the upload to complete
          TaskSnapshot taskSnapshot = await uploadTask;
          String pdfUrl = await taskSnapshot.ref.getDownloadURL(); // Get the download URL of the uploaded file

          print('Upload task completed: $pdfUrl');

          setState(() {
            isUploading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF upload successful!')), // Show success message
            );
          });

          // Call the callback with the pdfUrl
          widget.onPdfUploaded(pdfUrl);
          widget.controller.text = originalFileName; // Set the text field with the original file name
        } catch (e) {
          print('Error during PDF upload: $e');
          setState(() {
            isUploading = false;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('PDF upload failed!')), // Show error message
            );
          });
        }
      }
    } else {
      print('No file selected');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No file selected')), // Show message if no file was selected
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: TextField(
            controller: widget.controller, // Controller for the text field
            decoration: InputDecoration(
              labelText: widget.labelText, // Set the label text
              labelStyle: TextStyle(fontSize: 14),
              hintText: _pdfFile == null ? 'Select a PDF' : _pdfFile!.path, // Show the file path if a file is selected
              helperText: widget.helperText, // Set the helper text
              helperStyle: TextStyle(color: Colors.grey.withOpacity(0.7)),
            ),
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 15,
            ),
            readOnly: true, // Make the text field read-only
          ),
        ),
        IconButton(
          icon: Icon(Icons.upload_file),
          onPressed: isUploading ? null : _pickPdf, // Disable the button if uploading
        ),
        if (isUploading) CircularProgressIndicator(), // Show a progress indicator if uploading
      ],
    );
  }
}
