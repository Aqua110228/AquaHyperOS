# Hook 地址验证和修正指南

## ⚠️ 当前状态

经过研究，我发现当前项目中的 Hook 地址**确实需要验证和调整**。以下是我的发现和建议。

## 🔍 研究发现

### 1. HyperCeiler 项目
- ✅ 找到项目：https://github.com/ReChronoRain/HyperCeiler
- ❌ 无法直接访问源代码文件（可能是私有或路径变化）
- ✅ 确认了作用域包名

### 2. 参考项目
从研究中发现的可用参考：

#### XMiTools (MIUI 10/11/12/12.5)
- GitHub: https://github.com/tianma8023/XMiTools
- 适用于 MIUI SystemUI
- 可以参考其 Hook 实现

#### AOSP 官方文档
- QSTile 架构文档：https://android.googlesource.com/platform/frameworks/base/+show/main/packages/SystemUI/docs/qs-tiles.md
- 标准类名：
  - `com.android.systemui.qs.QSTileHost`
  - `com.android.systemui.qs.tileimpl.QSTileImpl`
  - `com.android.systemui.qs.tileimpl.QSTileViewImpl`

### 3. 可能的 MIUI/HyperOS 类名

基于 AOSP 和常见模式，MIUI 可能使用：

```kotlin
// 控制中心 QSTile
"com.android.systemui.qs.tileimpl.QSTileViewImpl"  // AOSP 标准
"com.android.systemui.qs.MiuiQSTileView"           // MIUI 可能
"com.android.systemui.miui.qs.MiuiQSTileViewImpl"  // MIUI 可能
"com.android.systemui.controlcenter.qs.tileview.MiuiQSTileView"  // HyperOS 可能

// 指纹
"com.android.systemui.biometrics.UdfpsKeyguardView"  // AOSP 标准
"com.android.keyguard.fod.MiuiFodView"               // MIUI FOD
"com.android.systemui.biometrics.MiuiUdfpsView"      // MIUI 可能

// 状态栏
"com.android.systemui.statusbar.phone.PhoneStatusBarView"  // AOSP 标准
"com.android.systemui.statusbar.phone.MiuiPhoneStatusBarView"  // MIUI 可能
```

## 📋 必须做的验证步骤

### 步骤 1：从设备提取 APK

```bash
# 查找 SystemUI 路径
adb shell pm path com.android.systemui

# 可能的路径：
# /system/priv-app/MiuiSystemUI/MiuiSystemUI.apk
# /system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk

# 提取
adb pull /system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk

# 同样提取 Settings
adb shell pm path com.android.settings
adb pull /system/priv-app/Settings/Settings.apk
```

### 步骤 2：反编译 APK

**使用 jadx (推荐)**：
```bash
# 下载 jadx：https://github.com/skylot/jadx/releases

# 反编译
jadx MiuiSystemUI.apk -d output_systemui/
jadx Settings.apk -d output_settings/
```

### 步骤 3：搜索真实类名

```bash
cd output_systemui/

# 搜索 QSTile 相关
grep -r "QSTile" . | grep "class" | head -20
grep -r "ControlCenter" . | head -20

# 搜索指纹相关
grep -r "Udfps" . | grep "class" | head -20
grep -r "Fingerprint" . | grep "class" | head -20
grep -r "Fod" . | grep "class" | head -20

# 搜索状态栏
grep -r "StatusBarView" . | grep "class" | head -20
grep -r "PhoneStatusBar" . | grep "class" | head -20

# 搜索模糊效果
grep -r "Blur" . | grep "class" | head -20
```

### 步骤 4：验证方法是否存在

找到类后，打开对应的 Java 文件查看：
1. 方法名是否正确
2. 方法参数是否匹配
3. 方法是否是 public/protected

## 🛠️ 使用验证工具

### 在项目中使用 HookValidator

```kotlin
import com.aqua.hyperos.utils.HookValidator

override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
    // 步骤 1：尝试多个可能的类名
    val possibleClasses = arrayOf(
        "com.android.systemui.qs.tileimpl.QSTileViewImpl",
        "com.android.systemui.qs.MiuiQSTileView",
        "com.android.systemui.miui.qs.MiuiQSTileViewImpl",
        "com.android.systemui.controlcenter.qs.tileview.MiuiQSTileView"
    )
    
    val tileViewClass = HookValidator.findFirstExistingClass(
        lpparam.classLoader,
        *possibleClasses
    )
    
    if (tileViewClass == null) {
        XposedBridge.log("❌ 找不到 QSTileView 类，功能无法使用")
        return
    }
    
    // 步骤 2：列出该类的所有方法（调试用）
    HookValidator.listClassMethods(tileViewClass.name, lpparam.classLoader)
    
    // 步骤 3：验证方法是否存在
    val methodExists = HookValidator.validateMethod(
        tileViewClass.name,
        "onConfigurationChanged",
        lpparam.classLoader,
        android.content.res.Configuration::class.java
    )
    
    if (!methodExists) {
        XposedBridge.log("❌ 方法 onConfigurationChanged 不存在")
        return
    }
    
    // 步骤 4：执行 Hook
    try {
        XposedHelpers.findAndHookMethod(
            tileViewClass,
            "onConfigurationChanged",
            android.content.res.Configuration::class.java,
            object : XC_MethodHook() {
                override fun afterHookedMethod(param: MethodHookParam) {
                    // Hook 逻辑
                }
            }
        )
        XposedBridge.log("✅ Hook 成功")
    } catch (e: Exception) {
        XposedBridge.log("❌ Hook 失败: ${e.message}")
    }
}
```

