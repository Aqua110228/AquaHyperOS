# 📦 导入官改包到 AquaHyperOS 模块

## 准备工作

### 需要的工具
- ✅ Android SDK Platform Tools (adb)
- ✅ MT 管理器 或 其他文件管理器
- ✅ Root 权限
- ✅ LSPosed 框架

---

## 方法一：通过 adb 导入（推荐）

### 1. 提取官改包

```bash
# 连接设备
adb devices

# 查找官改包位置
adb shell pm path com.android.systemui
adb shell pm path com.android.settings
adb shell pm path com.miui.home

# 示例输出：
# package:/system/system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk
# package:/system/priv-app/Settings/Settings.apk
# package:/product/priv-app/MiuiHome/MiuiHome.apk
```

### 2. 拉取到电脑

```bash
# 创建目录
mkdir -p ~/official_rom_apks

# 拉取 APK
adb pull /system/system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk ~/official_rom_apks/
adb pull /system/priv-app/Settings/Settings.apk ~/official_rom_apks/
adb pull /product/priv-app/MiuiHome/MiuiHome.apk ~/official_rom_apks/

# 如果上面的路径不对，用实际路径替换
```

### 3. 复制到工作区

```bash
# 如果在本地
cp ~/official_rom_apks/*.apk ~/workspace/apk_analysis/

# 如果用 AiCode，通过文件管理器上传
# 或者用 adb 直接推送到设备
```

---

## 方法二：直接在设备上提取

### 1. 使用 MT 管理器

1. 打开 MT 管理器
2. 获取 Root 权限
3. 导航到以下目录：
   ```
   /system/system_ext/priv-app/MiuiSystemUI/
   /system/priv-app/Settings/
   /product/priv-app/MiuiHome/
   /system_ext/priv-app/MiSettings/
   ```
4. 长按 APK 文件 → 复制
5. 粘贴到 `/sdcard/Download/` 或其他可访问位置

### 2. 上传到 AiCode

1. 在 AiCode 中打开文件管理器
2. 导航到 `~/workspace/.aicode/attachments/`
3. 从设备存储中选择提取的 APK
4. 上传

---

## 方法三：使用脚本自动提取

创建一个自动化脚本：

```bash
#!/bin/bash
# extract_official_apks.sh

DEST_DIR="official_apks"
mkdir -p "$DEST_DIR"

echo "📦 提取官改 APK..."

# 提取 SystemUI
SYSTEMUI_PATH=$(adb shell pm path com.android.systemui | cut -d: -f2 | tr -d '\r')
if [ -n "$SYSTEMUI_PATH" ]; then
    echo "提取 SystemUI: $SYSTEMUI_PATH"
    adb pull "$SYSTEMUI_PATH" "$DEST_DIR/SystemUI.apk"
fi

# 提取 Settings
SETTINGS_PATH=$(adb shell pm path com.android.settings | cut -d: -f2 | tr -d '\r')
if [ -n "$SETTINGS_PATH" ]; then
    echo "提取 Settings: $SETTINGS_PATH"
    adb pull "$SETTINGS_PATH" "$DEST_DIR/Settings.apk"
fi

# 提取 MiuiHome
HOME_PATH=$(adb shell pm path com.miui.home | cut -d: -f2 | tr -d '\r')
if [ -n "$HOME_PATH" ]; then
    echo "提取 MiuiHome: $HOME_PATH"
    adb pull "$HOME_PATH" "$DEST_DIR/MiuiHome.apk"
fi

# 提取 MiSettings
MISETTINGS_PATH=$(adb shell pm path com.xiaomi.misettings | cut -d: -f2 | tr -d '\r')
if [ -n "$MISETTINGS_PATH" ]; then
    echo "提取 MiSettings: $MISETTINGS_PATH"
    adb pull "$MISETTINGS_PATH" "$DEST_DIR/MiSettings.apk"
fi

echo "✅ 提取完成！文件保存在: $DEST_DIR/"
ls -lh "$DEST_DIR/"
```

