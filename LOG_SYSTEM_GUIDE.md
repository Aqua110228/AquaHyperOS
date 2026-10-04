# 📋 日志系统使用指南

## 功能特性

✅ **自动记录所有 Hook 操作**  
✅ **保存到外部存储，方便查看**  
✅ **自动分级（V/D/I/W/E）**  
✅ **自动日志轮转（超过 5MB）**  
✅ **支持异常堆栈跟踪**

---

## 日志位置

### 日志文件路径
```
/sdcard/AquaHyperOS/aqua_YYYYMMDD.log
```

例如：`/sdcard/AquaHyperOS/aqua_20241003.log`

### 查看方法

#### 方法 1：MT 管理器
1. 打开 MT 管理器
2. 导航到 `/sdcard/AquaHyperOS/`
3. 打开 `.log` 文件

#### 方法 2：adb
```bash
# 查看实时日志
adb logcat | grep "AquaHyperOS"

# 拉取日志文件
adb pull /sdcard/AquaHyperOS/aqua_$(date +%Y%m%d).log

# 查看文件日志
adb shell cat /sdcard/AquaHyperOS/aqua_*.log
```

#### 方法 3：文件管理器
直接用任何文件管理器打开：
```
内部存储 → AquaHyperOS → aqua_日期.log
```

---

## 日志格式

```
[2024-10-03 14:30:25.123] [I] [StatusBar] Init
[2024-10-03 14:30:25.456] [D] [StatusBar] StatusBar hooked
[2024-10-03 14:30:25.789] [W] [Launcher] Key not found: workspace_rows
[2024-10-03 14:30:26.012] [E] [Core] Hook failed
[2024-10-03 14:30:26.013] [E] [Core] Exception: Class not found
[2024-10-03 14:30:26.014] [E] [Core] StackTrace: ...
```

**格式说明：**
- `[时间戳]` - 精确到毫秒
- `[级别]` - V(详细)/D(调试)/I(信息)/W(警告)/E(错误)
- `[模块]` - 哪个 Hook 模块
- `消息内容`

---

## 使用方法

### 在 Hook 代码中使用

所有 Hook 已自动集成日志：

```kotlin
import com.aqua.hyperos.utils.Logger

class YourHook : IXposedHookLoadPackage {
    companion object {
        private const val TAG = "YourModule"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        Logger.i(TAG, "Hook started")
        
        runCatching {
            // Your code
            Logger.d(TAG, "Operation successful")
        }.onFailure {
            Logger.e(TAG, "Operation failed", it)
        }
    }
}
```

### 日志级别

```kotlin
// Verbose - 详细信息（开发调试）
Logger.v("Module", "Detailed info")

// Debug - 调试信息
Logger.d("Module", "Debug info")

// Info - 一般信息
Logger.i("Module", "General info")

// Warning - 警告
Logger.w("Module", "Warning message")

// Error - 错误（带异常）
Logger.e("Module", "Error message", exception)
```

---

## 故障排查流程

### 1. 功能不工作时

```bash
# 查看最新日志
adb shell tail -n 100 /sdcard/AquaHyperOS/aqua_*.log

# 查找错误
adb shell grep "\\[E\\]" /sdcard/AquaHyperOS/aqua_*.log

# 查找特定模块
adb shell grep "StatusBar" /sdcard/AquaHyperOS/aqua_*.log
```

### 2. 查看模块是否加载

```bash
# 检查初始化日志
adb shell grep "Init" /sdcard/AquaHyperOS/aqua_*.log

# 应该看到：
[2024-10-03 14:30:25.123] [I] [Core] Init
[2024-10-03 14:30:25.234] [I] [StatusBar] Init
[2024-10-03 14:30:25.345] [I] [Launcher] Init
```

### 3. 查看 Hook 是否成功

```bash
# 检查 "hooked" 日志
adb shell grep "hooked" /sdcard/AquaHyperOS/aqua_*.log

# 应该看到：
[2024-10-03 14:30:25.456] [D] [StatusBar] StatusBar hooked
[2024-10-03 14:30:25.567] [D] [Launcher] Prefs hooked
```

### 4. 查找崩溃原因

```bash
# 查看异常堆栈
adb shell grep -A 20 "Exception" /sdcard/AquaHyperOS/aqua_*.log
```

---

## 日志管理

### 自动清理

日志文件超过 5MB 时自动轮转：
- 当前日志：`aqua_20241003.log`
- 旧日志：`aqua_20241003.log.old`

### 手动清理

