import 'package:flutter/material.dart';
import 'dart:math' as math;

class PetWidget extends StatefulWidget {
  final String mood; // 从后端获取的心情
  final Function(PetController) onControllerCreated; // 让父组件能控制它

  const PetWidget({
    super.key,
    required this.mood,
    required this.onControllerCreated,
  });

  @override
  State<PetWidget> createState() => _PetWidgetState();
}

// 定义一个控制器，让外部能触发动画
class PetController {
  late void Function(String) triggerAction;
}

class _PetWidgetState extends State<PetWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  String _currentAction = 'idle'; // 当前正在做的动作

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    // 初始化控制器，把触发函数暴露给父组件
    final controller = PetController();
    controller.triggerAction = _triggerAnimation;
    widget.onControllerCreated(controller);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // 触发动画的核心逻辑
  void _triggerAnimation(String action) {
    setState(() {
      _currentAction = action;
    });

    _controller.reset();
    
    // 睡觉动画需要慢一点，且循环
    if (action == 'sleep') {
      _controller.duration = const Duration(seconds: 2);
      _controller.repeat(reverse: true); 
    } else {
      // 其他动作快一点，做完一次就停
      _controller.duration = const Duration(milliseconds: 600);
      _controller.forward().then((_) {
        // 动画结束后，延迟一会儿回到发呆状态
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted && _currentAction != 'sleep') {
            setState(() {
              _currentAction = 'idle';
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // 1. 根据心情或动作决定显示什么图标/表情
    IconData iconData;
    Color color;

    // 优先显示动作中的状态
    switch (_currentAction) {
      case 'feed':
        iconData = Icons.restaurant;
        color = Colors.orange;
        break;
      case 'play':
        iconData = Icons.sports_soccer;
        color = Colors.green;
        break;
      case 'dance':
        iconData = Icons.music_note;
        color = Colors.purple;
        break;
      case 'sleep':
        iconData = Icons.bedtime;
        color = Colors.indigo;
        break;
      default:
        // 如果没有动作，根据后端的心情 mood 显示
        // (后端返回: "开心", "困倦", "饥饿", "兴奋", "饱饱的")
        if (widget.mood.contains("开心") || widget.mood.contains("兴奋")) {
          iconData = Icons.sentiment_very_satisfied;
          color = Colors.amber;
        } else if (widget.mood.contains("困倦")) {
          iconData = Icons.sentiment_dissatisfied;
          color = Colors.blueGrey;
        } else if (widget.mood.contains("饥饿")) {
          iconData = Icons.sentiment_neutral;
          color = Colors.redAccent;
        } else {
          iconData = Icons.pets; // 默认
          color = Colors.blue;
        }
    }

    // 2. 构建动画
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        Widget transformChild = Icon(iconData, size: 120, color: color);

        switch (_currentAction) {
          case 'feed':
            // 缩放动画 (弹一下: 1.0 -> 1.5 -> 1.0)
            final scale = 1.0 + (_controller.value < 0.5 ? _controller.value : (1.0 - _controller.value));
            return Transform.scale(scale: scale, child: transformChild);
          
          case 'play':
            // 摇晃动画 (左右旋转)
            final offset = math.sin(_controller.value * math.pi * 4) * 0.1;
            return Transform.rotate(angle: offset, child: transformChild);
            
          case 'dance':
            // 旋转动画 (转圈圈)
            return Transform.rotate(
              angle: _controller.value * 2 * math.pi, 
              child: transformChild
            );
            
          case 'sleep':
            // 呼吸动画 (透明度变化)
            return Opacity(
              opacity: 0.5 + (_controller.value * 0.5),
              child: Transform.scale(scale: 0.95 + (_controller.value * 0.05), child: transformChild),
            );
            
          default:
            return transformChild;
        }
      },
    );
  }
}