使用方法：
```bash
chmod +x extract_official_apks.sh
./extract_official_apks.sh
```

---

## 分析官改包

### 1. 解压 APK

```bash
cd ~/workspace
mkdir -p apk_analysis/official_systemui
unzip -q official_apks/SystemUI.apk -d apk_analysis/official_systemui/
```

### 2. 查找 DEX 文件

```bash
cd apk_analysis/official_systemui
find . -name "*.dex"
```

### 3. 提取类名

```bash
# 查找关键类
for dex in *.dex; do
    strings "$dex" | grep "Lcom/android/systemui" | grep -i "statusbar\|tile\|blur"
done | sort -u
```

---

## 常见问题

### Q1: 提示"没有权限"
```bash
# 确保设备已 Root
adb shell su -c "ls /system"

# 重新挂载为可读
adb shell su -c "mount -o remount,rw /system"
```

### Q2: 找不到 APK 路径
```bash
# 手动查找
adb shell su -c "find /system -name '*SystemUI*.apk'"
adb shell su -c "find /product -name '*Settings*.apk'"
```

### Q3: APK 太大无法传输
```bash
# 分片传输或压缩
adb shell su -c "gzip /system/path/to/app.apk"
adb pull /system/path/to/app.apk.gz
gunzip app.apk.gz
```

---

## 针对不同设备

### 小米/Redmi 手机
```bash
# SystemUI 可能在
/system/system_ext/priv-app/MiuiSystemUI/
/system_ext/priv-app/MiuiSystemUI/

# Settings 可能在
/system/priv-app/Settings/
/system/app/Settings/
```

### 小米平板
```bash
# 可能有平板专用版本
/system/priv-app/MiuiSystemUIPad/
/product/priv-app/MiuiHomePad/
```

### HyperOS 2.0
```bash
# 新位置可能不同
adb shell pm list packages -f | grep systemui
adb shell pm list packages -f | grep settings
```

---

## 快速命令参考

```bash
# 列出所有系统应用
adb shell pm list packages -s

# 查看应用路径
adb shell pm path <package_name>

# 批量提取
adb shell pm list packages -s | cut -d: -f2 | while read pkg; do
    adb shell pm path "$pkg"
done

# 查看 APK 信息
adb shell dumpsys package <package_name>
```

---

## 验证提取成功

```bash
# 检查文件大小
ls -lh ~/official_apks/*.apk

# 查看 APK 信息
aapt dump badging SystemUI.apk | grep package
unzip -l SystemUI.apk | grep classes.dex
```

---

## 下一步

提取完成后：
1. 使用我之前的分析工具分析 APK
2. 查找需要的类名和方法
3. 更新 Hook 代码中的类名
4. 测试功能

---

## 完整示例

```bash
# 1. 连接设备
adb devices

# 2. 查找路径
SYSTEMUI=$(adb shell pm path com.android.systemui | cut -d: -f2 | tr -d '\r')
echo "SystemUI 路径: $SYSTEMUI"

# 3. 提取
mkdir -p official_apks
adb pull "$SYSTEMUI" official_apks/SystemUI.apk

# 4. 验证
ls -lh official_apks/SystemUI.apk

# 5. 解压
unzip -q official_apks/SystemUI.apk -d official_apks/systemui_extracted

# 6. 查找 DEX
find official_apks/systemui_extracted -name "*.dex"

# 7. 提取类名
strings official_apks/systemui_extracted/classes.dex | grep "Lcom/android/systemui" > systemui_classes.txt

echo "✅ 完成！类名已保存到 systemui_classes.txt"
```

---

**需要帮助？**
- 如果遇到问题，提供你的设备型号和 HyperOS 版本
- 贴上错误信息
- 我会帮你定制命令

准备好了吗？需要我帮你执行提取吗？
