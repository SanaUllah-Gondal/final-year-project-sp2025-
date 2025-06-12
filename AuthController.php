<?php

namespace App\Http\Controllers;

use App\Models\User;
use App\Mail\OTPMail;
use Illuminate\Http\Request;
use Illuminate\Support\Carbon;
use Tymon\JWTAuth\Facades\JWTAuth;
use Illuminate\Support\Facades\Hash;
use Illuminate\Support\Facades\Mail;
use Illuminate\Support\Facades\Validator;

class AuthController extends Controller
{
    public function register(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'name'     => 'required|string|max:255',
            'role'     => 'required|string|max:255',
            'email' => 'required',
            'password' => 'required|string|min:6',
        ]);
    
        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }
    
        $otp = rand(100000, 999999);
        $user = User::create([
            'name' => $request->name,
            'email' => $request->email,
            'password' => bcrypt($request->password), 
            'role' => $request->role,
            'otp' => $otp,
            'otp_expires_at' => Carbon::now()->addMinutes(1)
        ]);

        Mail::to($user->email)->send(new OTPMail($user));
        return response()->json([
            'success' => true,
            'message' => 'Otp send on Your Email',
            'User' => $user,
        ], 200);
    }
    

    public function verifyOtp(Request $request)
    {
        $validator = Validator::make($request->all(), [
            'email' => 'required|email|exists:users,email',
            'otp'   => 'required'
        ]);

        if ($validator->fails()) {
            return response()->json($validator->errors(), 422);
        }

        $user = User::where('email', $request->email)->first();

        if ($user->otp !== $request->otp || Carbon::now()->gt($user->otp_expires_at)) {
            return response()->json(['message' => 'Invalid or expired OTP'], 403);
        }

        $user->is_verified = true;
        $user->otp = null;
        $user->otp_expires_at = null;
        $user->save();

        return response()->json(['message' => 'OTP verified successfully. You can now login.']);
    }

    // public function login(Request $request)
    // {
    //     $credentials = $request->only('email', 'password');

    //     $user = User::where('email', $request->email)->first();
    //     if (!$user || !$user->is_verified) {
    //         return response()->json(['error' => 'Email not verified or user not found.'], 403);
    //     }

    //     if (!$token = JWTAuth::attempt($credentials)) {
    //         return response()->json(['error' => 'Invalid credentials'], 401);
    //     }

    //     return response()->json([
    //         'access_token' => $token,
    //         'token_type'   => 'bearer',
    //         'expires_in'   => auth('api')->factory()->getTTL() * 60,
    //         'user'         => auth('api')->user()
    //     ]);
    // }

    public function login(Request $request)
{
    // Validate the input
    $request->validate([
        'email'    => 'required|email',
        'password' => 'required|string|min:6',
    ]);

    $credentials = $request->only('email', 'password');

    // Check if the user exists and is verified
    $user = User::where('email', $request->email)->first();
    if (!$user) {
        return response()->json(['error' => 'User not found.'], 404);
    }

    if (!$user->is_verified) {
        return response()->json(['error' => 'Email not verified.'], 403);
    }

    // Attempt to authenticate and generate a token
    if (!$token = JWTAuth::attempt($credentials)) {
        return response()->json(['error' => 'Invalid credentials.'], 401);
    }

    // Return the token and user information
    return response()->json([
        'access_token' => $token,
        'token_type'   => 'bearer',
        'expires_in'   => auth('api')->factory()->getTTL() * 60,
        'user'         => auth('api')->user(),
    ]);
}

    public function me()
    {
        return response()->json(auth()->user());
    }

    public function logout()
    {
        auth()->logout();
        return response()->json(['message' => 'Successfully logged out']);
    }
}