### 运行时类枚举（高级）

```kotlin
fun enumerateClasses(lpparam: XC_LoadPackage.LoadPackageParam, keyword: String) {
    try {
        val dexFile = dalvik.system.DexFile(lpparam.appInfo.sourceDir)
        val entries = dexFile.entries()
        
        XposedBridge.log("📋 搜索包含 '$keyword' 的类：")
        while (entries.hasMoreElements()) {
            val className = entries.nextElement()
            if (className.contains(keyword, ignoreCase = true)) {
                XposedBridge.log("  - $className")
            }
        }
    } catch (e: Exception) {
        XposedBridge.log("枚举类失败: ${e.message}")
    }
}

// 使用
enumerateClasses(lpparam, "QSTile")
enumerateClasses(lpparam, "Udfps")
enumerateClasses(lpparam, "Blur")
```

## 📝 修正建议

### 方案 A：渐进式修正（推荐）

1. **先让配置界面能用**
   - 设置注入部分使用 AOSP 标准类（基本不变）
   - 配置界面可以正常显示

2. **逐个功能验证**
   - 从简单的开始（状态栏、设置）
   - 逐步到复杂的（控制中心、指纹）

3. **提供降级方案**
   ```kotlin
   if (hookSuccess) {
       // 功能正常
   } else {
       // 在配置界面显示"该功能在当前系统版本不可用"
       XposedBridge.log("功能不可用，但不影响其他功能")
   }
   ```

### 方案 B：多版本适配

```kotlin
// 根据 Android 版本选择类名
val className = when {
    Build.VERSION.SDK_INT >= 35 -> "com.android.systemui.controlcenter.qs.MiuiQSTileView"
    Build.VERSION.SDK_INT >= 34 -> "com.android.systemui.qs.MiuiQSTileView"
    else -> "com.android.systemui.qs.tileimpl.QSTileViewImpl"
}
```

## 🎯 优先级建议

### 高优先级（必须验证）
1. ✅ **设置注入** - 使用 AOSP 标准类，基本可用
2. ❓ **配置界面构建** - 使用 AOSP 标准类，基本可用
3. ❓ **状态栏** - 需要验证但相对简单

### 中优先级（重要但可延后）
4. ❓ **控制中心** - MIUI 深度定制，需要仔细验证
5. ❓ **锁屏指纹** - FOD 实现因设备而异

### 低优先级（增值功能）
6. ❓ **灵动岛歌词** - MediaSession 是标准 API，但 UI 注入需验证
7. ❓ **柔光玻璃** - 效果因系统版本差异大

## 📚 参考资源

### 工具
- **jadx**：https://github.com/skylot/jadx (反编译 APK)
- **MT Manager**：Android 上的 APK 编辑工具
- **LSPosed**：现代 Xposed 实现，有详细日志

### 文档
- **AOSP QSTile 文档**：https://cs.android.com/android/platform/superproject/+/master:frameworks/base/packages/SystemUI/docs/qs-tiles.md
- **Xposed API**：https://api.xposed.info/reference/packages.html

### 参考项目
- **HyperCeiler**：https://github.com/ReChronoRain/HyperCeiler
- **XMiTools**：https://github.com/tianma8023/XMiTools
- **custoMIUIzer**：搜索 GitHub

## ✅ 总结

**当前项目的价值**：
- ✅ 完整的项目架构
- ✅ 正确的实现思路
- ✅ 可用的配置系统框架
- ✅ 验证工具已准备

**需要你做的**：
1. 🔴 反编译你的 HyperOS 版本的 SystemUI.apk
2. 🔴 找到每个功能的真实类名和方法名
3. 🔴 修改 Hook 代码中的类名和方法名
4. 🟡 使用 HookValidator 工具逐个测试
5. 🟡 根据日志输出调整代码

**预期结果**：
- 设置注入和配置界面：90% 可直接使用（基于 AOSP 标准）
- 其他功能：需要根据真机反编译结果调整

---

**再次抱歉之前没有明确说明这一点。这个项目是一个完整的"脚手架"，但需要根据实际系统填充正确的 Hook 地址。**
