
import 'package:flutter/material.dart';
import '../services/mqtt_service.dart';
import '../utils/constants.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final MqttService mqtt = MqttService.instance;

  @override
  void initState() {
    super.initState();
    mqtt.addListener(_updateDashboard);

    if (!mqtt.isConnected && !mqtt.isConnecting) {
      mqtt.connect();
    }
  }

  void _updateDashboard() {
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void dispose() {
    mqtt.removeListener(_updateDashboard);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final air = mqtt.getData('bebek/sensor/air');
    final pakan = mqtt.getData('bebek/sensor/pakan');
    final pompa = mqtt.getData('bebek/status/pompa');
    final servo = mqtt.getData('bebek/status/servo');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard Duckfullness'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Icon(
              Icons.circle,
              size: 12,
              color: mqtt.isConnected ? Colors.green : Colors.red,
            ),
          ),
        ],
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Monitoring Kandang',
              style: Theme.of(context).textTheme.titleLarge,
            ),

            const SizedBox(height: 8),

            Text(
              mqtt.connectionMessage,
              style: TextStyle(
                color: mqtt.isConnected ? Colors.green : Colors.red,
              ),
            ),

            const SizedBox(height: 24),

            // Monitoring sensor air
            _sensorCard(
              title: 'Ketinggian Air',
              value: air == '-' ? '-' : '$air',
              icon: Icons.water_drop,
            ),

            const SizedBox(height: 16),

            // Monitoring berat pakan
            _sensorCard(
              title: 'Berat Pakan',
              value: pakan == '-' ? '-' : '$pakan kg',
              icon: Icons.scale,
            ),

            const SizedBox(height: 24),

            const Text(
              'Kontrol Perangkat',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 16),

            // Kontrol pompa
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Pompa Air',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text('Status: $pompa'),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: mqtt.isConnected
                                ? () => mqtt.controlPump(true)
                                : null,
                            child: const Text('ON'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: mqtt.isConnected
                                ? () => mqtt.controlPump(false)
                                : null,
                            child: const Text('OFF'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Kontrol servo
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Servo Pakan',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 8),

                    Text('Status: $servo'),

                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: mqtt.isConnected
                                ? () => mqtt.controlServo(true)
                                : null,
                            child: const Text('BUKA'),
                          ),
                        ),

                        const SizedBox(width: 12),

                        Expanded(
                          child: ElevatedButton(
                            onPressed: mqtt.isConnected
                                ? () => mqtt.controlServo(false)
                                : null,
                            child: const Text('TUTUP'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: mqtt.isConnected
                    ? mqtt.disconnect
                    : mqtt.connect,
                child: Text(
                  mqtt.isConnected
                      ? 'Putuskan MQTT'
                      : 'Hubungkan MQTT',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sensorCard({
    required String title,
    required String value,
    required IconData icon,
  }) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Icon(
              icon,
              size: 35,
              color: AppColors.primaryDark,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
