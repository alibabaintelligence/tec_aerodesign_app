import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:tec_aerodesign_app/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tec Aerodesign App',
      theme: ThemeData(),
      routes: {
        '/': (context) => const HomeScreen(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final DatabaseReference _temperatureRef =
      FirebaseDatabase.instance.ref().child('esp32test/sensores/temperature');
  late final DatabaseReference _pressureRef =
      FirebaseDatabase.instance.ref().child('esp32test/sensores/pressure');
  final List<double> _temperatures = [33.0, 33.0, 33.0];
  final List<double> _pressures = [33.0, 33.0, 33.0];

  @override
  void initState() {
    super.initState();

    _temperatureRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        _temperatures.add((event.snapshot.value as double?) ?? 0.0);
      });
    });

    _pressureRef.onValue.listen((DatabaseEvent event) {
      setState(() {
        _pressures.add((event.snapshot.value as double?) ?? 0.0);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'Inicio',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Expanded(
            flex: 3,
            child: Padding(
              padding: EdgeInsets.all(8.0),
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: _temperatures.length.toDouble(),
                  minY: 0,
                  maxY: 100,
                  titlesData: FlTitlesData(
                    leftTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTextStyles: (value, _) => const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      margin: 8,
                    ),
                    bottomTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 30,
                      getTextStyles: (value, _) => const TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                      ),
                      margin: 8,
                    ),
                  ),
                  borderData: FlBorderData(
                    show: true,
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: _temperatures.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      colors: [Colors.blue],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                    LineChartBarData(
                      spots: _pressures.asMap().entries.map((entry) {
                        return FlSpot(entry.key.toDouble(), entry.value);
                      }).toList(),
                      isCurved: true,
                      colors: [Colors.red],
                      barWidth: 4,
                      isStrokeCapRound: true,
                      belowBarData: BarAreaData(
                        show: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Text(
                  'Temperature: ${_temperatures.isNotEmpty ? _temperatures.last.toStringAsFixed(2) : ''}',
                  style: TextStyle(fontSize: 20),
                ),
                SizedBox(height: 10),
                Text(
                  'Pressure: ${_pressures.isNotEmpty ? _pressures.last.toStringAsFixed(2) : ''}',
                  style: TextStyle(fontSize: 20),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
