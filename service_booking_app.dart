import 'dart:math';
import 'dart:async';

// Models
class Location {
  final double latitude;
  final double longitude;
  final String address;

  Location({
    required this.latitude,
    required this.longitude,
    required this.address,
  });

  @override
  String toString() => '$address (${latitude.toStringAsFixed(4)}, ${longitude.toStringAsFixed(4)})';
}

enum ServiceType { plumber, electrician }

enum ServiceProviderStatus { available, busy, offline }

enum BookingStatus { pending, accepted, inProgress, completed, cancelled }

class ServiceProvider {
  final String id;
  final String name;
  final String phone;
  final ServiceType serviceType;
  final Location location;
  final double rating;
  final double pricePerHour;
  ServiceProviderStatus status;
  final List<String> specialties;

  ServiceProvider({
    required this.id,
    required this.name,
    required this.phone,
    required this.serviceType,
    required this.location,
    required this.rating,
    required this.pricePerHour,
    this.status = ServiceProviderStatus.available,
    this.specialties = const [],
  });

  @override
  String toString() {
    return '''
Provider: $name
Type: ${serviceType.name.toUpperCase()}
Rating: ${rating.toStringAsFixed(1)}/5.0
Price: \$${pricePerHour.toStringAsFixed(2)}/hour
Status: ${status.name.toUpperCase()}
Location: ${location.address}
Phone: $phone
Specialties: ${specialties.join(', ')}
''';
  }
}

class Customer {
  final String id;
  final String name;
  final String phone;
  final Location location;

  Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.location,
  });
}

class Booking {
  final String id;
  final Customer customer;
  final ServiceProvider serviceProvider;
  final DateTime requestTime;
  final String problemDescription;
  final double estimatedDuration;
  BookingStatus status;
  DateTime? acceptedTime;
  DateTime? completedTime;
  double? finalPrice;

  Booking({
    required this.id,
    required this.customer,
    required this.serviceProvider,
    required this.requestTime,
    required this.problemDescription,
    required this.estimatedDuration,
    this.status = BookingStatus.pending,
    this.acceptedTime,
    this.completedTime,
    this.finalPrice,
  });

  @override
  String toString() {
    return '''
Booking ID: $id
Customer: ${customer.name}
Service Provider: ${serviceProvider.name}
Service Type: ${serviceProvider.serviceType.name.toUpperCase()}
Problem: $problemDescription
Status: ${status.name.toUpperCase()}
Request Time: ${requestTime.toString()}
Estimated Duration: ${estimatedDuration.toStringAsFixed(1)} hours
${finalPrice != null ? 'Final Price: \$${finalPrice!.toStringAsFixed(2)}' : ''}
''';
  }
}

// Distance calculation utility
class DistanceCalculator {
  static double calculateDistance(Location loc1, Location loc2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    
    double lat1Rad = loc1.latitude * pi / 180;
    double lat2Rad = loc2.latitude * pi / 180;
    double deltaLat = (loc2.latitude - loc1.latitude) * pi / 180;
    double deltaLon = (loc2.longitude - loc1.longitude) * pi / 180;

    double a = sin(deltaLat / 2) * sin(deltaLat / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLon / 2) * sin(deltaLon / 2);
    double c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadius * c; // Distance in kilometers
  }

  static String formatDistance(double distance) {
    if (distance < 1) {
      return '${(distance * 1000).round()} meters';
    } else {
      return '${distance.toStringAsFixed(2)} km';
    }
  }
}

// Service matching and booking system
class ServiceBookingSystem {
  final List<ServiceProvider> _serviceProviders = [];
  final List<Booking> _bookings = [];
  final List<Customer> _customers = [];

  void addServiceProvider(ServiceProvider provider) {
    _serviceProviders.add(provider);
  }

  void addCustomer(Customer customer) {
    _customers.add(customer);
  }

  List<ServiceProvider> findNearestProviders({
    required Location customerLocation,
    required ServiceType serviceType,
    double maxRadius = 10.0, // km
    int maxResults = 5,
  }) {
    // Filter providers by service type and availability
    List<ServiceProvider> availableProviders = _serviceProviders
        .where((provider) => 
            provider.serviceType == serviceType &&
            provider.status == ServiceProviderStatus.available)
        .toList();

    // Calculate distances and filter by radius
    List<MapEntry<ServiceProvider, double>> providersWithDistance = [];
    
    for (ServiceProvider provider in availableProviders) {
      double distance = DistanceCalculator.calculateDistance(
        customerLocation,
        provider.location,
      );
      
      if (distance <= maxRadius) {
        providersWithDistance.add(MapEntry(provider, distance));
      }
    }

    // Sort by distance, then by rating (descending)
    providersWithDistance.sort((a, b) {
      int distanceComparison = a.value.compareTo(b.value);
      if (distanceComparison != 0) return distanceComparison;
      return b.key.rating.compareTo(a.key.rating);
    });

    // Return top results
    return providersWithDistance
        .take(maxResults)
        .map((entry) => entry.key)
        .toList();
  }

