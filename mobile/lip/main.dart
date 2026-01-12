import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'pet_provider.dart';
import 'log_page.dart'; // 假设你把日志页分开了

void main() {
  runApp(
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => PetProvider())],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pocket Pet',
      theme: ThemeData(primarySwatch: Colors.blue, useMaterial3: true),
      home: const PetHomePage(),
    );
  }
}

class PetHomePage extends StatefulWidget {
  const PetHomePage({super.key});

  @override
  State<PetHomePage> createState() => _PetHomePageState();
}

class _PetHomePageState extends State<PetHomePage> {
  @override
  void initState() {
    super.initState();
    // 初始加载
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPetState();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PetProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text("Pocket Pet Controller")),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const LogPage()),
        ),
        child: const Icon(Icons.history), // 跳转日志页
      ),
      body: RefreshIndicator( // 下拉刷新 [cite: 35]
        onRefresh: () => provider.fetchPetState(),
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (provider.errorMessage != null)
                  Container(
                    color: Colors.red.shade100,
                    padding: const EdgeInsets.all(8),
                    child: Row(
                      children: [
                        Expanded(child: Text(provider.errorMessage!)),
                        TextButton(
                            onPressed: () => provider.fetchPetState(),
                            child: const Text("重试")) // 重试按钮 [cite: 40]
                      ],
                    ),
                  ),
                
                // 状态展示卡片
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text("心情: ${provider.petState['mood']}", 
                            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 20),
                        _buildProgressBar("精力", provider.petState['energy']),
                        const SizedBox(height: 10),
                        _buildProgressBar("饥饿", provider.petState['hunger']),
                        const SizedBox(height: 20),
                        Text("最后更新: ${provider.petState['lastUpdated']}",
                            style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 动作按钮区域 [cite: 12]
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  alignment: WrapAlignment.center,
                  children: [
                    _actionButton(context, "feed", Icons.fastfood, "喂食"),
                    _actionButton(context, "play", Icons.sports_esports, "玩耍"),
                    _actionButton(context, "sleep", Icons.bed, "睡觉"),
                    _actionButton(context, "dance", Icons.music_note, "跳舞"),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar(String label, int value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("$label: $value/100"),
        LinearProgressIndicator(value: value / 100.0, minHeight: 10),
      ],
    );
  }

  Widget _actionButton(BuildContext context, String actionKey, IconData icon, String label) {
    return ElevatedButton.icon(
      onPressed: () => Provider.of<PetProvider>(context, listen: false).performAction(actionKey),
      icon: Icon(icon),
      label: Text(label),
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(20)),
    );
  }
}
