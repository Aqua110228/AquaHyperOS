# 🎯 真正内置设置入口 - Settings.apk 修改方案

## 问题说明

当前实现的问题：
- 设置入口通过 Hook 注入
- 需要 LSPosed 激活才能显示
- 未激活时看不到入口

---

## 解决方案：修改 Settings.apk

### 原理

直接在 Settings.apk 中添加我们的入口，不需要 Hook。

---

## 📋 实施步骤

### 步骤 1: 反编译 Settings.apk

```bash
# 从官改 ROM 提取 Settings.apk
adb pull /system/priv-app/Settings/Settings.apk

# 反编译
apktool d Settings.apk -o Settings_src
```

### 步骤 2: 找到设置列表

```bash
# 查找主设置布局
cd Settings_src
find . -name "*dashboard*" -type f
find . -name "*preference*" -type f

# 通常在这些位置：
# res/xml/dashboard_main.xml
# res/xml/top_level_settings.xml
```

### 步骤 3: 添加我们的入口

编辑 `res/xml/dashboard_main.xml` (或 `top_level_settings.xml`)：

```xml
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen
    xmlns:android="http://schemas.android.com/apk/res/android"
    xmlns:settings="http://schemas.android.com/apk/res-auto">
    
    <!-- 添加我们的入口 (放在最前面) -->
    <Preference
        android:key="aqua_hyperos_settings"
        android:title="AquaHyperOS"
        android:summary="HyperOS 深度定制模块"
        android:order="0">
        <intent
            android:targetPackage="com.aqua.hyperos"
            android:targetClass="com.aqua.hyperos.ui.SettingsActivity" />
    </Preference>
    
    <!-- 原有的设置项 -->
    <Preference ...>
    ...
```

### 步骤 4: 添加图标（可选）

```bash
# 如果有图标
cp ic_aqua.png Settings_src/res/drawable/

# 在 Preference 中引用
android:icon="@drawable/ic_aqua"
```

### 步骤 5: 重新打包

```bash
# 编译
apktool b Settings_src -o Settings_modified.apk

# 对齐
zipalign -v 4 Settings_modified.apk Settings_aligned.apk

# 签名（使用官改的 platform 密钥）
apksigner sign --ks platform.keystore Settings_aligned.apk
```

### 步骤 6: 替换到 ROM

```bash
# 挂载 system
mount -o loop system.img system_mount/

# 替换 Settings.apk
cp Settings_aligned.apk system_mount/priv-app/Settings/Settings.apk

# 设置权限
chmod 644 system_mount/priv-app/Settings/Settings.apk
chown root:root system_mount/priv-app/Settings/Settings.apk

# 卸载
umount system_mount/
```

---

## 📊 对比

| 方案 | 桌面图标 | 设置入口(未激活LSP) | 设置入口(已激活LSP) |
|------|----------|---------------------|---------------------|
| **当前方案** | ✅ 有 | ❌ 无 | ✅ 有 |
| **修改Settings** | ✅ 有 | ✅ 有 | ✅ 有 |

---

## 🎯 推荐方案

### 方案 1: 只修改 Settings.apk（最简单）

**优点**：
- ✅ 入口永远可见
- ✅ 不需要 Hook
- ✅ 不需要 LSPosed（仅入口）

**缺点**：
- ⚠️ 需要修改系统 APK
- ⚠️ 功能仍需 LSPosed

**适合**：
- 想要入口始终可见
- 不介意修改 Settings.apk

### 方案 2: 当前方案（保持不动）

**优点**：
- ✅ 不修改系统 APK
- ✅ 有桌面图标作为替代

**缺点**：
- ⚠️ 设置入口需要激活 LSPosed

**适合**：
- 不想修改系统 APK
- 桌面图标足够

### 方案 3: 混合方案（推荐）⭐

**做法**：
1. 修改 Settings.apk 添加入口
2. 入口始终可见
3. 但显示状态提示

```xml
<Preference
    android:title="AquaHyperOS"
    android:summary="深度定制模块 (需要 LSPosed)" />
```

**优点**：
- ✅ 入口始终可见
- ✅ 提示清晰
- ✅ 用户体验好

---

## 🤔 你想要哪种方案？

**选项 A**: 修改 Settings.apk，入口永远可见
**选项 B**: 保持当前，只用桌面图标
**选项 C**: 两个都做，提供完整体验

告诉我，我立即实施！
