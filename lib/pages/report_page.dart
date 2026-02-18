import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../helpers/map_container.dart';
import '../layout/main_layout.dart';
import 'home_page.dart';
import '../enums/report_status.dart';

class ReportPage extends StatefulWidget {
  final LatLng? initialLocation;
  const ReportPage({super.key, this.initialLocation});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final _formKey = GlobalKey<FormState>();

  LatLng? selectedLocation;
  DateTime? reportedDate;
  String? shortDescription;
  String longDescription = "";
  List<XFile> _images = [];

  final db = FirebaseFirestore.instance;

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
    "Temporary closure",
    "Farm/wildlife disruption",
  ];

  final TextEditingController _dateController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  bool isSaving = false;
  bool hasSaveBeenAttempted = false;
  String? _locationError;

  final supabase = Supabase.instance.client;

  @override
  void initState() {
    super.initState();
    selectedLocation = widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: Container(
        padding: const EdgeInsets.all(16),
        color: Colors.white,
        child: Center(
          child: Form(
            key: _formKey,
            autovalidateMode: hasSaveBeenAttempted
                ? AutovalidateMode.always
                : AutovalidateMode.disabled,
            child: ListView(
              children: [
                Text(
                  "Location:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // optional, adjust size
                  ),
                ),
                Text(
                  selectedLocation != null
                      ? "Check this is the correct location for the problem:"
                      : "Please select the location for the problem on the map:",
                ),
                SizedBox(height: 8),
                Container(
                  height: MediaQuery.of(context).size.height * 0.4,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: _locationError != null ? Colors.red : Colors.grey,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: MapContainer(
                    showReportsToggle: false,
                    showSearchBar: true,
                    showRecentre: true,
                    isShowingReportDetails: false,
                    initialLocation: selectedLocation,
                    onLocationSelected: (latLng) {
                      setState(() {
                        selectedLocation = latLng;
                        _locationError = null;
                      });
                    },
                  ),
                ),
                if (selectedLocation != null)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Selected Location: ${selectedLocation!.latitude}, ${selectedLocation!.longitude}',
                    ),
                  ),
                if (_locationError != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4.0, left: 8),
                    child: Text(
                      _locationError!,
                      style: TextStyle(color: Colors.red),
                    ),
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
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () => pickDate(context),
                  validator: (val) {
                    if (val == null || val.isEmpty) {
                      return 'Please select a date';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 12),
                Text(
                  "Description:",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18, // optional, adjust size
                  ),
                ),
                SizedBox(height: 10),
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width - 32,
                  ),
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
                    onChanged: (desc) {
                      setState(() {
                        shortDescription = desc;
                      });
                      if (hasSaveBeenAttempted) {
                        _formKey.currentState!.validate();
                      }
                    },
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please select a problem';
                      }
                      return null;
                    },
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  "Any additional information:",
                  style: TextStyle(
                    fontSize: 16, // optional, adjust size
                  ),
                ),
                Text(
                  "This could include: \n - Severity of the problem and whether it's getting worse \n - Any safety risks or injuries \n - How much of the area is affected",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                TextFormField(
                  maxLines: null, // grows vertically
                  minLines: 3,
                  keyboardType: TextInputType.multiline,
                  decoration: const InputDecoration(
                    hintText: 'Enter text',
                    alignLabelWithHint: true,
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (longDesc) {
                    longDescription = longDesc;
                  },
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
                  "This could include: \n - Close up of the problem \n - Distance picture for context",
                  style: TextStyle(fontStyle: FontStyle.italic),
                ),
                SizedBox(height: 10),
                Row(
                  children: [
                    IconButton(
                      icon: Icon(Icons.photo),
                      iconSize: 60,
                      onPressed: _showImageSourceSelection,
                    ),
                    _images.isNotEmpty
                        ? Expanded(
                            child: SizedBox(
                              height: 150,
                              child: GridView.builder(
                                itemCount: _images.length,
                                gridDelegate:
                                    SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 3,
                                      crossAxisSpacing: 4,
                                      mainAxisSpacing: 4,
                                    ),
                                itemBuilder: (context, index) {
                                  return Stack(
                                    children: [
                                      Positioned.fill(
                                        child: FutureBuilder<Uint8List>(
                                          future: _images[index].readAsBytes(),
                                          builder: (context, snapshot) {
                                            if (!snapshot.hasData) {
                                              return const Center(
                                                child:
                                                    CircularProgressIndicator(),
                                              );
                                            }

                                            return Image.memory(
                                              snapshot.data!,
                                              fit: BoxFit.cover,
                                            );
                                          },
                                        ),
                                      ),
                                      Positioned(
                                        top: 4,
                                        right: 4,
                                        child: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              _images.removeAt(index);
                                            });
                                          },
                                          child: Container(
                                            decoration: BoxDecoration(
                                              color: Colors.black54,
                                              shape: BoxShape.circle,
                                            ),
                                            padding: EdgeInsets.all(4),
                                            child: Icon(
                                              Icons.close,
                                              color: Colors.white,
                                              size: 12,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
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
                      onPressed: isSaving ? null : saveReport,
                      icon: isSaving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.white,
                              ),
                            )
                          : const Icon(Icons.save),
                      label: Text(isSaving ? 'Saving...' : 'Save'),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> pickDate(BuildContext context) async {
    final DateTime? datePicked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );

    if (datePicked != null) {
      setState(() {
        reportedDate = datePicked;
        _dateController.text =
            "${datePicked.day}-${datePicked.month}-${datePicked.year}";
      });
    }
    if (hasSaveBeenAttempted) {
      _formKey.currentState!.validate();
    }
  }

  void _showImageSourceSelection() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.camera_alt),
                title: Text("Take Photo"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.camera);
                },
              ),
              ListTile(
                leading: Icon(Icons.photo_library),
                title: Text("Choose from Gallery"),
                onTap: () {
                  Navigator.pop(context);
                  _pickImage(ImageSource.gallery);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _pickImage(ImageSource source) async {
    if (source == ImageSource.camera) {
      final XFile? photo = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (photo != null) {
        setState(() {
          _images.add(photo);
        });
      }
    }

    if (source == ImageSource.gallery) {
      final List<XFile> selectedImages = await _imagePicker.pickMultiImage(
        maxWidth: 800,
        maxHeight: 800,
        imageQuality: 80,
      );

      if (selectedImages.isNotEmpty) {
        setState(() {
          _images.addAll(selectedImages);
        });
      }
    }
  }

  Future<void> saveReport() async {
    setState(() {
      isSaving = true;
      hasSaveBeenAttempted = true;
    });

    if (selectedLocation == null || !_formKey.currentState!.validate()) {
      // Invalid fields will automatically show red borders & error messages
      setState(() {
        isSaving = false;
        _locationError = "Please select a location";
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all highlighted fields')),
      );
      return; // stop saving
    }

    try {
      List<String> imageUrls = [];
      if (_images.isNotEmpty) {
        imageUrls = await uploadImages(_images);
      }

      final userid = FirebaseAuth.instance.currentUser!.uid;

      final locationText = await convertlatlngToLocationText(
        selectedLocation!.latitude,
        selectedLocation!.longitude,
      );

      List<String> locationKeywords = locationText
          .toLowerCase()
          .replaceAll(',', '')
          .split(' ');

      //save logic
      final report = <String, dynamic>{
        "latitude": selectedLocation!.latitude,
        "longitude": selectedLocation!.longitude,
        "location text": locationText,
        "location keywords": locationKeywords,
        "date": Timestamp.fromDate(reportedDate!),
        "description": shortDescription,
        "long description": longDescription,
        "photos": imageUrls,
        "likes": 0,
        "dislikes": 0,
        "votes": {},
        "userid": userid,
        "status": ReportStatus.Submitted.toString(),
      };

      final reportRef = await db.collection("reports").add(report);
      debugPrint("report added: ${reportRef.id}");

      if (!mounted) return;

      await showDialog<bool>(
        context: context,
        barrierDismissible: false, // user must choose
        builder: (ctx) => AlertDialog(
          title: const Text('Report Saved Successsfully'),
          content: const Text(
            'Do you want to return to the Home page or stay on this page?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => HomePage()),
              ), // return home
              child: const Text('Return Home'),
            ),
            TextButton(
              onPressed: () => Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => ReportPage())), // stay
              child: const Text('Stay'),
            ),
          ],
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving report: $e')));
      debugPrint("error: $e");
    } finally {
      setState(() {
        isSaving = false;
      });
    }
  }

  Future<List<String>> uploadImages(List<XFile> images) async {
    List<String> downloadUrls = [];

    for (var image in images) {
      final bytes = await image.readAsBytes();
      String fileName = "${DateTime.now().toString()}_${image.name}";

      // Upload to 'reports' bucket
      await supabase.storage
          .from('reports')
          .uploadBinary(
            'images/$fileName',
            bytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final imageUrl = supabase.storage
          .from('reports')
          .getPublicUrl('images/$fileName');

      downloadUrls.add(imageUrl);
    }
    return downloadUrls;
  }

  Future<String> convertlatlngToLocationText(double lat, double lng) async {
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/reverse'
      '?lat=$lat&lon=$lng&format=json',
    );

    final response = await http.get(
      url,
      headers: {'User-Agent': 'RoamAndReport/1.0'},
    );

    if (response.statusCode != 200) return "Unknown location";

    final locationData = json.decode(response.body);

    return locationData['display_name'] ?? "Unknown location";
  }
}
