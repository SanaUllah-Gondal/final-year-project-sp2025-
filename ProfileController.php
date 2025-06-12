<?php

namespace App\Http\Controllers;

use App\Models\Profile;
use App\Models\PlumberProfile;
use App\Models\ElectricianProfile;
use App\Models\UserProfile;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class ProfileController extends Controller
{
    public function index()
    {
        $profiles = Profile::with(['plumberProfile', 'electricianProfile', 'userProfile'])->get();

        $data = $profiles->map(function ($profile) {
            if ($profile->role === 'plumber' && $profile->plumberProfile) {
                $imageFile = $profile->plumberProfile->plumber_image;
                $imagePath = public_path('uploads/plumber_image/' . $imageFile);

                return [
                    'full_name' => $profile->plumberProfile->full_name,
                    'experience' => $profile->plumberProfile->experience,
                    'hourly_rate' => $profile->plumberProfile->hourly_rate,
                    'service_area' => $profile->plumberProfile->service_area,
                    'skill' => $profile->plumberProfile->skill,
                    'contact_number' => $profile->plumberProfile->contact_number,
                    'image' => file_exists($imagePath) && !empty($imageFile)
                        ? url('uploads/plumber_image/' . $imageFile)
                        : url('uploads/defaults/no-image.png'),
                    'role' => $profile->role,
                    'profile_id' => $profile->profile_id
                ];
            } elseif ($profile->role === 'electrician' && $profile->electricianProfile) {
                return [
                    'full_name' => $profile->electricianProfile->full_name,
                    'experience' => $profile->electricianProfile->experience,
                    'hourly_rate' => $profile->electricianProfile->hourly_rate,
                    'service_area' => $profile->electricianProfile->service_area,
                    'skill' => $profile->electricianProfile->skill,
                    'contact_number' => $profile->electricianProfile->contact_number,
                    'image' => url('uploads/electrician_image/' . $profile->electricianProfile->electrician_image),
                    'role' => $profile->role,
                    'profile_id' => $profile->profile_id
                ];
            } elseif ($profile->role === 'user' && $profile->userProfile) {
                return [
                    'full_name' => $profile->userProfile->full_name,
                    'short_bio' => $profile->userProfile->short_bio,
                    'location' => $profile->userProfile->location,
                    'contact_number' => $profile->userProfile->contact_number,
                    'image' => url('uploads/user_image/' . $profile->userProfile->user_image),
                    'role' => $profile->role,
                    'profile_id' => $profile->profile_id
                ];
            }

            return null;
        })->filter();

        return response()->json([
            'success' => true,
            'data' => $data->values(),
        ]);
    }

    public function store(Request $request)
    {
        $userId = Auth::id();

        if ($request->role === 'plumber') {
            $profilePlumber = new PlumberProfile();
            $profilePlumber->fill($request->only([
                'full_name', 'experience', 'skill', 'service_area', 'hourly_rate', 'contact_number'
            ]));

            $destinationPath = public_path('uploads/plumber_image');
            if (!file_exists($destinationPath)) {
                mkdir($destinationPath, 0755, true);
            }

            $plumberImage = $request->file('plumber_image');
            $imageName = time() . '.' . $plumberImage->getClientOriginalExtension();
            $plumberImage->move($destinationPath, $imageName);

            $profilePlumber->plumber_image = $imageName;
            $profilePlumber->created_by = $userId;
            $profilePlumber->save();

            $profile = new Profile([
                'user_id' => $userId,
                'profile_id' => $profilePlumber->id,
                'role' => $request->role,
            ]);
            $profile->save();

            return response()->json([
                'success' => true,
                'message' => 'Plumber profile created successfully',
                'profile' => $profile,
                'profilePlumber' => $profilePlumber,
            ]);
        }

        if ($request->role === 'electrician') {
            $electricianProfile = new ElectricianProfile();
            $electricianProfile->fill($request->only([
                'full_name', 'experience', 'skill', 'service_area', 'hourly_rate', 'contact_number'
            ]));

            $destinationPath = public_path('uploads/electrician_image');
            if (!file_exists($destinationPath)) {
                mkdir($destinationPath, 0755, true);
            }

            $electricianImage = $request->file('electrician_image');
            $imageName = time() . '.' . $electricianImage->getClientOriginalExtension();
            $electricianImage->move($destinationPath, $imageName);

            $electricianProfile->electrician_image = $imageName;
            $electricianProfile->created_by = $userId;
            $electricianProfile->save();

            $profile = new Profile([
                'user_id' => $userId,
                'profile_id' => $electricianProfile->id,
                'role' => $request->role,
            ]);
            $profile->save();

            return response()->json([
                'success' => true,
                'message' => 'Electrician profile created successfully',
                'profile' => $profile,
                'electricianProfile' => $electricianProfile,
            ]);
        }

        if ($request->role === 'user') {
            $userProfile = new UserProfile();
            $userProfile->fill($request->only(['full_name', 'short_bio', 'location', 'contact_number']));

            $destinationPath = public_path('uploads/user_image');
            if (!file_exists($destinationPath)) {
                mkdir($destinationPath, 0755, true);
            }

            $userImage = $request->file('user_image');
            $imageName = time() . '.' . $userImage->getClientOriginalExtension();
            $userImage->move($destinationPath, $imageName);

            $userProfile->user_image = $imageName;
            $userProfile->save();

            $profile = new Profile([
                'user_id' => $userId,
                'profile_id' => $userProfile->id,
                'role' => $request->role,
            ]);
            $profile->save();

            return response()->json([
                'success' => true,
                'message' => 'User profile created successfully',
                'profile' => $profile,
                'userProfile' => $userProfile,
            ]);
        }

        return response()->json([
            'success' => false,
            'message' => 'Invalid role',
        ], 400);
    }

    public function checkProfiless($userId)
    {
        $profile = Profile::with(['userProfile', 'electricianProfile', 'plumberProfile'])
            ->where('profile_id', $userId)
            ->get();

        if ($profile->isEmpty()) {
            return response()->json([
                'success' => false,
                'message' => 'Profile not found',
            ], 404);
        }

        return response()->json([
            'success' => true,
            'message' => 'Record Found',
            'profile' => $profile
        ], 200);
    }

    public function checkProfile($userId)
    {
        $profile = Profile::with(['userProfile', 'electricianProfile', 'plumberProfile'])
            ->where('user_id', $userId)
            ->first();

        if ($profile) {
            return response()->json([
                'success' => true,
                'profile_exists' => true,
                'message' => 'Profile found',
                'profile' => $profile,
            ]);
        }

        return response()->json([
            'success' => true,
            'profile_exists' => false,
            'message' => 'No profile found for user',
        ]);
    }

    public function update(Request $request)
    {
        $request->validate([
            'location' => 'required|string|max:255',
        ]);

        $userId = Auth::id();

        $profile = Profile::where('user_id', $userId)->where('role', 'user')->first();

        if (!$profile || !$profile->userProfile) {
            return response()->json([
                'success' => false,
                'message' => 'User profile not found',
            ], 404);
        }

        $userProfile = $profile->userProfile;
        $userProfile->location = $request->location;
        $userProfile->save();

        return response()->json([
            'success' => true,
            'message' => 'Location updated successfully',
            'location' => $userProfile->location,
        ]);
    }

    public function show()
    {
        $user = Auth::user();

        $profile = Profile::where('user_id', $user->id)->first();

        return response()->json([
            'data' => $profile
        ]);
    }
}
