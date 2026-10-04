# 🎯 AquaHyperOS 最终集成指南（方案 A）

## 📦 需要的文件

打包后你会得到：
1. **AquaHyperOS.apk** - 主模块（无桌面图标）
2. **SETTINGS_XML_ENTRY.xml** - Settings.apk 入口配置
3. **aqua_permissions.xml** - 权限配置文件

---

## 🗂️ 集成到 ROM

### 文件放置位置

```
super.img
└── system/
    ├── priv-app/
    │   ├── AquaHyperOS/
    │   │   └── AquaHyperOS.apk          ← 放这里（推荐）
    │   └── Settings/
    │       └── Settings.apk              ← 需要修改
    ├── etc/
    │   └── permissions/
    │       └── com.aqua.hyperos.xml      ← 权限配置
    └── framework/
        └── lspd.dex                      ← LSPosed（如需预装）
```

**或者 product 分区（备选）：**
```
super.img
└── product/
    └── priv-app/
        └── AquaHyperOS/
            └── AquaHyperOS.apk
```

**推荐：system/priv-app/**
- 系统级特权应用
- 权限充足
- 不会被清除

---

## 📋 详细步骤

### 步骤 1: 修改 Settings.apk

#### 1.1 提取 Settings.apk

```bash
# 从 ROM 提取
unzip your_rom.zip -d rom_extracted
lpunpack rom_extracted/super.img super_extracted/
mount -o loop super_extracted/system.img system_mount/
cp system_mount/priv-app/Settings/Settings.apk .
```

#### 1.2 反编译

```bash
apktool d Settings.apk -o Settings_src
```

#### 1.3 找到主设置文件

```bash
cd Settings_src
find res/xml -name "*dashboard*.xml"
find res/xml -name "*top_level*.xml"

# 通常是这几个之一：
# res/xml/dashboard_main.xml
# res/xml/top_level_settings.xml
# res/xml/settings_headers.xml
```

#### 1.4 添加入口

编辑找到的 XML 文件（如 `res/xml/dashboard_main.xml`）：

```xml
<?xml version="1.0" encoding="utf-8"?>
<PreferenceScreen
    xmlns:android="http://schemas.android.com/apk/res/android">
    
    <!-- 添加我们的入口 - 放在最前面 -->
    <Preference
        android:key="aqua_hyperos_settings"
        android:title="AquaHyperOS"
        android:summary="HyperOS 深度定制模块"
        android:order="0">
        <intent
            android:targetPackage="com.aqua.hyperos"
            android:targetClass="com.aqua.hyperos.ui.SettingsActivity" />
    </Preference>
    
    <!-- 原有的设置项... -->
    
</PreferenceScreen>
```

#### 1.5 重新打包

```bash
# 编译
apktool b Settings_src -o Settings_modified.apk

# 对齐
zipalign -v 4 Settings_modified.apk Settings_aligned.apk

# 签名（使用官改的 platform 密钥）
apksigner sign --ks platform.keystore Settings_aligned.apk

# 如果没有密钥，可以用测试密钥
apksigner sign --ks ~/.android/debug.keystore Settings_aligned.apk
```

### 步骤 2: 添加 AquaHyperOS.apk

```bash
# 创建目录
mkdir -p system_mount/priv-app/AquaHyperOS/

# 复制 APK
cp AquaHyperOS.apk system_mount/priv-app/AquaHyperOS/

# 设置权限
chmod 644 system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
chown root:root system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
```

### 步骤 3: 替换 Settings.apk

```bash
# 备份原文件
cp system_mount/priv-app/Settings/Settings.apk Settings_original.apk.bak

# 替换
cp Settings_aligned.apk system_mount/priv-app/Settings/Settings.apk

# 设置权限
chmod 644 system_mount/priv-app/Settings/Settings.apk
chown root:root system_mount/priv-app/Settings/Settings.apk
```

### 步骤 4: 添加权限配置

```bash
cat > system_mount/etc/permissions/com.aqua.hyperos.xml << 'XMLEOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.aqua.hyperos">
        <permission name="android.permission.WRITE_EXTERNAL_STORAGE"/>
        <permission name="android.permission.READ_EXTERNAL_STORAGE"/>
        <permission name="android.permission.WRITE_SECURE_SETTINGS"/>
        <permission name="android.permission.INTERACT_ACROSS_USERS"/>
    </privapp-permissions>
</permissions>
XMLEOF

chmod 644 system_mount/etc/permissions/com.aqua.hyperos.xml
```

### 步骤 5: 添加 LSPosed（可选但推荐）

```bash
# 下载 LSPosed
# https://github.com/LSPosed/LSPosed/releases

# 解压
unzip LSPosed-v1.9.2-7024-zygisk-release.zip -d lsposed

# 复制文件
cp -r lsposed/system/* system_mount/
```

### 步骤 6: 重新打包 super.img

```bash
# 卸载
umount system_mount/

# 重新打包
lpmake --metadata-size 65536 \
       --super-name super \
       --device super:9126805504 \
       --group main:9126805504 \
       --partition system:readonly:$(stat -c%s super_extracted/system.img):main \
       --image system=super_extracted/system.img \
       --partition product:readonly:$(stat -c%s super_extracted/product.img):main \
       --image product=super_extracted/product.img \
       --partition system_ext:readonly:$(stat -c%s super_extracted/system_ext.img):main \
       --image system_ext=super_extracted/system_ext.img \
       --partition vendor:readonly:$(stat -c%s super_extracted/vendor.img):main \
       --image vendor=super_extracted/vendor.img \
       --sparse \
       --output super_new.img
```

### 步骤 7: 打包 ROM

```bash
# 替换 super.img
cp super_new.img rom_extracted/super.img

# 打包
cd rom_extracted
zip -r ../your_rom_aqua.zip *

# 签名（可选）
java -jar signapk.jar certificate.pem key.pk8 your_rom_aqua.zip your_rom_signed.zip
```

---

## 📊 最终文件清单

### ✅ 需要添加的文件

```
system/priv-app/AquaHyperOS/AquaHyperOS.apk
system/etc/permissions/com.aqua.hyperos.xml
```

### ✅ 需要修改的文件

```
system/priv-app/Settings/Settings.apk
  └── res/xml/dashboard_main.xml (添加入口)
```

### ✅ 可选添加

```
system/framework/lspd.dex (LSPosed)
system/lib64/liblspd.so (LSPosed)
```

---

## 🧪 刷机后测试

```bash
# 1. 检查文件
adb shell ls -la /system/priv-app/AquaHyperOS/
adb shell ls -la /system/priv-app/Settings/

# 2. 检查应用
adb shell pm list packages | grep aqua

# 3. 打开设置
# 应该在第一位看到 "AquaHyperOS" 入口

# 4. 点击入口
# 应该打开配置界面

# 5. 桌面检查
# 桌面应该没有 AquaHyperOS 图标 ✅

# 6. 查看日志
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log
```

---

## 🎯 分区选择总结

| 分区 | 推荐度 | 说明 |
|------|--------|------|
| **system/priv-app/** | ⭐⭐⭐ | 最推荐 - 系统特权应用 |
| product/priv-app/ | ⭐⭐ | 备选 - 产品定制应用 |
| system_ext/priv-app/ | ⭐ | 不推荐 - 可能被覆盖 |

**推荐：system/priv-app/**

---

## ✅ 需要替换的文件

| 文件 | 是否替换 | 说明 |
|------|----------|------|
| **Settings.apk** | ✅ 需要 | 添加入口 |
| SystemUI.apk | ❌ 不需要 | 通过 Hook 修改 |
| MiuiHome.apk | ❌ 不需要 | 通过 Hook 修改 |

**只需要替换 Settings.apk**

---

## 🚀 快速命令脚本

```bash
#!/bin/bash
# quick_integrate.sh

ROM_ZIP="$1"
AQUA_APK="$2"

# 解包
unzip "$ROM_ZIP" -d rom
lpunpack rom/super.img super_ext
mkdir sys_mnt
mount super_ext/system.img sys_mnt

# 添加 AquaHyperOS
mkdir -p sys_mnt/priv-app/AquaHyperOS
cp "$AQUA_APK" sys_mnt/priv-app/AquaHyperOS/
chmod 644 sys_mnt/priv-app/AquaHyperOS/*.apk

# 权限配置
cat > sys_mnt/etc/permissions/com.aqua.hyperos.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.aqua.hyperos">
        <permission name="android.permission.WRITE_EXTERNAL_STORAGE"/>
        <permission name="android.permission.READ_EXTERNAL_STORAGE"/>
    </privapp-permissions>
</permissions>
