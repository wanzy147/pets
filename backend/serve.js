const express = require('express');
const cors = require('cors');
const bodyParser = require('body-parser');

const app = express();
const PORT = 3000;

app.use(cors());
app.use(bodyParser.json());

// 内存存储状态 
let petState = {
    mood: "开心",
    energy: 80,
    hunger: 20,
    lastUpdated: new Date().toISOString()
};

// 内存日志 (最多保留20条) [cite: 24]
let logs = [];

// Helper: 添加日志
const addLog = (action, result) => {
    const newLog = { action, result, timestamp: new Date().toISOString() };
    logs.unshift(newLog); // 最新在最前
    if (logs.length > 20) logs.pop();
};

// GET /pet - 获取状态
app.get('/pet', (req, res) => {
    res.json(petState);
});

// POST /pet/action - 执行动作
app.post('/pet/action', (req, res) => {
    const { action } = req.body;
    let resultText = "";

    // 简单的游戏逻辑
    switch (action) {
        case 'feed':
            petState.hunger = Math.max(0, petState.hunger - 20);
            petState.energy = Math.min(100, petState.energy + 5);
            petState.mood = "饱饱的";
            resultText = "宠物吃得很开心！";
            break;
        case 'play':
            petState.energy = Math.max(0, petState.energy - 15);
            petState.hunger = Math.min(100, petState.hunger + 10);
            petState.mood = "兴奋";
            resultText = "宠物玩得满头大汗！";
            break;
        case 'sleep':
            petState.energy = 100;
            petState.mood = "困倦";
            resultText = "宠物睡了一大觉。";
            break;
        case 'dance':
            petState.hunger = Math.min(100, petState.hunger + 15);
            petState.mood = "开心";
            resultText = "宠物跳了一支魔性的舞！";
            break;
        default:
            return res.status(400).json({ error: "未知动作" });
    }

    
    if (petState.hunger >= 80) {
        petState.mood = "饥饿";
    } else if (petState.energy <= 20) {
        petState.mood = "困倦";
    }

    petState.lastUpdated = new Date().toISOString();
    addLog(action, resultText);

    res.json({ state: petState, message: resultText });
});

// GET /pet/log - 获取日志
app.get('/pet/log', (req, res) => {
    res.json(logs);
});

app.listen(PORT, () => {
    console.log(`Server running at http://localhost:${PORT}`);
});
