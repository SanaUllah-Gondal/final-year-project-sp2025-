<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class PlumberProfile extends Model
{
    protected $fillable = [
        'full_name',
        'experience',
        'skill',
        'service_area',
        'hourly_rate',
        'contact_number',
        'plumber_image',
        'created_by',
    ];
}
