<?php

// =============================================================================
// MIGRATIONS
// =============================================================================

// database/migrations/2024_01_01_000001_create_users_table.php
use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

class CreateUsersTable extends Migration
{
    public function up()
    {
        Schema::create('users', function (Blueprint $table) {
            $table->id();
            $table->string('name');
            $table->string('email')->unique();
            $table->string('phone');
            $table->enum('role', ['customer', 'service_provider', 'admin']);
            $table->timestamp('email_verified_at')->nullable();
            $table->string('password');
            $table->decimal('latitude', 10, 8)->nullable();
            $table->decimal('longitude', 11, 8)->nullable();
            $table->string('address')->nullable();
            $table->rememberToken();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('users');
    }
}

// database/migrations/2024_01_01_000002_create_service_providers_table.php
class CreateServiceProvidersTable extends Migration
{
    public function up()
    {
        Schema::create('service_providers', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->enum('service_type', ['plumber', 'electrician']);
            $table->decimal('rating', 3, 2)->default(0);
            $table->integer('total_reviews')->default(0);
            $table->decimal('price_per_hour', 8, 2);
            $table->enum('status', ['available', 'busy', 'offline'])->default('available');
            $table->json('specialties')->nullable();
            $table->string('license_number')->nullable();
            $table->integer('years_experience')->default(0);
            $table->text('description')->nullable();
            $table->string('profile_image')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('service_providers');
    }
}

// database/migrations/2024_01_01_000003_create_bookings_table.php
class CreateBookingsTable extends Migration
{
    public function up()
    {
        Schema::create('bookings', function (Blueprint $table) {
            $table->id();
            $table->string('booking_id')->unique();
            $table->foreignId('customer_id')->constrained('users')->onDelete('cascade');
            $table->foreignId('service_provider_id')->constrained('service_providers')->onDelete('cascade');
            $table->text('problem_description');
            $table->decimal('estimated_duration', 4, 2);
            $table->decimal('estimated_price', 8, 2);
            $table->decimal('final_price', 8, 2)->nullable();
            $table->enum('status', ['pending', 'accepted', 'in_progress', 'completed', 'cancelled'])->default('pending');
            $table->timestamp('accepted_at')->nullable();
            $table->timestamp('started_at')->nullable();
            $table->timestamp('completed_at')->nullable();
            $table->decimal('customer_latitude', 10, 8);
            $table->decimal('customer_longitude', 11, 8);
            $table->string('customer_address');
            $table->text('notes')->nullable();
            $table->integer('rating')->nullable();
            $table->text('review')->nullable();
            $table->timestamps();
        });
    }

    public function down()
    {
        Schema::dropIfExists('bookings');
    }
}

// =============================================================================
// MODELS
// =============================================================================

// app/Models/User.php
<?php

namespace App\Models;

use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

class User extends Authenticatable
{
    use HasApiTokens, HasFactory, Notifiable;

    protected $fillable = [
        'name',
        'email',
        'phone',
        'role',
        'password',
        'latitude',
        'longitude',
        'address',
    ];

    protected $hidden = [
        'password',
        'remember_token',
    ];

    protected $casts = [
        'email_verified_at' => 'datetime',
        'latitude' => 'decimal:8',
        'longitude' => 'decimal:8',
    ];

    public function serviceProvider()
    {
        return $this->hasOne(ServiceProvider::class);
    }

    public function customerBookings()
    {
        return $this->hasMany(Booking::class, 'customer_id');
    }

    public function isCustomer()
    {
        return $this->role === 'customer';
    }

    public function isServiceProvider()
    {
        return $this->role === 'service_provider';
    }
}

// app/Models/ServiceProvider.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class ServiceProvider extends Model
{
    use HasFactory;

    protected $fillable = [
        'user_id',
        'service_type',
        'rating',
        'total_reviews',
        'price_per_hour',
        'status',
        'specialties',
        'license_number',
        'years_experience',
        'description',
        'profile_image',
    ];

    protected $casts = [
        'specialties' => 'array',
        'rating' => 'decimal:2',
        'price_per_hour' => 'decimal:2',
    ];

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function bookings()
    {
        return $this->hasMany(Booking::class);
    }

    public function scopeAvailable($query)
    {
        return $query->where('status', 'available');
    }

    public function scopeByServiceType($query, $serviceType)
    {
        return $query->where('service_type', $serviceType);
    }

    public function calculateDistance($latitude, $longitude)
    {
        $earthRadius = 6371; // Earth's radius in kilometers
        
        $lat1 = deg2rad($this->user->latitude);
        $lon1 = deg2rad($this->user->longitude);
        $lat2 = deg2rad($latitude);
        $lon2 = deg2rad($longitude);
        
        $deltaLat = $lat2 - $lat1;
        $deltaLon = $lon2 - $lon1;
        
        $a = sin($deltaLat / 2) * sin($deltaLat / 2) +
             cos($lat1) * cos($lat2) *
             sin($deltaLon / 2) * sin($deltaLon / 2);
        $c = 2 * atan2(sqrt($a), sqrt(1 - $a));
        
        return $earthRadius * $c;
    }
}

// app/Models/Booking.php
<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Booking extends Model
{
    use HasFactory;

    protected $fillable = [
        'booking_id',
        'customer_id',
        'service_provider_id',
        'problem_description',
        'estimated_duration',
        'estimated_price',
        'final_price',
        'status',
        'accepted_at',
        'started_at',
        'completed_at',
        'customer_latitude',
        'customer_longitude',
        'customer_address',
        'notes',
        'rating',
        'review',
    ];

    protected $casts = [
        'estimated_duration' => 'decimal:2',
        'estimated_price' => 'decimal:2',
        'final_price' => 'decimal:2',
        'customer_latitude' => 'decimal:8',
        'customer_longitude' => 'decimal:8',
        'accepted_at' => 'datetime',
        'started_at' => 'datetime',
        'completed_at' => 'datetime',
    ];

    public function customer()
    {
        return $this->belongsTo(User::class, 'customer_id');
    }

    public function serviceProvider()
    {
        return $this->belongsTo(ServiceProvider::class);
    }

    protected static function boot()
    {
        parent::boot();
        
        static::creating(function ($booking) {
            $booking->booking_id = 'BK' . time() . rand(1000, 9999);
        });
    }
}

// =============================================================================
// CONTROLLERS
// =============================================================================

// app/Http/Controllers/Api/AuthController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name' => 'required|string|max:255',
            'email' => 'required|string|email|max:255|unique:users',
            'phone' => 'required|string|max:20',
            'password' => 'required|string|min:8|confirmed',
            'role' => 'required|in:customer,service_provider',
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'address' => 'required|string|max:255',
            
            // Service provider specific fields
            'service_type' => 'required_if:role,service_provider|in:plumber,electrician',
            'price_per_hour' => 'required_if:role,service_provider|numeric|min:0',
            'specialties' => 'array',
            'license_number' => 'string|max:255',
            'years_experience' => 'integer|min:0',
            'description' => 'string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'phone' => $request->phone,
            'role' => $request->role,
            'password' => Hash::make($request->password),
            'latitude' => $request->latitude,
            'longitude' => $request->longitude,
            'address' => $request->address,
        ]);

