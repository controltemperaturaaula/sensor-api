<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Model;

class Lectura extends Model
{
    protected $fillable = [
        'sensor',
        'temperatura',
        'humitat'
    ];
}