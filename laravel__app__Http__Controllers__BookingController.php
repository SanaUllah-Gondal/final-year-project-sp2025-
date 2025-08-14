<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\Booking;

class BookingController extends Controller {
  public function index(){ return Booking::all(); }
  public function store(Request $r){ return Booking::create($r->all()); }
  public function show(Booking $booking){ return $booking; }
  public function update(Request $r, Booking $booking){ $booking->update($r->all()); return $booking; }
  public function destroy(Booking $booking){ $booking->delete(); return response()->noContent(); }
}