        // Create service provider profile if role is service_provider
        if ($request->role === 'service_provider') {
            ServiceProvider::create([
                'user_id' => $user->id,
                'service_type' => $request->service_type,
                'price_per_hour' => $request->price_per_hour,
                'specialties' => $request->specialties ?? [],
                'license_number' => $request->license_number,
                'years_experience' => $request->years_experience ?? 0,
                'description' => $request->description,
            ]);
        }

        $token = $user->createToken('API Token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'User registered successfully',
            'data' => [
                'user' => $user->load('serviceProvider'),
                'token' => $token,
            ]
        ], 201);
    }

    public function login(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        if (!Auth::attempt($request->only('email', 'password'))) {
            return response()->json([
                'success' => false,
                'message' => 'Invalid credentials'
            ], 401);
        }

        $user = User::where('email', $request->email)->first();
        $token = $user->createToken('API Token')->plainTextToken;

        return response()->json([
            'success' => true,
            'message' => 'Login successful',
            'data' => [
                'user' => $user->load('serviceProvider'),
                'token' => $token,
            ]
        ]);
    }

    public function logout(Request $request)
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Logged out successfully'
        ]);
    }

    public function profile(Request $request)
    {
        return response()->json([
            'success' => true,
            'data' => $request->user()->load('serviceProvider')
        ]);
    }
}