```bash
# 删除旧日志
adb shell rm /sdcard/AquaHyperOS/*.log.old

# 清空当前日志
adb shell truncate -s 0 /sdcard/AquaHyperOS/aqua_*.log
```

---

## 导出日志给开发者

### 完整日志

```bash
# 导出到电脑
adb pull /sdcard/AquaHyperOS/ ./aqua_logs/

# 打包
cd aqua_logs
zip -r aqua_logs_$(date +%Y%m%d).zip *.log
```

### 最近 1000 行

```bash
adb shell tail -n 1000 /sdcard/AquaHyperOS/aqua_*.log > recent_logs.txt
```

### 只导出错误

```bash
adb shell grep "\\[E\\]" /sdcard/AquaHyperOS/aqua_*.log > errors_only.txt
```

---

## 常见问题

### Q: 日志文件为空？

**原因：**
- 没有存储权限
- 模块未正确加载

**解决：**
```bash
# 检查权限
adb shell ls -la /sdcard/AquaHyperOS/

# 手动创建目录
adb shell mkdir -p /sdcard/AquaHyperOS
adb shell chmod 777 /sdcard/AquaHyperOS
```

### Q: 看不到日志文件？

```bash
# 查找日志位置
adb shell find /sdcard -name "aqua_*.log"

# 检查是否正在写入
adb shell du -h /sdcard/AquaHyperOS/
```

### Q: 日志太多怎么过滤？

```bash
# 只看错误和警告
adb shell grep -E "\\[(E|W)\\]" /sdcard/AquaHyperOS/aqua_*.log

# 只看特定模块
adb shell grep "\\[Launcher\\]" /sdcard/AquaHyperOS/aqua_*.log

# 只看最近 5 分钟
adb shell grep "$(date +%Y-%m-%d\ %H:%M)" /sdcard/AquaHyperOS/aqua_*.log
```

---

## 实时监控

### 实时查看新日志

```bash
# Xposed 日志流
adb logcat | grep "AquaHyperOS"

# 文件日志流
adb shell tail -f /sdcard/AquaHyperOS/aqua_$(date +%Y%m%d).log
```

### 多窗口监控

```bash
# 终端 1 - Xposed 日志
adb logcat -c && adb logcat | grep "AquaHyperOS"

# 终端 2 - 文件日志
adb shell tail -f /sdcard/AquaHyperOS/aqua_*.log

# 终端 3 - 只看错误
adb shell tail -f /sdcard/AquaHyperOS/aqua_*.log | grep "\\[E\\]"
```

---

## 日志示例

### 正常启动

```
[2024-10-03 14:30:25.123] [I] [Logger] Initialized - /sdcard/AquaHyperOS/aqua_20241003.log
[2024-10-03 14:30:25.234] [I] [Core] Init core patches
[2024-10-03 14:30:25.345] [D] [Core] Signature patch applied
[2024-10-03 14:30:25.456] [D] [Core] Permission patch applied
[2024-10-03 14:30:25.567] [I] [Core] Core patches loaded
[2024-10-03 14:30:25.678] [I] [StatusBar] Init
[2024-10-03 14:30:25.789] [D] [StatusBar] StatusBar hooked
[2024-10-03 14:30:25.890] [I] [StatusBar] Loaded
```

### 出现错误

```
[2024-10-03 14:30:26.123] [I] [Launcher] Init (Rust-based launcher detected)
[2024-10-03 14:30:26.234] [D] [Launcher] Prefs hooked
[2024-10-03 14:30:26.345] [W] [Launcher] Key not found: workspace_rows
[2024-10-03 14:30:26.456] [E] [Launcher] Hook failed
[2024-10-03 14:30:26.457] [E] [Launcher] Exception: java.lang.ClassNotFoundException
[2024-10-03 14:30:26.458] [E] [Launcher] StackTrace:
    at com.aqua.hyperos.hooks.LauncherHook.hookPrefs(LauncherHook.kt:45)
    at com.aqua.hyperos.hooks.LauncherHook.handleLoadPackage(LauncherHook.kt:23)
    ...
```

---

## 提交 Bug 时

请提供：
1. ✅ 完整日志文件
2. ✅ 设备信息（型号、HyperOS 版本）
3. ✅ 问题描述（什么功能不工作）
4. ✅ 复现步骤

```bash
# 一键收集信息
adb shell getprop ro.product.model > bug_report.txt
adb shell getprop ro.miui.ui.version.name >> bug_report.txt
adb pull /sdcard/AquaHyperOS/aqua_$(date +%Y%m%d).log bug_report.txt
```

---

**现在你可以随时查看日志了！** 🎉

遇到问题就把日志发给我，我能立即定位问题！
