import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

class LocalCouncilInfo {
  FutureBuilder<List<Map<String, String>>> showLocalCouncilInfo(
    LatLng location,
  ) {
    final Future<List<Map<String, String>>> councilDetails =
        loadCouncilsWithWebsites(location.latitude, location.longitude);

    return FutureBuilder<List<Map<String, String>>>(
      future: councilDetails,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          //still loading
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Finding the responsible local councils...',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              SizedBox(height: 20),
              CircularProgressIndicator(),
            ],
          );
        }
        if (snapshot.hasError) {
          return const Text(
            'Failed to load council information',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          );
        }

        final councils = snapshot.data ?? [];
        if (councils.isEmpty) {
          return const Text(
            'No local councils found',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16),
          );
        }

        return SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'These local councils may be responsible for this issue:',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              for (final council in councils)
                Card(
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      children: [
                        Text(
                          council['name'] ?? '',
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        TextButton.icon(
                          onPressed: () async {
                            final url = council['website'] ?? '';
                            if (url.isNotEmpty) {
                              final uri = Uri.parse(url);
                              await launchUrl(
                                uri,
                                mode: LaunchMode.externalApplication,
                              );
                            }
                          },
                          icon: const Icon(Icons.public),
                          label: const Text('Visit council website'),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<List<String>> findLocalCouncil(double lat, double lng) async {
    final url = Uri.parse(
      'https://mapit.mysociety.org/point/4326/$lng,$lat?type=UTA,CTY,LBO,DIS',
    );

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = jsonDecode(response.body);
        if (data.isNotEmpty) {
          List<String> councils = [];
          for (final area in data.values) {
            if (area['name'] != null) {
              councils.add(area['name']);
            }
          }
          return councils;
        } else {
          return [];
        }
      } else {
        return ["Error: ${response.statusCode}"];
      }
    } catch (e) {
      return ["Exception: $e"];
    }
  }

  Future<String> getCouncilWebsite(String councilName) async {
    final jsonString = await rootBundle.loadString('assets/councils.json');
    final List data = jsonDecode(jsonString);

    final matchCouncil = data.firstWhere(
      (counciljson) => counciljson['name'].toString().toLowerCase().contains(
        councilName.toLowerCase(),
      ),
      orElse: () => null,
    );

    if (matchCouncil != null) {
      return matchCouncil['website'];
    } else {
      return "";
    }
  }

  Future<List<Map<String, String>>> loadCouncilsWithWebsites(
    double lat,
    double lng,
  ) async {
    final List<String> councilNames = await findLocalCouncil(lat, lng);
    final List<Map<String, String>> councilsAndWebsites = [];

    for (String name in councilNames) {
      if (name.contains('Error') || name.contains('Exception')) {
        debugPrint(name);
        return [];
      }
      final String website = await getCouncilWebsite(name);
      councilsAndWebsites.add({'name': name, 'website': website});
    }

    return councilsAndWebsites;
  }
}