  void displayNearestProviders({
    required Location customerLocation,
    required ServiceType serviceType,
    double maxRadius = 10.0,
    int maxResults = 5,
  }) {
    print('\n🔍 Finding nearest ${serviceType.name}s...\n');
    
    List<ServiceProvider> nearestProviders = findNearestProviders(
      customerLocation: customerLocation,
      serviceType: serviceType,
      maxRadius: maxRadius,
      maxResults: maxResults,
    );

    if (nearestProviders.isEmpty) {
      print('❌ No ${serviceType.name}s found within ${maxRadius}km radius.');
      return;
    }

    print('📍 Found ${nearestProviders.length} ${serviceType.name}(s) near you:\n');
    
    for (int i = 0; i < nearestProviders.length; i++) {
      ServiceProvider provider = nearestProviders[i];
      double distance = DistanceCalculator.calculateDistance(
        customerLocation,
        provider.location,
      );
      
      print('${i + 1}. ${'=' * 50}');
      print(provider.toString());
      print('Distance: ${DistanceCalculator.formatDistance(distance)}');
      print('Estimated arrival: ${_calculateEstimatedArrival(distance)} minutes');
      print('${'=' * 50}\n');
    }
  }

  int _calculateEstimatedArrival(double distance) {
    // Assuming average speed of 30 km/h in city
    return (distance / 30 * 60).round();
  }

  Future<Booking?> createBooking({
    required String customerId,
    required String serviceProviderId,
    required String problemDescription,
    required double estimatedDuration,
  }) async {
    // Find customer and service provider
    Customer? customer = _customers.firstWhere(
      (c) => c.id == customerId,
      orElse: () => throw Exception('Customer not found'),
    );

    ServiceProvider? serviceProvider = _serviceProviders.firstWhere(
      (sp) => sp.id == serviceProviderId,
      orElse: () => throw Exception('Service provider not found'),
    );

    if (serviceProvider.status != ServiceProviderStatus.available) {
      print('❌ Service provider is not available');
      return null;
    }

    // Create booking
    Booking booking = Booking(
      id: 'BK${DateTime.now().millisecondsSinceEpoch}',
      customer: customer,
      serviceProvider: serviceProvider,
      requestTime: DateTime.now(),
      problemDescription: problemDescription,
      estimatedDuration: estimatedDuration,
    );

    _bookings.add(booking);
    
    // Update service provider status
    serviceProvider.status = ServiceProviderStatus.busy;

    print('✅ Booking created successfully!');
    print('📋 Booking Details:');
    print(booking.toString());

    // Simulate booking acceptance
    await _simulateBookingProcess(booking);

    return booking;
  }

  Future<void> _simulateBookingProcess(Booking booking) async {
    print('\n⏳ Waiting for service provider response...');
    await Future.delayed(Duration(seconds: 2));
    
    // Simulate acceptance
    booking.status = BookingStatus.accepted;
    booking.acceptedTime = DateTime.now();
    print('✅ Booking accepted by ${booking.serviceProvider.name}!');
    
    double distance = DistanceCalculator.calculateDistance(
      booking.customer.location,
      booking.serviceProvider.location,
    );
    int arrivalTime = _calculateEstimatedArrival(distance);
    
    print('🚗 ${booking.serviceProvider.name} is on the way!');
    print('⏱️  Estimated arrival: $arrivalTime minutes');
    print('📍 Distance: ${DistanceCalculator.formatDistance(distance)}');
  }

  void completeBooking(String bookingId) {
    Booking? booking = _bookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => throw Exception('Booking not found'),
    );

    booking.status = BookingStatus.completed;
    booking.completedTime = DateTime.now();
    booking.finalPrice = booking.estimatedDuration * booking.serviceProvider.pricePerHour;

    // Update service provider status
    booking.serviceProvider.status = ServiceProviderStatus.available;

    print('✅ Booking completed successfully!');
    print('💰 Final price: \$${booking.finalPrice!.toStringAsFixed(2)}');
  }

  List<Booking> getBookingHistory(String customerId) {
    return _bookings.where((b) => b.customer.id == customerId).toList();
  }

  void displayBookingHistory(String customerId) {
    List<Booking> customerBookings = getBookingHistory(customerId);
    
    if (customerBookings.isEmpty) {
      print('📋 No booking history found.');
      return;
    }

    print('\n📋 Booking History:');
    print('=' * 60);
    for (Booking booking in customerBookings) {
      print(booking.toString());
      print('-' * 60);
    }
  }
}

