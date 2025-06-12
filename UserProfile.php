<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class UserProfile extends Model
{
    protected $fillable = [
        'full_name',
        'short_bio',
        'location',
        'contact_number',
        'user_image'
    ];   
    
    public function electrician(){
        return $this->hasMany(ElectricianAppointment::class,'user_p_id','id');
    }

    public function plumber(){
        return $this->hasMany(PlumberAppointment::class,'user_p_id','id');
    }
    
}
