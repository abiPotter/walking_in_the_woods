import 'package:flutter/material.dart';
import 'package:http/http.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import '../helpers/map_container.dart';
import '../layout/main_layout.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  DateTime? reportedDate;
  String? shortDescription;
  List<XFile>? _images = [];

  List<String> possibleProblems = [
    "Blocked/overgrown footpath",
    "Damaged footpath",
    "Slippery footpath",
    "Locked gate",
    "Poor signage",
    "Poor visibility",
    "Safety hazard",
    "Accessibility issue, e,g, steep slope, narrow path, obstacles inaccessible for wheelchair users, etc.",
    "Flooding",
    "Temporary closure"
  ];

  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return MainLayout(
        child: Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Center(
                child: ListView(children: [
              Text(
                "Location:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // optional, adjust size
                ),
              ),
              Text("Confirm this is the correct location for the problem"),
              SizedBox(height: 8),
              SizedBox(
                height: MediaQuery.of(context).size.height * 0.4,
                child: MapContainer(),
              ),
              SizedBox(height: 12),
              Text(
                "Date Found:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // optional, adjust size
                ),
              ),
              TextFormField(
                controller: _dateController,
                readOnly: true,
                decoration: const InputDecoration(
                    hintText: '  Select date',
                    suffixIcon: Icon(Icons.calendar_today)),
                onTap: () => pickDate(context),
              ),
              SizedBox(height: 12),
              Text(
                "Description:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // optional, adjust size
                ),
              ),
              SizedBox(height: 8),
              ConstrainedBox(
                constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32),
                child: DropdownButtonFormField<String>(
                  isExpanded: true,
                  initialValue: shortDescription,
                  decoration: const InputDecoration(
                    labelText: 'Identify the problem',
                    border: OutlineInputBorder(),
                  ),
                  items: possibleProblems.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      shortDescription = value;
                    });
                  },
                ),
              ),
              SizedBox(height: 8),
              Text("Any additional information:",
                  style: TextStyle(
                    fontSize: 16, // optional, adjust size
                  )),
              Text(
                  "This could include: \n - Severity of the problem and whether it's getting worse \n - Any safety risks or injuries \n - How much of the area is affected"),
              TextFormField(
                maxLines: null, // grows vertically
                minLines: 3,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                  hintText: 'Enter text',
                  alignLabelWithHint: true,
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 12),
              Text(
                "Photos:",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18, // optional, adjust size
                ),
              ),
              Text(
                  "This could include: \n - Close up of the problem \n - Distance picture for context"),
              SizedBox(height: 10),
              Row(
                children: [
                  IconButton(
                    icon: Icon(Icons.photo),
                    iconSize: 60,
                    onPressed: _pickImage,
                  ),
                  _images != null && _images!.isNotEmpty
                      ? Expanded(
                          child: SizedBox(
                            height: 150,
                            child: GridView.builder(
                              itemCount: _images?.length ?? 0,
                              gridDelegate:
                                  SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 4,
                                mainAxisSpacing: 4,
                              ),
                              itemBuilder: (context, index) {
                                return Image.file(
                                  File(_images![index].path),
                                  fit: BoxFit.cover,
                                );
                              },
                            ),
                          ),
                        )
                      : Text("No image selected"),
                ],
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30),
                child: Center(
                  child: FloatingActionButton.extended(
                    onPressed: saveReport,
                    icon: const Icon(Icons.save),
                    label: const Text('Save'),
                  ),
                ),
              ),
            ]))));
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (datePicked != null) {
      setState(() {
        reportedDate = datePicked;
        _dateController.text =
            "${datePicked.day}-${datePicked.month}-${datePicked.year}";
      });
    }
  }

  Future<void> _pickImage() async {
    final List<XFile>? selectedImages = await _imagePicker.pickMultiImage(
      maxWidth: 800,
      maxHeight: 800,
      imageQuality: 80,
    );

    if (selectedImages != null && selectedImages.isNotEmpty) {
      setState(() {
        _images = selectedImages;
      });
    }
  }

  void saveReport() {
    //save logic
  }
}