// app/Http/Controllers/Api/ServiceProviderController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class ServiceProviderController extends Controller
{
    public function findNearby(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'latitude' => 'required|numeric|between:-90,90',
            'longitude' => 'required|numeric|between:-180,180',
            'service_type' => 'required|in:plumber,electrician',
            'radius' => 'numeric|min:1|max:50',
            'limit' => 'integer|min:1|max:20',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $latitude = $request->latitude;
        $longitude = $request->longitude;
        $serviceType = $request->service_type;
        $radius = $request->radius ?? 10; // Default 10km
        $limit = $request->limit ?? 10;

        $providers = ServiceProvider::with('user')
            ->available()
            ->byServiceType($serviceType)
            ->get()
            ->map(function ($provider) use ($latitude, $longitude) {
                $distance = $provider->calculateDistance($latitude, $longitude);
                $provider->distance = round($distance, 2);
                $provider->estimated_arrival = $this->calculateEstimatedArrival($distance);
                return $provider;
            })
            ->filter(function ($provider) use ($radius) {
                return $provider->distance <= $radius;
            })
            ->sortBy('distance')
            ->sortByDesc('rating')
            ->take($limit)
            ->values();

        return response()->json([
            'success' => true,
            'message' => 'Nearby service providers found',
            'data' => [
                'providers' => $providers,
                'count' => $providers->count(),
                'search_params' => [
                    'service_type' => $serviceType,
                    'radius' => $radius,
                    'location' => [
                        'latitude' => $latitude,
                        'longitude' => $longitude,
                    ]
                ]
            ]
        ]);
    }

    public function show($id)
    {
        $provider = ServiceProvider::with('user')->find($id);

        if (!$provider) {
            return response()->json([
                'success' => false,
                'message' => 'Service provider not found'
            ], 404);
        }

        return response()->json([
            'success' => true,
            'data' => $provider
        ]);
    }

    public function updateStatus(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:available,busy,offline',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $provider = ServiceProvider::where('user_id', $request->user()->id)->first();

        if (!$provider) {
            return response()->json([
                'success' => false,
                'message' => 'Service provider profile not found'
            ], 404);
        }

        $provider->update(['status' => $request->status]);

        return response()->json([
            'success' => true,
            'message' => 'Status updated successfully',
            'data' => $provider
        ]);
    }

    private function calculateEstimatedArrival($distance)
    {
        // Assuming average speed of 30 km/h in city
        return round($distance / 30 * 60); // in minutes
    }
}

// app/Http/Controllers/Api/BookingController.php
<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\Booking;
use App\Models\ServiceProvider;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Validator;

class BookingController extends Controller
{
    public function store(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'service_provider_id' => 'required|exists:service_providers,id',
            'problem_description' => 'required|string|max:1000',
            'estimated_duration' => 'required|numeric|min:0.5|max:24',
            'customer_latitude' => 'required|numeric|between:-90,90',
            'customer_longitude' => 'required|numeric|between:-180,180',
            'customer_address' => 'required|string|max:255',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $serviceProvider = ServiceProvider::find($request->service_provider_id);

        if ($serviceProvider->status !== 'available') {
            return response()->json([
                'success' => false,
                'message' => 'Service provider is not available'
            ], 400);
        }

        $estimatedPrice = $request->estimated_duration * $serviceProvider->price_per_hour;

        $booking = Booking::create([
            'customer_id' => $request->user()->id,
            'service_provider_id' => $request->service_provider_id,
            'problem_description' => $request->problem_description,
            'estimated_duration' => $request->estimated_duration,
            'estimated_price' => $estimatedPrice,
            'customer_latitude' => $request->customer_latitude,
            'customer_longitude' => $request->customer_longitude,
            'customer_address' => $request->customer_address,
        ]);

        // Update service provider status to busy
        $serviceProvider->update(['status' => 'busy']);

        return response()->json([
            'success' => true,
            'message' => 'Booking created successfully',
            'data' => $booking->load(['customer', 'serviceProvider.user'])
        ], 201);
    }

