import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:plumber_project/pages/Apis.dart';
import 'package:plumber_project/pages/users/booking.dart';
import 'package:plumber_project/pages/userservice/electricianservice.dart';
import 'package:plumber_project/pages/userservice/plumberservice.dart';
import 'profile.dart';
import '../emergency.dart';

final Color darkBlue = Color(0xFF003E6B);
final Color tealBlue = Color(0xFF00A8A8);

class HomeController extends GetxController {
  var showSearchBar = false.obs;
  var selectedIndex = 0.obs;
  var userLocation = 'Fetching location...'.obs;
  var savedLocations = <String>[].obs;
  var selectedLocation = RxString('');
  var filteredServices = <Map<String, dynamic>>[].obs;

  final TextEditingController searchController = TextEditingController();

  List<Map<String, dynamic>> services = [
    {"icon": Icons.tap_and_play, "title": "Plumber"},
    {"icon": Icons.electrical_services, "title": "Electrician"},
  ];

  @override
  void onInit() {
    super.onInit();
    filteredServices.value = services;
    fetchUserLocation();
    loadSavedLocations();
  }

  @override
  void onClose() {
    searchController.dispose();
    super.onClose();
  }

  Future<void> fetchUserLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');

    if (token == null) {
      userLocation.value = 'Not logged in';
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/profile'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final profile = data['data'];
        if (profile != null) {
          userLocation.value = profile['location'] ?? 'Location not set';
          selectedLocation.value = userLocation.value;
        }
      } else {
        userLocation.value = 'Failed to load location';
      }
    } catch (e) {
      userLocation.value = 'Error loading location';
    }
  }

  void toggleSearchBar() {
    showSearchBar.value = !showSearchBar.value;
    if (!showSearchBar.value) {
      searchController.clear();
      filteredServices.value = services;
    }
  }

  void filterServices(String query) {
    filteredServices.value = services
        .where((service) =>
        service["title"].toLowerCase().contains(query.toLowerCase()))
        .toList();
  }

  void onTabSelected(int index, BuildContext context) {
    if (index == 1) {
      Get.to(() => EmergencyScreen());
    } else if (index == 2) {
      Get.to(() => ProfileScreen());
    } else {
      selectedIndex.value = index;
    }
  }

  void onServiceCardClicked(String serviceName) {
    if (serviceName.toLowerCase() == 'plumber') {
      Get.to(() => PlumberPage());
    } else if (serviceName.toLowerCase() == 'electrician') {
      Get.to(() => ElectricianPage());
    }
  }

  Future<void> updateUserLocation(String location) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('bearer_token');
    if (token == null) return;

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/profile/update'),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: json.encode({"location": location}),
      );

      if (response.statusCode == 200) {
        userLocation.value = location;
      }
    } catch (e) {
      print('Error updating location: $e');
    }
  }

  Future<void> loadSavedLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final storedLocations = prefs.getStringList('saved_locations') ?? [];
    savedLocations.value = storedLocations;
  }
}

class HomeScreen extends StatelessWidget {
  final HomeController controller = Get.put(HomeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBlue,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: tealBlue,
        title: Row(
          children: [
            PopupMenuButton<String>(
              icon: Icon(Icons.room_service, color: Colors.black, size: 28),
              onSelected: (value) {
                if (value == 'booking-request') {
                  Get.to(() => RequestScreen());
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: 'booking-request',
                  child: Row(
                    children: [
                      Icon(Icons.request_page, color: Colors.black),
                      SizedBox(width: 8),
                      Text('Booking Request'),
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(width: 8),
            Text(
              "Skill-Link",
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
        elevation: 0,
      ),
      body: _buildHomeScreen(),
      bottomNavigationBar: Obx(
            () => BottomNavigationBar(
          backgroundColor: Colors.blue,
          currentIndex: controller.selectedIndex.value,
          selectedItemColor: Colors.yellow,
          unselectedItemColor: Colors.white,
          onTap: (index) => controller.onTabSelected(index, context),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.emergency, color: Colors.red),
              label: 'Emergency',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHomeScreen() {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        children: [
          Obx(() => Align(
            alignment: Alignment.centerRight,
            child: controller.showSearchBar.value
                ? AnimatedContainer(
              duration: Duration(milliseconds: 300),
              width: MediaQuery.of(Get.context!).size.width * 0.9,
              child: TextField(
                controller: controller.searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Search services...",
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.close),
                    onPressed: controller.toggleSearchBar,
                  ),
                ),
                onChanged: controller.filterServices,
              ),
            )
                : IconButton(
              icon: Icon(Icons.search, color: Colors.cyan),
              onPressed: controller.toggleSearchBar,
              tooltip: 'Search Services',
            ),
          )),
          SizedBox(height: 20),
          Expanded(
            child: Obx(() => ListView.builder(
              itemCount: controller.filteredServices.length,
              itemBuilder: (context, index) {
                final service = controller.filteredServices[index];
                String imagePath = service["title"].toLowerCase() == "plumber"
                    ? "assets/images/pipe_background.jpeg"
                    : "assets/images/electric_background.jpeg";

                return GestureDetector(
                  onTap: () => controller.onServiceCardClicked(service["title"]),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          offset: Offset(0, 4),
                          blurRadius: 8,
                        )
                      ],
                      image: DecorationImage(
                        image: AssetImage(imagePath),
                        fit: BoxFit.cover,
                        colorFilter: ColorFilter.mode(
                          Colors.black.withOpacity(0.3),
                          BlendMode.darken,
                        ),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Row(
                        children: [
                          Icon(
                            service["icon"],
                            size: 40,
                            color: Colors.yellow,
                          ),
                          SizedBox(width: 20),
                          Text(
                            service["title"],
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              shadows: [
                                Shadow(
                                  offset: Offset(1, 1),
                                  blurRadius: 2,
                                  color: Colors.black,
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            )),
          ),
        ],
      ),
    );
  }
}