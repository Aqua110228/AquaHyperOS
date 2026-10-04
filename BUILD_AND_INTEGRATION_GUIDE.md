# 📦 AquaHyperOS 打包与集成指南

## 🎯 目录结构

```
AquaHyperOS/
├── 打包方式 1: LSPosed 模块（当前）
└── 打包方式 2: 集成到官改 ROM
```

---

## 方式 1: LSPosed 模块打包（推荐测试用）

### 打包步骤

```bash
# 1. 编译项目
./gradlew assembleRelease

# 2. 签名 APK
apksigner sign --ks release.keystore app-release.apk

# 3. 生成的文件
app/build/outputs/apk/release/AquaHyperOS-v1.0.0.apk
```

### 安装使用

```bash
# 安装模块
adb install AquaHyperOS-v1.0.0.apk

# 在 LSPosed 中激活
1. 打开 LSPosed Manager
2. 勾选 AquaHyperOS
3. 选择作用域：
   ☑ 系统界面 (com.android.systemui)
   ☑ 系统框架 (android)
   ☑ 设置 (com.android.settings)
4. 重启设备
```

---

## 方式 2: 集成到官改 ROM ⭐

### 📁 放置位置

#### 选项 A: system 分区（推荐）

```
super.img
└── system/
    └── priv-app/
        └── AquaHyperOS/
            └── AquaHyperOS.apk
```

**原因**：
- ✅ 系统级应用
- ✅ 自动获得所有权限
- ✅ 不会被用户卸载

#### 选项 B: product 分区

```
super.img
└── product/
    └── priv-app/
        └── AquaHyperOS/
            └── AquaHyperOS.apk
```

**原因**：
- ✅ 产品定制应用
- ✅ 适合官改定制
- ✅ 权限充足

#### ❌ 不建议：system_ext 分区

```
原因：
- 可能被系统更新覆盖
- 权限可能不足
```

---

## 🔧 集成详细步骤

### 步骤 1: 解包 ROM

```bash
# 1. 提取 super.img
unzip your_rom.zip -d rom_extracted
cd rom_extracted

# 2. 解包 super.img（需要 lpunpack 工具）
lpunpack super.img extracted_super/

# 你会得到：
extracted_super/
├── system.img
├── system_ext.img
├── product.img
└── vendor.img
```

### 步骤 2: 挂载分区

```bash
# 挂载 system 分区
mkdir system_mount
sudo mount -o loop extracted_super/system.img system_mount/

# 或者使用 ext4 工具
e2fsck -f extracted_super/system.img
resize2fs extracted_super/system.img
```

### 步骤 3: 添加 APK

```bash
# 创建目录
mkdir -p system_mount/priv-app/AquaHyperOS/

# 复制 APK
cp AquaHyperOS.apk system_mount/priv-app/AquaHyperOS/

# 设置权限
chmod 644 system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
chown root:root system_mount/priv-app/AquaHyperOS/AquaHyperOS.apk
```

### 步骤 4: 添加权限配置（重要）

创建权限配置文件：

```bash
# 创建权限文件
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

### 步骤 5: 卸载并重新打包

```bash
# 1. 卸载分区
sudo umount system_mount/

# 2. 重新打包 super.img
lpmake --metadata-size 65536 \
       --super-name super \
       --metadata-slots 2 \
       --device super:9126805504 \
       --group main:9126805504 \
       --partition system:readonly:$(stat -c%s extracted_super/system.img):main \
       --image system=extracted_super/system.img \
       --partition product:readonly:$(stat -c%s extracted_super/product.img):main \
       --image product=extracted_super/product.img \
       --partition system_ext:readonly:$(stat -c%s extracted_super/system_ext.img):main \
       --image system_ext=extracted_super/system_ext.img \
       --partition vendor:readonly:$(stat -c%s extracted_super/vendor.img):main \
       --image vendor=extracted_super/vendor.img \
       --sparse \
       --output super_new.img

# 3. 替换回 ROM 包
cp super_new.img rom_extracted/super.img
```

### 步骤 6: 重新打包 ROM

```bash
cd rom_extracted
zip -r ../your_rom_aqua.zip *

# 签名（如果需要）
java -jar signapk.jar certificate.pem key.pk8 your_rom_aqua.zip your_rom_aqua_signed.zip
```

---

## 🛠️ 是否需要替换系统 APK？

### ❌ 不需要替换 Settings.apk

**原因**：
- 我们通过 Hook 注入设置入口
- 不修改原 APK
- 保持系统完整性

### ❌ 不需要替换 SystemUI.apk

**原因**：
- 我们通过 LSPosed Hook
- 不修改原 APK
- 方便更新和调试

### ✅ 需要预装 LSPosed 框架

**集成 LSPosed 到 ROM**：

```bash
# 1. 下载 LSPosed Zygisk 版本
# https://github.com/LSPosed/LSPosed/releases

# 2. 解压 LSPosed-*-zygisk-release.zip
unzip LSPosed-*-zygisk-release.zip -d lsposed

# 3. 复制文件到 system
cp -r lsposed/system/* system_mount/

# 4. 需要的文件：
system/
├── framework/
│   └── lspd.dex
├── lib64/
│   └── liblspd.so
└── etc/
    └── lspd/
```

---

## 📋 完整集成清单

### 必需文件

```
system/priv-app/AquaHyperOS/
└── AquaHyperOS.apk

system/etc/permissions/
└── com.aqua.hyperos.xml

system/framework/
└── lspd.dex  (LSPosed)

system/lib64/
└── liblspd.so  (LSPosed)
```

### 目录结构示例

```
your_rom/
├── super.img (已修改)
│   └── system/
│       ├── priv-app/
│       │   ├── AquaHyperOS/
│       │   │   └── AquaHyperOS.apk  ← 我们的模块
│       │   ├── Settings/
│       │   │   └── Settings.apk  ← 不修改
│       │   └── SystemUI/
│       │       └── SystemUI.apk  ← 不修改
│       ├── framework/
│       │   └── lspd.dex  ← LSPosed
│       └── etc/
│           └── permissions/
│               └── com.aqua.hyperos.xml  ← 权限配置
├── boot.img
└── META-INF/
```

---

## 🚀 简化方法（使用脚本）

我给你准备了自动化脚本：

```bash
#!/bin/bash
# integrate_to_rom.sh

ROM_DIR="$1"
APK_FILE="$2"

echo "🚀 集成 AquaHyperOS 到 ROM..."

# 1. 解包 super
lpunpack "$ROM_DIR/super.img" super_extracted/

# 2. 挂载 system
mkdir system_mount
mount -o loop super_extracted/system.img system_mount/

# 3. 添加 APK
mkdir -p system_mount/priv-app/AquaHyperOS/
cp "$APK_FILE" system_mount/priv-app/AquaHyperOS/
chmod 644 system_mount/priv-app/AquaHyperOS/*.apk

# 4. 添加权限配置
cat > system_mount/etc/permissions/com.aqua.hyperos.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<permissions>
    <privapp-permissions package="com.aqua.hyperos">
        <permission name="android.permission.WRITE_EXTERNAL_STORAGE"/>
        <permission name="android.permission.READ_EXTERNAL_STORAGE"/>
    </privapp-permissions>
</permissions>
