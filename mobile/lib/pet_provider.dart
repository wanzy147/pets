import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

// 注意：Android 模拟器必须使用 10.0.2.2，不能用 localhost
const String API_BASE_URL = "http://10.0.2.2:3000"; 

class PetProvider with ChangeNotifier {
  Map<String, dynamic> _petState = {
    "mood": "加载中...",
    "energy": 0,
    "hunger": 0,
    "lastUpdated": ""
  };
  List<dynamic> _logs = [];
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, dynamic> get petState => _petState;
  List<dynamic> get logs => _logs;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

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
      _errorMessage = "你的宠物现在听不到你 (后端离线)";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> performAction(String action) async {
    final oldState = Map<String, dynamic>.from(_petState);
    
    // 乐观更新
    if (action == 'feed') {
      _petState['hunger'] = (_petState['hunger'] - 20).clamp(0, 100);
      _petState['energy'] = (_petState['energy'] + 5).clamp(0, 100);
    } else if (action == 'play') {
       _petState['energy'] = (_petState['energy'] - 15).clamp(0, 100);
    }
    notifyListeners(); 

    try {
      final response = await http.post(
        Uri.parse('$API_BASE_URL/pet/action'),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"action": action}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        _petState = data['state'];
      } else {
        throw Exception("Failed");
      }
    } catch (e) {
      _petState = oldState;
      _errorMessage = "操作未能确认，请重试"; 
    }
    notifyListeners();
  }

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