    public function show($id)
    {
        $booking = Booking::with(['customer', 'serviceProvider.user'])->find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Check if user is authorized to view this booking
        if ($booking->customer_id !== auth()->id() && 
            $booking->serviceProvider->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        return response()->json([
            'success' => true,
            'data' => $booking
        ]);
    }

    public function updateStatus(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'status' => 'required|in:accepted,in_progress,completed,cancelled',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Only service provider can update booking status
        if ($booking->serviceProvider->user_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        $updateData = ['status' => $request->status];

        switch ($request->status) {
            case 'accepted':
                $updateData['accepted_at'] = now();
                break;
            case 'in_progress':
                $updateData['started_at'] = now();
                break;
            case 'completed':
                $updateData['completed_at'] = now();
                $updateData['final_price'] = $booking->estimated_price;
                // Update service provider status back to available
                $booking->serviceProvider->update(['status' => 'available']);
                break;
            case 'cancelled':
                // Update service provider status back to available
                $booking->serviceProvider->update(['status' => 'available']);
                break;
        }

        $booking->update($updateData);

        return response()->json([
            'success' => true,
            'message' => 'Booking status updated successfully',
            'data' => $booking->load(['customer', 'serviceProvider.user'])
        ]);
    }

    public function rate(Request $request, $id)
    {
        $validator = Validator::make($request->all(), [
            'rating' => 'required|integer|min:1|max:5',
            'review' => 'nullable|string|max:1000',
        ]);

        if ($validator->fails()) {
            return response()->json([
                'success' => false,
                'message' => 'Validation failed',
                'errors' => $validator->errors()
            ], 422);
        }

        $booking = Booking::find($id);

        if (!$booking) {
            return response()->json([
                'success' => false,
                'message' => 'Booking not found'
            ], 404);
        }

        // Only customer can rate
        if ($booking->customer_id !== auth()->id()) {
            return response()->json([
                'success' => false,
                'message' => 'Unauthorized'
            ], 403);
        }

        if ($booking->status !== 'completed') {
            return response()->json([
                'success' => false,
                'message' => 'Can only rate completed bookings'
            ], 400);
        }

        $booking->update([
            'rating' => $request->rating,
            'review' => $request->review,
        ]);

        // Update service provider rating
        $serviceProvider = $booking->serviceProvider;
        $totalRating = $serviceProvider->rating * $serviceProvider->total_reviews + $request->rating;
        $newTotalReviews = $serviceProvider->total_reviews + 1;
        $newAverageRating = $totalRating / $newTotalReviews;

        $serviceProvider->update([
            'rating' => $newAverageRating,
            'total_reviews' => $newTotalReviews,
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Rating submitted successfully',
            'data' => $booking->load(['customer', 'serviceProvider.user'])
        ]);
    }

    public function history(Request $request)
    {
        $user = $request->user();
        $query = Booking::with(['customer', 'serviceProvider.user']);

        if ($user->isCustomer()) {
            $query->where('customer_id', $user->id);
        } elseif ($user->isServiceProvider()) {
            $query->whereHas('serviceProvider', function ($q) use ($user) {
                $q->where('user_id', $user->id);
            });
        }

        $bookings = $query->orderBy('created_at', 'desc')->paginate(10);

        return response()->json([
            'success' => true,
            'data' => $bookings
        ]);
    }
}

// =============================================================================
// ROUTES
// =============================================================================

// routes/api.php
<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\AuthController;
use App\Http\Controllers\Api\ServiceProviderController;
use App\Http\Controllers\Api\BookingController;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
*/

// Public routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/login', [AuthController::class, 'login']);

// Protected routes
Route::middleware('auth:sanctum')->group(function () {
    // Auth routes
    Route::post('/logout', [AuthController::class, 'logout']);
    Route::get('/profile', [AuthController::class, 'profile']);
    
    // Service provider routes
    Route::get('/providers/nearby', [ServiceProviderController::class, 'findNearby']);
    Route::get('/providers/{id}', [ServiceProviderController::class, 'show']);
    Route::put('/providers/status', [ServiceProviderController::class, 'updateStatus']);
    
    // Booking routes
    Route::post('/bookings', [BookingController::class, 'store']);
    Route::get('/bookings/{id}', [BookingController::class, 'show']);
    Route::put('/bookings/{id}/status', [BookingController::class, 'updateStatus']);
    Route::post('/bookings/{id}/rate', [BookingController::class, 'rate']);
    Route::get('/bookings', [BookingController::class, 'history']);
});

// =============================================================================
// SEEDERS
// =============================================================================

// database/seeders/DatabaseSeeder.php
<?php

namespace Database\Seeders;

use Illuminate\Database\Seeder;
use App\Models\User;
use App\Models\ServiceProvider;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    public function run()
    {
        // Create sample customers
        $customer1 = User::create([
            'name' => 'John Doe',
            'email' => 'john@example.com',
            'phone' => '+1-555-0101',
            'role' => 'customer',
            'password' => Hash::make('password123'),
            'latitude' => 40.7128,
            'longitude' => -74.0060,
            'address' => '123 Customer St, New York, NY',
        ]);

        $customer2 = User::create([
            'name' => 'Jane Smith',
            'email' => 'jane@example.com',
            'phone' => '+1-555-0102',
            'role' => 'customer',
            'password' => Hash::make('password123'),
            'latitude' => 40.7505,
            'longitude' => -73.9855,
            'address' => '456 Client Ave, New York, NY',
        ]);

        // Create sample service providers
        $plumber1 = User::create([
            'name' => 'Mike Johnson',
            'email' => 'mike@example.com',
            'phone' => '+1-555-0201',
            'role' => 'service_provider',
            'password' => Hash::make('password123'),
            'latitude' => 40.7589,
            'longitude' => -73.9851,
            'address' => '789 Plumber St, New York, NY',
        ]);

        ServiceProvider::create([
            'user_id' => $plumber1->id,
            'service_type' => 'plumber',
            'rating' => 4.8,
            'total_reviews' => 45,
            'price_per_hour' => 85.00,
            'specialties' => ['Emergency repairs', 'Pipe installation', 'Water heaters'],
            'license_number' => 'PL12345',
            'years_experience' => 8,
            'description' => 'Professional plumber with 8+ years experience',
        ]);

        $electrician1 = User::create([
            'name' => 'Sarah Wilson',
            'email' => 'sarah@example.com',
            'phone' => '+1-555-0301',
            'role' => 'service_provider',
            'password' => Hash::make('password123'),
            'latitude' => 40.7614,
            'longitude' => -73.9776,
            'address' => '321 Electric Ave, New York, NY',
        ]);

        ServiceProvider::create([
            'user_id' => $electrician1->id,
            'service_type' => 'electrician',
            'rating' => 4.9,
            'total_reviews' => 67,
            'price_per_hour' => 90.00,
            'specialties' => ['Wiring installation', 'Panel upgrades', 'Smart home setup'],
            'license_number' => 'EL67890',
            'years_experience' => 12,
            'description' => 'Certified electrician specializing in modern electrical systems',
        ]);
    }
}

// =============================================================================
// CONFIGURATION
// =============================================================================

// config/sanctum.php - Add this to your existing sanctum config
<?php

return [
    'stateful' => explode(',', env('SANCTUM_STATEFUL_DOMAINS', sprintf(
        '%s%s',
        'localhost,localhost:3000,127.0.0.1,127.0.0.1:8000,::1',
        env('APP_URL') ? ','.parse_url(env('APP_URL'), PHP_URL_HOST) : ''
    ))),

    'guard' => ['web'],

    'expiration' => null,

    'middleware' => [
        'verify_csrf_token' => App\Http\Middleware\VerifyCsrfToken::class,
        'encrypt_cookies' => App\Http\Middleware\EncryptCookies::class,
    ],
];

// =============================================================================
// INSTALLATION COMMANDS
// =============