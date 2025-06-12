<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class ElectricianProfile extends Model
{
    protected $fillable = [
        'full_name',
        'experience',
        'skill',
        'service_area',
        'hourly_rate',
        'contact_number',
        'electrician_image',
        'created_by',
    ];
    
}
