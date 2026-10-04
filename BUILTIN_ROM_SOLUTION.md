# 🎯 直接内置到系统 ROM 方案

## 你的需求

**目标**：用户刷机后直接就有所有功能，无需：
- ❌ 不需要 LSPosed
- ❌ 不需要 Magisk
- ❌ 不需要任何模块
- ✅ 开机即用

**这就是真正的官改！**

---

## 实现方案

### 方法 1：修改系统 APK（推荐）⭐

**原理**：
- 反编译系统应用（SystemUI、Settings 等）
- 注入我们的功能代码
- 重新打包
- 替换到 ROM 包中
- 用户刷机即可

**流程**：
```
1. 提取官改 ROM 中的 APK
2. 反编译 APK
3. 添加我们的功能代码
4. 重新打包并签名
5. 替换回 ROM 包
6. 打包成刷机包
```

**优点**：
- ✅ 无需任何框架
- ✅ 开机即用
- ✅ 性能最好
- ✅ 就像原生功能

---

### 方法 2：注入到 framework.jar

**原理**：
- 修改 `system/framework/framework.jar`
- 在系统核心添加 Hook 代码
- 所有应用启动时自动加载

**优点**：
- ✅ 一次注入，全局生效
- ✅ 不需要修改多个 APK

**缺点**：
- ⚠️ 难度较高
- ⚠️ 容易导致系统不稳定

---

## 🚀 推荐实现方案

### 修改 SystemUI.apk（状态栏、控制中心、锁屏）

#### 步骤 1：反编译
```bash
apktool d SystemUI.apk -o SystemUI_src
```

#### 步骤 2：添加我们的代码

在 `SystemUI_src/smali/` 下添加：
```
smali/com/aqua/hyperos/
├── StatusBarHelper.smali
├── ControlCenterHelper.smali
├── LockscreenHelper.smali
└── ConfigManager.smali
```

#### 步骤 3：修改原有代码

找到 `StatusBarView.smali`，注入调用：
```smali
# 在 setBackgroundColor 方法中
.method public setBackgroundColor(I)V
    .locals 1
    
    # 调用我们的代码
    invoke-static {p1}, Lcom/aqua/hyperos/StatusBarHelper;->getCustomColor(I)I
    move-result p1
    
    # 原始代码
    invoke-super {p0, p1}, Landroid/view/View;->setBackgroundColor(I)V
    return-void
.end method
```

#### 步骤 4：重新打包
```bash
apktool b SystemUI_src -o SystemUI_modified.apk
zipalign -v 4 SystemUI_modified.apk SystemUI_final.apk
```

#### 步骤 5：签名
```bash
# 使用官改的签名密钥
apksigner sign --ks platform.keystore SystemUI_final.apk
```

---

### 修改 Settings.apk（设置界面）

同样的流程：
1. 反编译
2. 添加配置界面代码
3. 注入功能代码
4. 重新打包签名

---

## 📦 集成到 ROM 包

### ROM 包结构

```
your_rom/
├── META-INF/
├── system/
│   ├── system_ext/
│   │   └── priv-app/
│   │       └── MiuiSystemUI/
│   │           └── MiuiSystemUI.apk  ← 替换这个
│   └── priv-app/
│       └── Settings/
│           └── Settings.apk  ← 替换这个
└── boot.img
```

### 替换步骤

```bash
# 1. 解包 ROM
unzip your_rom.zip -d rom_extracted

# 2. 替换 APK
cp SystemUI_final.apk rom_extracted/system/system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk
cp Settings_final.apk rom_extracted/system/priv-app/Settings/Settings.apk

# 3. 重新打包
cd rom_extracted
zip -r ../your_rom_modded.zip *

# 4. 签名（如果需要）
java -jar signapk.jar certificate.pem key.pk8 your_rom_modded.zip your_rom_signed.zip
```

---

## 🛠️ 我需要做的工作

### 1. 转换所有 Kotlin Hook 代码为 Smali

**当前代码**（Kotlin）：
```kotlin
class StatusBarHook {
    fun hookStatusBar() {
        // Hook 逻辑
    }
}
```

**转换为**（Smali）：
```smali
.class public Lcom/aqua/hyperos/StatusBarHelper;
.super Ljava/lang/Object;

.method public static hookStatusBar()V
    # Smali 实现
.end method
```

### 2. 注入点定位

为每个功能找到注入点：
- StatusBar 背景颜色 → `StatusBarView.setBackgroundColor()`
- 控制中心磁贴 → `QSTileView.onLayout()`
- 锁屏指纹 → `UdfpsView.setVisibility()`
- 等等...

### 3. 配置系统

添加配置文件到系统：
```
/system/etc/aquahyperos/
├── config.json
└── default_settings.json
```

---

## ⏱️ 工作量评估

### 需要转换的模块

| 模块 | 当前代码 | 需要转换 | 预估时间 |
|------|----------|----------|----------|
| CorePatch | 113 行 Kotlin | → Smali | 1 天 |
| StatusBar | 151 行 Kotlin | → Smali | 1 天 |
| ControlCenter | 88 行 Kotlin | → Smali | 0.5 天 |
| Lockscreen | 105 行 Kotlin | → Smali | 0.5 天 |
| Launcher | 183 行 Kotlin | → Smali | 1 天 |
| Theme | 54 行 Kotlin | → Smali | 0.5 天 |

**总计**：约 5-7 天

---

## 🎯 具体实施步骤

### 阶段 1：准备工作（1 天）

1. **提取你的官改 ROM 中的 APK**
   - SystemUI.apk
   - Settings.apk
   - MiuiHome.apk

2. **反编译所有 APK**

3. **分析代码结构**

### 阶段 2：代码转换（3-5 天）

1. **将 Kotlin Hook 代码转换为 Smali**
2. **找到所有注入点**
3. **编写 Smali 注入代码**

### 阶段 3：集成测试（1-2 天）

1. **重新打包 APK**
2. **签名**
3. **替换到 ROM**
4. **刷机测试**

---

## 💡 简化方案

如果觉得太复杂，还有一个**更简单**的方法：

### 使用 init.d 脚本 + 预编译库

**原理**：
- 编译我们的 Hook 代码为 `.so` 库
- 在系统启动时通过 `init.d` 脚本注入
- 不需要修改 APK

**结构**：
```
/system/
├── etc/
│   └── init.d/
│       └── 99-aquahyperos.sh  ← 启动脚本
└── lib64/
    └── libaquahyperos.so  ← 我们的库
```

**优点**：
- ✅ 不需要反编译 APK
- ✅ 实现相对简单
- ✅ 容易维护

**缺点**：
- ⚠️ 仍需要 Hook 框架（但可以内置）

---

## 🤔 你想用哪种方案？

### 方案 A：完全内置（推荐）
- 修改系统 APK
- 功能直接内置
- 无需任何框架
- 工作量：5-7 天

### 方案 B：init.d + .so 库
- 使用启动脚本
- 注入预编译库
- 需要精简的 Hook 框架
- 工作量：2-3 天

### 方案 C：混合方案
- 核心功能内置到 APK
- 复杂功能用 .so 库
- 平衡实现难度和效果
- 工作量：3-4 天

---

**告诉我你选哪个方案，我立即开始实施！**

需要提供：
1. 你的官改 ROM 包（或至少 SystemUI.apk、Settings.apk）
2. ROM 的签名密钥（如果有）
3. 目标设备型号

准备好了吗？ 🚀
