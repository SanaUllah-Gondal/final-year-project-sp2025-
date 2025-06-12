<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;
use App\Models\ElectricianAppointment;

class ElectricianAppointmentController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        //
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
    public function store(Request $request)
    {
        $electrician = new ElectricianAppointment();
        $electrician->electrician_p_id = $request->electrician_p_id;
        $electrician->user_p_id = $request->user_p_id;
        $electrician->description = $request->description;
        $electrician->status = 'inactive';
        $electrician->created_by = Auth::id();
        $destinationPath = public_path('uploads/electrician_appointment_image');

        if ($request->hasFile('e_problem_image')) {
            $destinationPath = public_path('uploads/electrician_appointment_image');
            $electricianImage = $request->file('e_problem_image');
            $imageName = time() . '.' . $electricianImage->getClientOriginalExtension();
            $electricianImage->move($destinationPath, $imageName);
            $electrician->e_problem_image = $imageName;
        }
        $electrician->save();

        return response()->json([
            'success' => true,
            'message' => 'Record Store Successfully',
            'electrician' => $electrician
        ],201);
    }

    /**
     * Display the specified resource.
     */
    public function show(string $id)
    {
        $Appointment = ElectricianAppointment::with('electrician_user')->where('electrician_p_id',$id)->get();
        return response()->json([
            'success' => true,
            'message' => 'Record Found',
            'Appointment' => $Appointment
        ],201);
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
