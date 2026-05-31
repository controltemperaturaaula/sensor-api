<?php

use Illuminate\Support\Facades\Route;
use App\Models\Lectura;

Route::get('/dashboard', function () {

    $lectures = Lectura::latest()
        ->take(20)
        ->get()
        ->reverse();

    return view('dashboard', [
        'lectures' => $lectures
    ]);

});
