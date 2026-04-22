import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_debug_kit/flutter_debug_kit.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DebugProxy.enableFromSystem();
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _status = '未请求';

  Future<void> _ping() async {
    setState(() => _status = '请求中...');
    try {
      final client = HttpClient();
      final req = await client.getUrl(Uri.parse('https://example.com'));
      final resp = await req.close();
      setState(() => _status = 'HTTP ${resp.statusCode}，代理态: ${DebugProxy.isActive}');
      client.close(force: true);
    } catch (e) {
      setState(() => _status = '失败: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('flutter_debug_kit example')),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('isActive: ${DebugProxy.isActive}'),
              const SizedBox(height: 16),
              ElevatedButton(onPressed: _ping, child: const Text('GET https://example.com')),
              const SizedBox(height: 16),
              Text(_status),
            ],
          ),
        ),
      ),
    );
  }
}
