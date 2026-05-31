<!DOCTYPE html>
<html lang="ca">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Dashboard IoT</title>

    <script src="https://cdn.jsdelivr.net/npm/chart.js"></script>

    <style>
        body {
            font-family: Arial, sans-serif;
            margin: 40px;
            background-color: #f5f5f5;
        }

        h1 {
            color: #333;
        }

        .card {
            background: white;
            padding: 20px;
            border-radius: 10px;
            margin-bottom: 20px;
            box-shadow: 0 2px 10px rgba(0,0,0,0.1);
        }

        canvas {
            max-width: 100%;
        }

        table {
            width: 100%;
            border-collapse: collapse;
            background: white;
        }

        th, td {
            padding: 12px;
            border-bottom: 1px solid #ddd;
            text-align: center;
        }

        th {
            background-color: #eee;
        }
    </style>
</head>

<body>

    <h1>Dashboard IoT</h1>

    <div class="card">
        <h2>Gràfica de Temperatura i Humitat</h2>

        <canvas id="grafica"></canvas>
    </div>

    <div class="card">
        <h2>Últimes lectures</h2>

        <table>
            <thead>
                <tr>
                    <th>ID</th>
                    <th>Temperatura</th>
                    <th>Humitat</th>
                    <th>Data</th>
                </tr>
            </thead>

            <tbody>
                @foreach($lectures as $lectura)
                    <tr>
                        <td>{{ $lectura->id }}</td>
                        <td>{{ $lectura->temperatura }} °C</td>
                        <td>{{ $lectura->humitat }} %</td>
                        <td>{{ $lectura->created_at }}</td>
                    </tr>
                @endforeach
            </tbody>
        </table>
    </div>

    <script>

        const labels = [
            @foreach($lectures as $lectura)
                '{{ $lectura->created_at }}',
            @endforeach
        ];

        const temperatures = [
            @foreach($lectures as $lectura)
                {{ $lectura->temperatura }},
            @endforeach
        ];

        const humiditats = [
            @foreach($lectures as $lectura)
                {{ $lectura->humitat }},
            @endforeach
        ];

        const ctx = document.getElementById('grafica');

        new Chart(ctx, {

            type: 'line',

            data: {

                labels: labels,

                datasets: [

                    {
                        label: 'Temperatura °C',
                        data: temperatures,
                        borderColor: 'red',
                        backgroundColor: 'rgba(255,0,0,0.2)',
                        borderWidth: 2
                    },

                    {
                        label: 'Humitat %',
                        data: humiditats,
                        borderColor: 'blue',
                        backgroundColor: 'rgba(0,0,255,0.2)',
                        borderWidth: 2
                    }

                ]
            }

        });

    </script>

</body>
</html>