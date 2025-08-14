<?php
namespace App\Http\Controllers;
use Illuminate\Http\Request;
use App\Models\User;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller {
  public function register(Request $r){
    $user = User::create([
      'name'=>$r->name,
      'email'=>$r->email,
      'password'=>Hash::make($r->password),
      'role'=>$r->role ?? 'customer'
    ]);
    return response()->json($user);
  }
  public function login(Request $r){
    // Placeholder login (non-production)
    return response()->json(['token'=>'demo-token']);
  }
  public function me(Request $r){
    return response()->json(['user'=>'demo-user']);
  }
}
