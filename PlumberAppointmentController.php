<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\PlumberAppointment;
use Illuminate\Support\Facades\Auth;

class PlumberAppointmentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        $appointments = PlumberAppointment::all();

        return response()->json([
            'success' => true,
            'message' => 'Appointments fetched successfully',
            'data' => $appointments
        ], 200);
    }

    /**
     * Show the form for creating a new resource.
     */
    public function create()
    {
        //
    }

    /**
     * Store a newly created resource in storage.
     */
    // public function store(Request $request)
    // {
    //     $plumber = new PlumberAppointment();
    //     $plumber->plumber_p_id = $request->plumber_p_id;
    //     $plumber->user_p_id = $request->user_p_id;
    //     $plumber->description = $request->description;
    //     $plumber->status = 'inactive';
    //     $plumber->created_by = Auth::id();

    //     if ($request->hasFile('p_problem_image')) {
    //         $destinationPath = public_path('uploads/plumber_appointment_image');
    //         $plumberImage = $request->file('p_problem_image');
    //         $imageName = time() . '.' . $plumberImage->getClientOriginalExtension();
    //         $plumberImage->move($destinationPath, $imageName);
    //         $plumber->p_problem_image = $imageName;
    //     }

    //     $plumber->save();

    //     return response()->json([
    //         'success' => true,
    //         'message' => 'Record Store Successfully',
    //         'plumber' => $plumber
    //     ], 201);
    // }


    public function store(Request $request)
{
    try {
        $plumber = new PlumberAppointment();
        $plumber->plumber_p_id = $request->plumber_p_id;
        $plumber->user_p_id = $request->user_p_id;
        $plumber->description = $request->description;
        $plumber->status = 'inactive';
        $plumber->created_by = Auth::id();

        $destinationPath = public_path('uploads/plumber_appointment_image');
        if (!file_exists($destinationPath)) {
            mkdir($destinationPath, 0755, true);
        }

        if ($request->hasFile('p_problem_image')) {
            $plumberImage = $request->file('p_problem_image');
            $imageName = time() . '.' . $plumberImage->getClientOriginalExtension();
            $plumberImage->move($destinationPath, $imageName);
            $plumber->p_problem_image = $imageName;
        }

        $plumber->save();

        return response()->json([
            'success' => true,
            'message' => 'Record Store Successfully',
            'plumber' => $plumber
        ], 201);
    } 
    catch (\Exception $e) {
        return response()->json([
            'success' => false,
            'message' => 'Failed to store plumber appointment',
            'error' => $e->getMessage()
        ], 500);
    }
}
    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $Appointment = PlumberAppointment::where('plumber_p_id', $id)->get();

        return response()->json([
            'success' => true,
            'message' => 'Record Found',
            'Appointment' => $Appointment
        ], 201);
    }

    /**
     * Show the form for editing the specified resource.
     */
    public function edit(string $id)
    {
        //
    }

    /**
     * Update the specified resource in storage.
     */
    public function update(Request $request, string $id)
    {
        //
    }

    /**
     * Remove the specified resource from storage.
     */
    public function destroy(string $id)
    {
        //
    }
}
