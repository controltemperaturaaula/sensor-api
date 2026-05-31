<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;
use App\Models\Lectura;

class SensorController extends Controller
{
    public function store(Request $request)
    {
        $lectura = Lectura::create([
            'sensor' => $request->sensor,
            'temperatura' => $request->temperatura,
            'humitat' => $request->humitat
        ]);

        return response()->json([
            'ok' => true,
            'lectura' => $lectura
        ]);
    }

    public function index()
    {
        return Lectura::latest()->get();
    }
}