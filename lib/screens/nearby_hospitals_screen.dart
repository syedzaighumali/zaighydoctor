import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import '../widgets/top_nav_bar.dart';
import '../utils/responsive.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import '../services/emergency_service.dart';
import '../providers/locale_provider.dart';
import 'package:provider/provider.dart';

class NearbyHospitalsScreen extends StatefulWidget {
  const NearbyHospitalsScreen({super.key});

  @override
  State<NearbyHospitalsScreen> createState() => _NearbyHospitalsScreenState();
}

class _NearbyHospitalsScreenState extends State<NearbyHospitalsScreen> {
  final MapController _mapController = MapController();
  LatLng _currentLocation = const LatLng(33.9946, 72.9313); // Default: Haripur, Pakistan
  bool _isLoading = true;
  List<dynamic> _hospitals = [];

  @override
  void initState() {
    super.initState();
    _determinePosition();
    _fetchHospitals('Lahore'); // Default search for now
  }

  Future<void> _fetchHospitals(String city) async {
    final lang = Provider.of<LocaleProvider>(context, listen: false).locale.languageCode;
    final result = await EmergencyService.fetchHospitals(city, lang);
    if (mounted) {
      setState(() {
        if (result['success']) {
          _hospitals = result['data'];
        }
      });
    }
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    setState(() {
      _isLoading = true;
    });

    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showErrorSnackBar('Location services are disabled.');
        setState(() => _isLoading = false);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permissions are denied.');
          setState(() => _isLoading = false);
          return;
        }
      }
      
      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permissions are permanently denied.');
        setState(() => _isLoading = false);
        return;
      } 

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      _mapController.move(_currentLocation, 15.0);
    } catch (e) {
      debugPrint('Error getting location: $e');
      _showErrorSnackBar('Could not fetch location. Using default.');
      setState(() => _isLoading = false);
    }
  }

  void _showErrorSnackBar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.redAccent),
    );
  }

  void _recenterMap() {
    _mapController.move(_currentLocation, 15.0);
  }

  @override
  Widget build(BuildContext context) {
    bool isMobile = Responsive.isMobile(context);
    bool isTablet = Responsive.isTablet(context);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: const TopNavBar(activeRoute: '/hospitals'),
      body: SingleChildScrollView(
        padding: EdgeInsets.symmetric(
          horizontal: isMobile ? 24 : (isTablet ? 48 : 80),
          vertical: 40,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'RESOURCES',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: theme.primaryColor,
                      letterSpacing: 1.2,
                    ),
                  ),
                ).animate().fadeIn(duration: 600.ms).slideX(begin: -0.2),
                const SizedBox(height: 16),
                Text(
                  'Nearby Medical Facilities',
                  style: GoogleFonts.outfit(
                    fontSize: isMobile ? 32 : 40,
                    fontWeight: FontWeight.w800,
                    color: theme.colorScheme.onSurface,
                    height: 1.1,
                  ),
                ).animate().fadeIn(delay: 200.ms, duration: 600.ms).slideX(begin: -0.1),
                const SizedBox(height: 12),
                Text(
                  'Real-time map view of hospitals and clinics near your current location.',
                  style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 16),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
              ],
            ),
            const SizedBox(height: 32),
            
            Stack(
              children: [
                Container(
                  height: 400,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: theme.dividerColor.withValues(alpha: 0.1)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      )
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _currentLocation,
                        initialZoom: 15.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        ),
                        MarkerLayer(
                          markers: [
                            Marker(
                              point: _currentLocation,
                              width: 80,
                              height: 80,
                              child: Column(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(4),
                                    decoration: const BoxDecoration(
                                      color: Colors.white,
                                      shape: BoxShape.circle,
                                      boxShadow: [
                                        BoxShadow(color: Colors.black26, blurRadius: 4),
                                      ],
                                    ),
                                    child: Icon(
                                      Icons.person_pin_circle,
                                      color: theme.primaryColor,
                                      size: 30,
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                    decoration: BoxDecoration(
                                      color: theme.primaryColor,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Text(
                                      'You',
                                      style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            ..._hospitals.map((h) => Marker(
                              point: LatLng(h['lat'], h['lng']),
                              width: 60,
                              height: 60,
                              child: Icon(Icons.location_on, color: theme.colorScheme.error, size: 40),
                            )),
                          ],
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.98, 0.98)),
                
                Positioned(
                  bottom: 16,
                  right: 16,
                  child: Column(
                    children: [
                      FloatingActionButton.small(
                        heroTag: 'recenter',
                        onPressed: _recenterMap,
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                        child: const Icon(Icons.my_location),
                      ),
                      const SizedBox(height: 8),
                      FloatingActionButton.small(
                        heroTag: 'refresh',
                        onPressed: _determinePosition,
                        backgroundColor: Colors.white,
                        foregroundColor: theme.primaryColor,
                        child: _isLoading 
                          ? const SizedBox(width: 15, height: 15, child: CircularProgressIndicator(strokeWidth: 2))
                          : const Icon(Icons.refresh),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 48),
            
            Text('Verified Facilities', style: GoogleFonts.inter(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            if (_hospitals.isEmpty)
              const Center(child: Text('No hospitals found in this city.'))
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: isMobile ? 1 : 2,
                  childAspectRatio: isMobile ? 3.0 : 3.5,
                  crossAxisSpacing: 24,
                  mainAxisSpacing: 24,
                ),
                itemCount: _hospitals.length,
                itemBuilder: (context, index) {
                  final h = _hospitals[index];
                  return _HospitalCard(
                    name: h['name'] ?? 'Hospital', 
                    city: h['city'] ?? '', 
                    phone: h['phone'] ?? '',
                    onTap: () {
                       _mapController.move(LatLng(h['lat'], h['lng']), 15.0);
                    },
                  )
                      .animate()
                      .fadeIn(duration: 500.ms, delay: (index * 100).ms)
                      .slideY(begin: 0.1, curve: Curves.easeOutQuad);
                },
              ),
          ],
        ),
      ),
    );
  }
}

class _HospitalCard extends StatelessWidget {
  final String name;
  final String city;
  final String phone;
  final VoidCallback onTap;

  const _HospitalCard({
    required this.name, 
    required this.city, 
    required this.phone,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Card(
        color: theme.cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: theme.dividerColor.withValues(alpha: 0.1)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
               Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: theme.primaryColor.withValues(alpha: 0.08),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.local_hospital, color: theme.primaryColor, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.outfit(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: theme.colorScheme.onSurface,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '$city • $phone',
                      style: GoogleFonts.outfit(color: theme.colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 13),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 14, color: theme.hintColor.withValues(alpha: 0.3)),
            ],
          ),
        ),
      ),
    );
  }
}
