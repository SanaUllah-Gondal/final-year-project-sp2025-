<?php

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\AuthController;
use App\Http\Controllers\ProfileController;
use App\Http\Controllers\PlumberAppointmentController;
use App\Http\Controllers\ElectricianAppointmentController;


Route::middleware('auth:sanctum')->get('/profiles', [ProfileController::class, 'index']);

Route::middleware('auth:sanctum')->get('/users/{id}', function ($id) {
    return response()->json([
        'data' => \App\Models\User::find($id)
    ]);
});

// 🔵 Authentication routes
Route::post('/register', [AuthController::class, 'register']);
Route::post('/verify-otp', [AuthController::class, 'verifyOtp']);
Route::post('/login', [AuthController::class, 'login']);

Route::middleware('auth:api')->group(function () {
    Route::get('/me', [AuthController::class, 'me']);
    Route::post('/logout', [AuthController::class, 'logout']);
});

// 🔵 Profile routes (protected by JWT)
// Route::middleware(['jwt.auth'])->group(function () {
//     Route::resource('/profile', ProfileController::class, 'store');
//     Route::resource('/plumber_appointment', PlumberAppointmentController::class);
//     Route::get('/check-profile/{userId}', [ProfileController::class, 'checkProfile']);
// });

Route::middleware(['jwt.auth'])->group(function () {
    // Resource route for ProfileController with only 'store' action
    Route::resource('/profile', ProfileController::class);


    // Route::get('/check-profiless/{userId}', [ProfileController::class, 'checkProfiless']);

 Route::get('/checkProfiless/{userId}', [ProfileController::class, 'checkProfiless']);
    // Full resource route for PlumberAppointmentController
    Route::resource('/plumber_appointment', PlumberAppointmentController::class);
    Route::resource('/electrician_appointment', ElectricianAppointmentController::class);

    // Route for checking profile by user ID
    Route::get('/check-profile/{userId}', [ProfileController::class, 'checkProfile']);

    // 🔴 NEW ROUTE TO UPDATE USER LOCATION
    Route::put('/update-location', [ProfileController::class, 'update']);
    
});