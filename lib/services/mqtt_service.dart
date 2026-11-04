import 'dart:convert';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';

class MqttService {
  // =====================================
  // KONFIGURASI HIVEMQ
  // =====================================

  final String host = 'broker.hivemq.com';
  final int port = 8000;
  final String path = '/mqtt';

  // =====================================
  // MQTT TOPIC
  // =====================================

  final String topicAir =
      'peternakanbebek/irwansyah/air';

  final String topicPakan =
      'peternakanbebek/irwansyah/pakan';

  final String topicPompa =
      'peternakanbebek/irwansyah/pompa';

  final String topicServo =
      'peternakanbebek/irwansyah/servo';

  late MqttServerClient client;

  bool terhubung = false;
  String status = 'Menghubungkan...';

  // =====================================
  // DATA SENSOR
  // =====================================

  double persentaseAir = 0;
  int nilaiAir = 0;

  double beratPakan = 0;
  bool hx711Siap = false;

  String statusPompa = '-';
  String statusServo = '-';

  Function()? onDataChanged;
  Function(String)? onStatusChanged;

  // =====================================
  // KONEKSI MQTT
  // =====================================

  Future<void> connect() async {
    final clientId =
        'Dashboard-${DateTime.now().millisecondsSinceEpoch}';

    client = MqttServerClient.withPort(
      host,
      clientId,
      port,
    );

    client.useWebSocket = true;
    client.keepAlivePeriod = 30;
    client.logging(on: false);

    client.onConnected = () {
      terhubung = true;
      status = 'Terhubung ke HiveMQ';
      onStatusChanged?.call(status);
    };

    client.onDisconnected = () {
      terhubung = false;
      status = 'Koneksi terputus';
      onStatusChanged?.call(status);
    };

    client.connectionMessage =
        MqttConnectMessage()
            .withClientIdentifier(clientId)
            .startClean();

    try {
      await client.connect();

      if (client.connectionStatus?.state ==
          MqttConnectionState.connected) {
        terhubung = true;
        status = 'Terhubung ke HiveMQ';

        onStatusChanged?.call(status);

        subscribeTopics();
      } else {
        terhubung = false;
        status = 'Gagal terhubung';
        onStatusChanged?.call(status);
        client.disconnect();
      }
    } catch (e) {
      terhubung = false;
      status = 'Gagal terhubung: $e';
      onStatusChanged?.call(status);
      client.disconnect();
    }
  }

  // =====================================
  // SUBSCRIBE TOPIC
  // =====================================

  void subscribeTopics() {
    client.subscribe(topicAir, MqttQos.atMostOnce);
    client.subscribe(topicPakan, MqttQos.atMostOnce);
    client.subscribe(topicPompa, MqttQos.atMostOnce);
    client.subscribe(topicServo, MqttQos.atMostOnce);

    client.updates?.listen((messages) {
      for (final message in messages) {
        final topic = message.topic;

        final payload =
            message.payload as MqttPublishMessage;

        final data =
            MqttPublishPayload.bytesToStringAsString(
          payload.payload.message,
        );

        print('$topic : $data');

        // DATA WATER LEVEL
        if (topic == topicAir) {
          try {
            final air = jsonDecode(data);

            persentaseAir =
                (air['persentase'] as num).toDouble();

            nilaiAir =
                (air['nilai'] as num).toInt();
          } catch (e) {
            print('Error data air: $e');
          }
        }

        // DATA LOAD CELL
        else if (topic == topicPakan) {
          try {
            final pakan = jsonDecode(data);

            beratPakan =
                (pakan['berat'] as num).toDouble();

            hx711Siap = pakan['hx711Siap'] == true;
          } catch (e) {
            print('Error data pakan: $e');
          }
        }

        // STATUS WATER PUMP
        else if (topic == topicPompa) {
          statusPompa = data;
        }

        // STATUS SERVO
        else if (topic == topicServo) {
          statusServo = data;
        }

        onDataChanged?.call();
      }
    });
  }

  // =====================================
  // PUBLISH DATA / PERINTAH
  // =====================================

  void publish(String topic, String data) {
    if (!terhubung) {
      print('MQTT belum terhubung');
      return;
    }

    final builder = MqttClientPayloadBuilder();
    builder.addString(data);

    client.publishMessage(
      topic,
      MqttQos.atMostOnce,
      builder.payload!,
    );
  }

  // KONTROL POMPA
  void kontrolPompa(bool nyala) {
    publish(
      topicPompa,
      nyala ? 'ON' : 'OFF',
    );
  }

  // KONTROL SERVO
  void kontrolServo(bool buka) {
    publish(
      topicServo,
      buka ? 'OPEN' : 'CLOSE',
    );
  }

  // =====================================
  // DISCONNECT
  // =====================================

  void disconnect() {
    if (terhubung) {
      client.disconnect();
      terhubung = false;
    }
  }
}