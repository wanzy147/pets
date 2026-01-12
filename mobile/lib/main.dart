// 记得在文件头部添加引用:
import 'pet_widget.dart'; 

class _PetHomePageState extends State<PetHomePage> {
  // 新增：用于控制宠物的动画
  PetController? _petController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<PetProvider>(context, listen: false).fetchPetState();
    });
  }

  // 新增：处理动作点击
  void _handleAction(String action) {
    // 1. 触发 UI 动画 (视觉反馈)
    _petController?.triggerAction(action);
    
    // 2. 触发 业务逻辑 (网络请求)
    Provider.of<PetProvider>(context, listen: false).performAction(action);
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
        child: const Icon(Icons.history),
      ),
      body: RefreshIndicator(
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
                            child: const Text("重试"))
                      ],
                    ),
                  ),
                
                // ------------------------------------------------
                // 修改区域开始：使用新的 PetWidget 替换原来的 Card 文本
                // ------------------------------------------------
                const SizedBox(height: 20),
                Center(
                  child: PetWidget(
                    mood: provider.petState['mood'] ?? "开心", // 传入心情
                    onControllerCreated: (controller) {
                      _petController = controller; // 绑定控制器
                    },
                  ),
                ),
                const SizedBox(height: 30),
                // ------------------------------------------------
                // 修改区域结束
                // ------------------------------------------------

                // 状态数值卡片 (稍微简化一下显示，把图标移到了 PetWidget 里)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Text("当前心情: ${provider.petState['mood']}", 
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 20),
                        _buildProgressBar("精力 (Energy)", provider.petState['energy']),
                        const SizedBox(height: 10),
                        _buildProgressBar("饥饿 (Hunger)", provider.petState['hunger']),
                        const SizedBox(height: 20),
                        Text("Last Updated: ${provider.petState['lastUpdated']}",
                            style: const TextStyle(color: Colors.grey, fontSize: 10)),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: 30),
                
                // 动作按钮区域
                Wrap(
                  spacing: 15,
                  runSpacing: 15,
                  alignment: WrapAlignment.center,
                  children: [
                    // 注意：这里 onPressed 改成了 _handleAction
                    _actionButton("feed", Icons.fastfood, "喂食", Colors.orange),
                    _actionButton("play", Icons.sports_esports, "玩耍", Colors.green),
                    _actionButton("dance", Icons.music_note, "跳舞", Colors.purple),
                    _actionButton("sleep", Icons.bedtime, "睡觉", Colors.indigo),
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
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
            Text("$value/100"),
          ],
        ),
        const SizedBox(height: 5),
        LinearProgressIndicator(
          value: value / 100.0, 
          minHeight: 10,
          backgroundColor: Colors.grey.shade200,
          valueColor: AlwaysStoppedAnimation<Color>(
            value > 80 ? Colors.green : (value > 30 ? Colors.blue : Colors.red)
          ),
          borderRadius: BorderRadius.circular(5),
        ),
      ],
    );
  }

  Widget _actionButton(String actionKey, IconData icon, String label, Color color) {
    return SizedBox(
      width: 150, // 让按钮宽一点
      height: 50,
      child: ElevatedButton.icon(
        // 调用我们新的处理函数
        onPressed: () => _handleAction(actionKey),
        icon: Icon(icon, color: Colors.white),
        label: Text(label, style: const TextStyle(fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white, // 文字颜色
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }
}