import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pet_provider.dart';
import 'package:intl/intl.dart'; // 需要在 pubspec.yaml 添加 intl 依赖

class LogPage extends StatefulWidget {
  const LogPage({super.key});

  @override
  State<LogPage> createState() => _LogPageState();
}

class _LogPageState extends State<LogPage> {
  @override
  void initState() {
    super.initState();
    // 页面加载时获取日志
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchLogs(); // 需在 Provider 中实现 fetchLogs
    });
  }

  String _formatTime(String? isoString) {
    if (isoString == null) return "";
    try {
      final date = DateTime.parse(isoString).toLocal();
      return DateFormat('HH:mm:ss').format(date);
    } catch (e) {
      return isoString;
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("行为日志")),
      body: provider.logs.isEmpty
          ? const Center(child: Text("暂无记录"))
          : ListView.builder(
              itemCount: provider.logs.length,
              itemBuilder: (context, index) {
                final log = provider.logs[index];
                return ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(log['action'] ?? "未知操作"),
                  subtitle: Text(log['result'] ?? ""),
                  trailing: Text(
                    _formatTime(log['timestamp']),
                    style: const TextStyle(color: Colors.grey),
                  ),
                );
              },
            ),
    );
  }
}