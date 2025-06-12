<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Profile extends Model
{
    use HasFactory;

    protected $fillable = ['user_id', 'profile_id', 'role'];

    public function plumberProfile()
    {
        return $this->belongsTo(PlumberProfile::class, 'profile_id');
    }

    public function electricianProfile()
    {
        return $this->belongsTo(ElectricianProfile::class, 'profile_id');
    }

    public function userProfile()
    {
        return $this->belongsTo(UserProfile::class, 'profile_id');
    }
}
