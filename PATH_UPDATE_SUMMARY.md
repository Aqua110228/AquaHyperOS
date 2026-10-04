# ✅ 日志路径已更新

## 新路径

```
/sdcard/AquaHyperOS/logs/aqua_YYYYMMDD.log
```

### 变更说明

**之前：** `/sdcard/AquaHyperOS/aqua_20241003.log`  
**现在：** `/sdcard/AquaHyperOS/logs/aqua_20241003.log`

---

## 自动创建

- ✅ 如果 `/sdcard/AquaHyperOS/logs/` 不存在，会自动创建
- ✅ 创建失败会记录到 Xposed 日志
- ✅ 无需手动操作

---

## 查看日志

### 方法 1: adb
```bash
# 实时查看
adb logcat | grep "AquaHyperOS"

# 拉取日志文件
adb pull /sdcard/AquaHyperOS/logs/aqua_$(date +%Y%m%d).log

# 查看日志内容
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log

# 查看最新 100 行
adb shell tail -n 100 /sdcard/AquaHyperOS/logs/aqua_*.log

# 只看错误
adb shell grep "\[错误\]" /sdcard/AquaHyperOS/logs/aqua_*.log
```

### 方法 2: MT 管理器
```
1. 打开 MT 管理器
2. 导航到 /sdcard/AquaHyperOS/logs/
3. 打开 aqua_日期.log 文件
```

### 方法 3: 文件管理器
```
内部存储 → AquaHyperOS → logs → aqua_日期.log
```

---

## 已更新的文件

1. ✅ **module/utils/Logger.kt**
   - 日志目录改为 `AquaHyperOS/logs`
   - 添加创建失败检测

2. ✅ **LOG_SYSTEM_GUIDE.md**
   - 所有路径已更新
   - 添加自动创建说明

---

## 测试

```bash
# 检查日志目录是否存在
adb shell ls -la /sdcard/AquaHyperOS/

# 检查日志文件
adb shell ls -la /sdcard/AquaHyperOS/logs/

# 查看日志内容
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log | head -20
```

---

完成！日志现在会保存到 `/sdcard/AquaHyperOS/logs/` 目录 🎉
