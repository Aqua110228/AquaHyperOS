# 📦 AquaHyperOS 打包与集成指南

## 🎯 两种使用方式

### 方式 1: LSPosed 模块（推荐测试）
- 独立 APK
- 需要 LSPosed 框架
- 容易测试和调试

### 方式 2: 集成到官改 ROM（最终方案）
- 预装到系统
- 用户刷机即可使用
- 需要预装 LSPosed

---

## 📦 方式 1: 打包 LSPosed 模块

### 需要的文件结构

```
AquaHyperOS/
├── AndroidManifest.xml
├── build.gradle
├── module/
│   ├── hooks/          (所有 Hook 类)
│   ├── ui/             (SettingsActivity)
│   └── utils/          (Logger)
└── res/
    └── values/
        └── strings.xml
```

### 打包命令

```bash
# 如果你有 Android Studio 项目
./gradlew assembleRelease

# 生成的文件
app/build/outputs/apk/release/AquaHyperOS-v1.0.0.apk
```

### 安装测试

```bash
adb install AquaHyperOS-v1.0.0.apk

# 在 LSPosed 中激活
# 选择作用域: android, com.android.systemui, com.android.settings
# 重启设备
```

---

## 🔧 方式 2: 集成到官改 ROM

### 📍 放置位置

**推荐：system/priv-app/**

```
super.img
└── system/
    └── priv-app/
        └── AquaHyperOS/
            └── AquaHyperOS.apk
```

**原因**：
- ✅ 系统特权应用
- ✅ 自动获得所有权限
- ✅ 开机自动激活

**备选：product/priv-app/**

```
super.img
└── product/
    └── priv-app/
        └── AquaHyperOS/
            └── AquaHyperOS.apk
```

---

## 🛠️ 集成详细步骤

### 步骤 1: 解包 ROM

```bash
# 解压 ROM 包
unzip your_rom.zip -d rom_extracted

# 解包 super.img (需要 lpunpack 工具)
lpunpack rom_extracted/super.img super_extracted/

# 得到各个分区镜像
super_extracted/
├── system.img
├── system_ext.img
├── product.img
└── vendor.img
```

### 步骤 2: 挂载 system 分区

```bash
# 创建挂载点
mkdir system_mount

# 挂载 system.img
sudo mount -o loop super_extracted/system.img system_mount/
```

### 步骤 3: 添加 AquaHyperOS

```bash
# 创建目录
mkdir -p system_mount/priv-app/AquaHyperOS/

# 复制 APK
cp AquaHyperOS.apk system_mount/priv-app/AquaHyperOS/

# 设置权限
chmod 644 system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
chown root:root system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
```

### 步骤 4: 添加权限配置

```bash
# 创建权限配置文件
cat > system_mount/etc/permissions/com.aqua.hyperos.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.aqua.hyperos">
        <permission name="android.permission.WRITE_EXTERNAL_STORAGE"/>
        <permission name="android.permission.READ_EXTERNAL_STORAGE"/>
        <permission name="android.permission.WRITE_SECURE_SETTINGS"/>
    </privapp-permissions>
</permissions>
EOF

# 设置权限
chmod 644 system_mount/etc/permissions/com.aqua.hyperos.xml
```

### 步骤 5: 集成 LSPosed（重要）

```bash
# 下载 LSPosed (Zygisk 版本)
# https://github.com/LSPosed/LSPosed/releases

# 解压
unzip LSPosed-v1.9.2-7024-zygisk-release.zip -d lsposed

# 复制 LSPosed 文件到 system
cp -r lsposed/system/* system_mount/
```

### 步骤 6: 卸载并重新打包

```bash
# 卸载分区
sudo umount system_mount/

# 重新打包 super.img
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

### 步骤 7: 重新打包 ROM

```bash
# 替换 super.img
cp super_new.img rom_extracted/super.img

# 打包 ROM
cd rom_extracted
zip -r ../your_rom_aqua.zip *

# 签名 (如果需要)
java -jar signapk.jar certificate.pem key.pk8 your_rom_aqua.zip your_rom_aqua_signed.zip
```

---

## ❓ 常见问题

### Q1: 需要替换 Settings.apk 吗？

**❌ 不需要**

我们通过 Hook 注入设置入口，不修改原 APK。

### Q2: 需要替换 SystemUI.apk 吗？

**❌ 不需要**

我们通过 LSPosed Hook 运行时行为，不修改原 APK。

### Q3: 需要预装什么？

**✅ 必需：**
1. AquaHyperOS.apk (我们的模块)
2. LSPosed 框架
3. 权限配置文件

**❌ 不需要：**
1. 不需要替换任何系统 APK
2. 不需要修改 framework.jar

### Q4: 放哪个分区？

**推荐顺序：**
1. system/priv-app/ ⭐ (最推荐)
2. product/priv-app/ (备选)
3. ❌ 不推荐 system_ext/priv-app/

---

## 📋 完整文件清单

### 必需添加的文件

```
system/
├── priv-app/
│   └── AquaHyperOS/
│       └── AquaHyperOS.apk          ← 我们的模块
├── etc/
│   └── permissions/
│       └── com.aqua.hyperos.xml     ← 权限配置
├── framework/
│   └── lspd.dex                     ← LSPosed
└── lib64/
    └── liblspd.so                   ← LSPosed
```

### 不需要修改的文件

```
system/
├── priv-app/
│   └── Settings/
│       └── Settings.apk             ✅ 保持不动
system_ext/
├── priv-app/
│   └── MiuiSystemUI/
│       └── MiuiSystemUI.apk         ✅ 保持不动
product/
├── priv-app/
│   └── MiuiHome/
│       └── MiuiHome.apk             ✅ 保持不动
```

---

## 🧪 刷机后测试

```bash
# 1. 检查 APK 是否存在
adb shell ls -la /system/priv-app/AquaHyperOS/

# 2. 检查应用是否安装
adb shell pm list packages | grep aqua

# 3. 打开系统设置
# 应该在第一位看到 "AquaHyperOS" 入口

# 4. 点击入口
# 应该能打开配置界面

# 5. 查看日志
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log
```

---

## 📊 总结

| 项目 | 是否需要 | 位置 |
|------|----------|------|
| AquaHyperOS.apk | ✅ 添加 | system/priv-app/ |
| 权限配置 | ✅ 添加 | system/etc/permissions/ |
| LSPosed | ✅ 添加 | system/framework/ |
| Settings.apk | ❌ 不动 | 保持原样 |
| SystemUI.apk | ❌ 不动 | 保持原样 |
| MiuiHome.apk | ❌ 不动 | 保持原样 |

**关键点**：
- ✅ 只添加 3 个东西：APK + 权限配置 + LSPosed
- ❌ 不替换任何系统 APK
- ✅ 通过 Hook 实现功能

---

## 🛠️ 需要的工具

1. **lpunpack / lpmake** - 解包打包 super.img
2. **mount / umount** - 挂载分区
3. **zip / unzip** - 打包 ROM
4. **apksigner** - 签名 (可选)

---

准备好了吗？🚀
