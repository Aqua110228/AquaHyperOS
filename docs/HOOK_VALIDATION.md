# Hook 地址验证说明

## ⚠️ 重要警告

**当前代码中的 Hook 地址（类名、方法名）大部分未经实际验证！**

这些地址是基于：
1. 标准 Android AOSP 源码结构
2. 常见的 MIUI/HyperOS Hook 经验
3. 类似项目的参考

**但可能存在的问题**：
- HyperOS 对 Android 进行了深度定制，很多类被重命名
- 不同系统版本的类结构可能完全不同
- 某些功能在 HyperOS 中可能用了完全不同的实现

## 🔍 如何验证 Hook 地址

### 方法一：使用 HookValidator 工具

在每个 Hook 模块的开头添加验证：

```kotlin
override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
    // 验证类是否存在
    if (!HookValidator.validateClass("com.android.systemui.qs.tileimpl.QSTileViewImpl", lpparam.classLoader)) {
        // 尝试其他可能的类名
        val clazz = HookValidator.findFirstExistingClass(
            lpparam.classLoader,
            "com.android.systemui.qs.tileimpl.QSTileViewImpl",
            "com.android.systemui.miui.qs.tileimpl.QSTileViewImpl",  // MIUI 定制
            "com.android.systemui.qs.QSTileView"  // 旧版本
        )
        if (clazz == null) {
            XposedBridge.log("无法找到 QSTileView 类，功能可能无法正常工作")
            return
        }
    }
}
```

### 方法二：反编译系统应用

**必须做的事情**：

1. **反编译 SystemUI.apk**
```bash
# 从设备提取
adb pull /system/priv-app/MiuiSystemUI/MiuiSystemUI.apk

# 使用 jadx 反编译
jadx MiuiSystemUI.apk -d output/
```

2. **查找实际的类名**
```bash
# 搜索控制中心磁贴相关类
grep -r "QSTile" output/
grep -r "ControlCenter" output/
```

3. **确认方法签名**
打开反编译后的 Java 代码，查看实际的方法名和参数

### 方法三：运行时枚举

添加调试代码列出所有类：

```kotlin
// 列出包含 "QSTile" 的所有类
lpparam.classLoader.loadClass("dalvik.system.DexFile")
// 枚举所有类名
```

## 📋 需要验证的关键 Hook 点

### ControlCenterHook
- ❓ `com.android.systemui.qs.tileimpl.QSTileViewImpl`
  - 可能是: `com.android.systemui.miui.qs.tileimpl.MiuiQSTileViewImpl`
- ❓ `com.android.systemui.plugins.qs.QSIconView`
  - 可能是: `com.android.systemui.miui.qs.MiuiQSIconView`

### LockscreenHook
- ❓ `com.android.systemui.biometrics.UdfpsKeyguardView`
  - 可能是: `com.android.keyguard.fod.MiuiFodView`
  - 或: `com.android.systemui.miui.biometrics.MiuiUdfpsView`

### ThemeBlurHook
- ❓ `com.android.systemui.statusbar.BlurUtils`
  - 可能是: `com.android.systemui.miui.blur.MiuiBlurUtils`

### DynamicIslandLyricsHook
- ❓ `com.android.systemui.media.MediaControlPanel`
  - 可能是: `com.android.systemui.miui.media.MiuiMediaControlPanel`

### SettingsAppHook
- ❓ Preference 的 key 名称需要实际查看设置应用确定
  - `device_benefits` 可能叫 `mi_vip` 或其他名字

## 🛠️ 建议的开发流程

### 1. 先验证，再实现
```kotlin
// 第一步：验证类是否存在
HookValidator.listClassMethods("com.android.systemui.qs.tileimpl.QSTileViewImpl", lpparam.classLoader)

// 第二步：根据实际输出调整 Hook 代码
```

### 2. 提供降级方案
```kotlin
val tileViewClass = HookValidator.findFirstExistingClass(
    lpparam.classLoader,
    "com.android.systemui.qs.tileimpl.QSTileViewImpl",  // AOSP
    "com.android.systemui.miui.qs.tileimpl.MiuiQSTileViewImpl",  // MIUI
    "com.android.systemui.qs.QSTileView"  // 备选
) ?: run {
    XposedBridge.log("无法找到 QSTileView，跳过此功能")
    return
}
```

### 3. 使用 try-catch 保护
```kotlin
try {
    XposedHelpers.findAndHookMethod(...)
} catch (e: NoSuchMethodError) {
    XposedBridge.log("方法不存在: ${e.message}")
    // 尝试其他方法名
} catch (e: Exception) {
    XposedBridge.log("Hook 失败: ${e.message}")
}
```

## 📝 实际测试清单

在真机上测试前，必须：

- [ ] 确认设备型号和 HyperOS 版本
- [ ] 反编译对应版本的 SystemUI.apk
- [ ] 验证每个 Hook 点的类名是否存在
- [ ] 验证每个 Hook 点的方法名和签名
- [ ] 调整代码以适配实际的类结构
- [ ] 添加日志输出便于调试
- [ ] 提供多个备选方案

## 🚨 当前状态

**这个项目的代码是框架和逻辑实现，但 Hook 地址需要根据实际的 HyperOS 版本进行调整。**

**强烈建议**：
1. 先在测试设备上运行验证工具
2. 根据日志输出调整类名和方法名
3. 逐个功能测试和修正
4. 记录不同 HyperOS 版本的差异

## 📚 参考资源

- HyperOS 反编译工具: jadx, apktool
- Xposed 调试: LSPosed Manager 的日志查看
- MIUI/HyperOS Hook 项目参考（需要实际查找开源项目）

---

**总结：当前代码提供了完整的项目结构和实现逻辑，但需要根据实际系统版本验证和调整 Hook 地址。**
