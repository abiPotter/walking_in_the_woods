import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

import '../layout/main_layout.dart';

import 'package:location/location.dart';

import 'first_page.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MainLayout(
      child: MapContainer(),
    );
  }
}

class MapContainer extends StatefulWidget {
  const MapContainer({super.key});

  @override
  State<MapContainer> createState() => _MapContainerState();
}

class _MapContainerState extends State<MapContainer> {
  LatLng? _position;
  bool _usingDefaultLocation = false;
  bool _mapLoading = true;
  bool _keyboardOpen = false;

  final MapController _mapController = MapController();
  final TextEditingController _searchController = TextEditingController();

  List<dynamic> _searchSuggestions = [];
  Timer? _debounce;
  final Map<String, List<dynamic>> _searchCache =
      {}; //local cache for faster suggestions
  final GlobalKey _suggestionsKey = GlobalKey();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _loadLocation();
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    debugPrint("Keyboardopen: $_keyboardOpen");

    return Column(children: [
      Expanded(
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _position ?? const LatLng(10, 10),
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate:
                      'https://api.maptiler.com/maps/streets-v2/{z}/{x}/{y}.png?key=pOhyO2fVFGnndUVzQFX8',
                  userAgentPackageName:
                      'com.undergrad_proj.walking_in_the_woods',
                ),
                RichAttributionWidget(
                  attributions: [
                    TextSourceAttribution(
                      '© MapTiler © OpenStreetMap contributors',
                      onTap: () => launchUrl(
                        Uri.parse('https://www.maptiler.com/copyright/'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            if (_mapLoading)
              // still loading the map
              const Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 12),
                    Text(
                      'Loading map...',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            _buildSearchBar(size),
            _buildSuggestions(),
            if (_usingDefaultLocation) _buildGpsWarning(),
            Positioned(
              bottom: 20,
              left: 20,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: Colors.white,
                onPressed: _loadLocation,
                child: Icon(Icons.my_location, color: Colors.blue),
              ),
            ),
          ],
        ),
      ),
      if (!_keyboardOpen)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 30),
          child: FloatingActionButton.extended(
            onPressed: () {
              //open profile
              Navigator.of(context)
                  .push(MaterialPageRoute(builder: (_) => FirstPage()));
            },
            icon: const Icon(Icons.report),
            label: const Text('Report'),
          ),
        ),
    ]);
  }

  Future<void> _loadLocation() async {
    setState(() {
      _mapLoading = true;
    });
    final position = await getCurrentLocation();

    final LatLng resolvedPosition =
        position ?? const LatLng(50.7219, -3.5330); // Exeter

    setState(() {
      _position = resolvedPosition;
      _usingDefaultLocation = position == null;
      _mapLoading = false;
    });

    _mapController.move(resolvedPosition, 15);
    setState(() => _mapLoading = false);
  }

  Future<LatLng?> getCurrentLocation() async {
    bool serviceEnabled;
    PermissionStatus permissionGranted;
    Location location = Location();

    try {
      serviceEnabled = await location.serviceEnabled();
    } on PlatformException catch (e) {
      // this error will always occur as the Location is not setup before this line is reached
      // treat it as though the service is not enabled
      serviceEnabled = false;
    }
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) {
        return null;
      }
    }

    permissionGranted = await location.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await location.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        return null;
      }
    }
    LocationData locationData = await location.getLocation();

    if (locationData.latitude == null || locationData.longitude == null) {
      return null;
    }

    return LatLng(locationData.latitude!, locationData.longitude!);
  }

  // ----------------- UI HELPERS ----------------

  Widget _buildSearchBar(Size size) {
    return Positioned(
      top: 15,
      right: 15,
      left: size.width * 0.5,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.blue),
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
        ),
        child: Row(
          children: [
            const Icon(Icons.search),
            Expanded(
              child: TextField(
                controller: _searchController,
                cursorColor: Colors.black,
                keyboardType: TextInputType.text,
                textInputAction: TextInputAction.go,
                decoration: InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 15),
                    hintText: "Search..."),
                onTap: () {
                  setState(() {
                    _keyboardOpen = true;
                  });
                },
                onChanged: fetchSearchSuggestions,
                onSubmitted: searchLocation,
                onTapOutside: (PointerDownEvent event) {
                  bool insideSuggestions = false;
                  final box = _suggestionsKey.currentContext?.findRenderObject()
                      as RenderBox?;
                  if (box != null) {
                    final pos =
                        box.localToGlobal(Offset.zero); // top-left corner
                    final size = box.size;
                    final rect =
                        Rect.fromLTWH(pos.dx, pos.dy, size.width, size.height);

                    insideSuggestions = rect.contains(event.position);
                  }
                  if (!insideSuggestions) {
                    // Only clear suggestions if the tap is truly outside
                    FocusScope.of(context).unfocus();
                    setState(() {
                      _searchSuggestions.clear();
                      _keyboardOpen = false;
                    });
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    if (_searchSuggestions.isEmpty || _mapLoading) {
      return const SizedBox.shrink();
    }

    return Positioned(
      top: 70,
      left: 20,
      right: 20,
      child: Container(
          key: _suggestionsKey,
          height: 200,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black26, blurRadius: 5),
            ],
          ),
          child: ListView.builder(
            itemCount: _searchSuggestions.length,
            itemBuilder: (context, index) {
              final item = _searchSuggestions[index];

              return ListTile(
                  title: Text(item['display_name']),
                  onTap: () {
                    setState(() {
                      _searchSuggestions.clear();
                      _searchController.clear();
                      _mapLoading = true;
                      _keyboardOpen = false;
                    });
                    _moveToLocation(item: item);
                  });
            },
          )),
    );
  }

  Widget _buildGpsWarning() {
    // display a popup box telling the user GPS location could not be used, and so map has loaded to default location (Exeter)
    return Positioned(
      top: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.amber,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 6,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: const Text(
          'GPS unavailable - showing default location.\nPlease check your device settings.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // --------------------- LOGIC ---------------
  void _moveToLocation({double? lat, double? lon, dynamic item}) async {
    if (item != null) {
      lat = double.parse(item['lat']);
      lon = double.parse(item['lon']);
    }

    if (lat == null || lon == null) return;

    FocusScope.of(context).unfocus();

    _mapController.move(LatLng(lat, lon), 15);
    setState(() => _mapLoading = false);

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   // runs after the current frame is painted
    //   _mapController.move(LatLng(lat, lon), 15);
    //   setState(() => _mapLoading = false);
    // });
  }

  Future<void> searchLocation(String query) async {
    setState(() {
      _searchSuggestions.clear();
      _searchController.clear();
      _mapLoading = true;
      _keyboardOpen = false;
    });

    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=1',
    );
    final response = await http.get(
      url,
      headers: {
        'User-Agent': 'RoamAndReport/1.0',
      },
    );

    if (response.statusCode != 200) return;

    final data = json.decode(response.body);
    if (data.isEmpty) return;

    _moveToLocation(item: data[0]);
  }

  Future<void> fetchSearchSuggestions(String query) async {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 300), () async {
      if (query.length < 2) {
        setState(() => _searchSuggestions.clear());
        return;
      }

      // Check cache first
      if (_searchCache.containsKey(query)) {
        setState(() => _searchSuggestions = _searchCache[query]!);
        return;
      }

      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search'
        '?q=$query&format=json&addressdetails=1&limit=10',
      );

      try {
        final response = await http.get(
          url,
          headers: {
            'User-Agent': 'RoamAndReport/1.0',
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          setState(() {
            _searchSuggestions = data;
            _searchCache[query] = data; // store in cache
          });
        }
      } catch (_) {}
    });
  }
}
