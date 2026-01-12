import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 根据文档，Android模拟器需使用 10.0.2.2 
const String API_BASE_URL = "http://10.0.2.2:3000"; 

class PetProvider with ChangeNotifier {
  // 状态变量
  Map<String, dynamic> _petState = {
    "mood": "加载中...",
    "energy": 0,
    "hunger": 0,
    "lastUpdated": ""
  };
  List<dynamic> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  Map<String, dynamic> get petState => _petState;
  List<dynamic> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // 获取状态 (支持下拉刷新) [cite: 35]
  Future<void> fetchPetState() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/pet'));
      if (response.statusCode == 200) {
        _petState = json.decode(response.body);
      } else {
        _errorMessage = "服务器错误";
      }
    } catch (e) {
      _errorMessage = "你的宠物现在听不到你 (后端离线)"; // [cite: 42]
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 乐观更新动作 
  Future<void> performAction(String action) async {
    // 1. 保存旧状态用于回滚
    final oldState = Map<String, dynamic>.from(_petState);
    
    // 2. 乐观更新：立即在界面上反应 (模拟逻辑)
    if (action == 'feed') {
      _petState['hunger'] = (_petState['hunger'] - 20).clamp(0, 100);
      _petState['energy'] = (_petState['energy'] + 5).clamp(0, 100);
    } else if (action == 'play') {
       _petState['energy'] = (_petState['energy'] - 15).clamp(0, 100);
    }
    // ... 其他动作的简单模拟
    
    notifyListeners(); // 立即刷新UI

    // 3. 发送真实请求
    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/pet/action'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": action}),
      );

      if (response.statusCode == 200) {
        // 请求成功：使用后端返回的最新准确数据覆盖
        final data = json.decode(response.body);
        _petState = data['state'];
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      // 4. 请求失败：回滚状态并报错 [cite: 40]
      _petState = oldState;
      _errorMessage = "操作未能确认，请重试"; 
    }
    notifyListeners();
  }
  
  // 获取日志
  // 在 pet_provider.dart 中找到 fetchLogs 并替换为：
  Future<void> fetchLogs() async {
    try {
      final response = await http.get(Uri.parse('$API_BASE_URL/pet/log'));
      if (response.statusCode == 200) {
        _logs = json.decode(response.body);
        notifyListeners();
      }
    } catch (e) {
      print("获取日志失败: $e");
    }
  }
}