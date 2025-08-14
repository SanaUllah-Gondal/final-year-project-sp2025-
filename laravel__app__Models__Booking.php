<?php
namespace App\Models;
use Illuminate\Database\Eloquent\Model;
class Booking extends Model {
  protected $fillable = ['user_id','worker_id','status','scheduled_at','notes','address'];
}