// Sample data generator
class SampleDataGenerator {
  static List<ServiceProvider> generateSampleProviders() {
    return [
      // Plumbers
      ServiceProvider(
        id: 'P001',
        name: 'John\'s Plumbing',
        phone: '+1-555-0101',
        serviceType: ServiceType.plumber,
        location: Location(
          latitude: 40.7128,
          longitude: -74.0060,
          address: '123 Main St, New York, NY',
        ),
        rating: 4.8,
        pricePerHour: 85.0,
        specialties: ['Emergency repairs', 'Pipe installation', 'Water heaters'],
      ),
      ServiceProvider(
        id: 'P002',
        name: 'Quick Fix Plumbing',
        phone: '+1-555-0102',
        serviceType: ServiceType.plumber,
        location: Location(
          latitude: 40.7589,
          longitude: -73.9851,
          address: '456 Broadway, New York, NY',
        ),
        rating: 4.5,
        pricePerHour: 75.0,
        specialties: ['Drain cleaning', 'Faucet repair', 'Toilet installation'],
      ),
      ServiceProvider(
        id: 'P003',
        name: 'Pro Plumbing Services',
        phone: '+1-555-0103',
        serviceType: ServiceType.plumber,
        location: Location(
          latitude: 40.7282,
          longitude: -73.7949,
          address: '789 Queens Blvd, Queens, NY',
        ),
        rating: 4.9,
        pricePerHour: 95.0,
        specialties: ['Bathroom remodeling', 'Pipe replacement', 'Water filtration'],
      ),
      
      // Electricians
      ServiceProvider(
        id: 'E001',
        name: 'Lightning Fast Electric',
        phone: '+1-555-0201',
        serviceType: ServiceType.electrician,
        location: Location(
          latitude: 40.7505,
          longitude: -73.9934,
          address: '321 Electric Ave, New York, NY',
        ),
        rating: 4.7,
        pricePerHour: 90.0,
        specialties: ['Wiring installation', 'Panel upgrades', 'Emergency repairs'],
      ),
      ServiceProvider(
        id: 'E002',
        name: 'Bright Solutions Electric',
        phone: '+1-555-0202',
        serviceType: ServiceType.electrician,
        location: Location(
          latitude: 40.7614,
          longitude: -73.9776,
          address: '654 Power St, New York, NY',
        ),
        rating: 4.6,
        pricePerHour: 80.0,
        specialties: ['Outlet installation', 'Lighting fixtures', 'Smart home setup'],
      ),
      ServiceProvider(
        id: 'E003',
        name: 'Volt Masters',
        phone: '+1-555-0203',
        serviceType: ServiceType.electrician,
        location: Location(
          latitude: 40.6782,
          longitude: -73.9442,
          address: '987 Brooklyn Ave, Brooklyn, NY',
        ),
        rating: 4.9,
        pricePerHour: 100.0,
        specialties: ['Industrial wiring', 'Solar panel installation', 'EV charging stations'],
      ),
    ];
  }

  static List<Customer> generateSampleCustomers() {
    return [
      Customer(
        id: 'C001',
        name: 'Alice Johnson',
        phone: '+1-555-1001',
        location: Location(
          latitude: 40.7505,
          longitude: -73.9855,
          address: '100 Customer St, New York, NY',
        ),
      ),
      Customer(
        id: 'C002',
        name: 'Bob Smith',
        phone: '+1-555-1002',
        location: Location(
          latitude: 40.7282,
          longitude: -73.7949,
          address: '200 Client Ave, Queens, NY',
        ),
      ),
    ];
  }
}

// Main application
void main() async {
  print('🔧 Service Provider Booking System');
  print('=' * 50);

  // Initialize the system
  ServiceBookingSystem bookingSystem = ServiceBookingSystem();

  // Add sample data
  List<ServiceProvider> providers = SampleDataGenerator.generateSampleProviders();
  List<Customer> customers = SampleDataGenerator.generateSampleCustomers();

  for (ServiceProvider provider in providers) {
    bookingSystem.addServiceProvider(provider);
  }

  for (Customer customer in customers) {
    bookingSystem.addCustomer(customer);
  }

  // Demo: Customer looking for a plumber
  Customer customer = customers[0];
  print('\n👤 Customer: ${customer.name}');
  print('📍 Location: ${customer.location.address}');

  // Find nearest plumbers
  bookingSystem.displayNearestProviders(
    customerLocation: customer.location,
    serviceType: ServiceType.plumber,
    maxRadius: 15.0,
    maxResults: 3,
  );

  // Book a plumber
  print('\n📞 Booking a plumber...');
  Booking? booking = await bookingSystem.createBooking(
    customerId: customer.id,
    serviceProviderId: 'P001',
    problemDescription: 'Kitchen sink is leaking and water pressure is low',
    estimatedDuration: 2.0,
  );

  // Wait a bit and complete the booking
  await Future.delayed(Duration(seconds: 3));
  if (booking != null) {
    bookingSystem.completeBooking(booking.id);
  }

  // Demo: Same customer looking for an electrician
  print('\n' + '=' * 50);
  print('🔌 Now looking for an electrician...');
  
  bookingSystem.displayNearestProviders(
    customerLocation: customer.location,
    serviceType: ServiceType.electrician,
    maxRadius: 15.0,
    maxResults: 3,
  );

  // Book an electrician
  print('\n📞 Booking an electrician...');
  Booking? electricianBooking = await bookingSystem.createBooking(
    customerId: customer.id,
    serviceProviderId: 'E001',
    problemDescription: 'Need to install new outlets in living room',
    estimatedDuration: 3.0,
  );

  // Display booking history
  print('\n' + '=' * 50);
  bookingSystem.displayBookingHistory(customer.id);
}
