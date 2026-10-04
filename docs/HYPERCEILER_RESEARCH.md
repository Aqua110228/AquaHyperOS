# HyperCeiler 参考研究笔记

## 研究进展

### 尝试过的方法
1. ✅ 找到了 HyperCeiler 项目：https://github.com/ReChronoRain/HyperCeiler
2. ❌ 直接访问源代码文件失败（404）
3. ✅ 确认了作用域：com.android.systemui, com.miui.home, com.android.settings 等

### 从 README 获取的关键信息

#### 支持的应用作用域
```
- 系统框架: system
- 系统界面: com.android.systemui
- 系统桌面: com.miui.home
- 系统更新: com.android.updater
- 系统设置: com.android.settings
- 安全中心: com.miui.securitycenter
- 壁纸: com.miui.miwallpaper
```

#### 版本支持
- 当前适配：Android 16 + HyperOS 3.0
- 已停止维护：Android 11-13 MIUI, HyperOS 1.0-2.0

### 参考的其他项目

从 HyperCeiler 的致谢中发现的相关项目：
1. **HyperOShape** - 指纹图标相关
2. **XiaomiHelper** - 系统设置注入
3. **HyperPasskey** - 凭据管理
4. **MiuiBackGestureHook** - MiuiHome 桌面钩子

## 下一步建议

### 方案 A：使用真机反编译验证（推荐）
这是最可靠的方法：

1. **从真机提取 SystemUI.apk**
```bash
adb shell pm path com.android.systemui
adb pull /system_ext/priv-app/MiuiSystemUI/MiuiSystemUI.apk
```

2. **使用 jadx 反编译**
```bash
jadx MiuiSystemUI.apk -d output/
```

3. **搜索关键类**
```bash
cd output/
grep -r "QSTile" . | head -20
grep -r "ControlCenter" . | head -20
grep -r "Udfps" . | head -20
grep -r "Fingerprint" . | head -20
```

### 方案 B：查找其他开源项目

可以研究的项目：
1. **XiaomiHelper** - 小米系统助手
2. **MIUI 莺语** (如果开源)
3. **Cemiuiler** (HyperCeiler 的前身)

### 方案 C：使用 Xposed 的运行时类枚举

在 Hook 中添加调试代码：
```kotlin
// 列出所有包含 QSTile 的类
val dexFile = DexFile(lpparam.appInfo.sourceDir)
val entries = dexFile.entries()
while (entries.hasMoreElements()) {
    val className = entries.nextElement()
    if (className.contains("QSTile")) {
        XposedBridge.log("找到类: $className")
    }
}
```

## 已知的可能类名（需验证）

基于 AOSP 和常见经验，MIUI/HyperOS 可能使用：

### 控制中心
- ❓ `com.android.systemui.qs.MiuiQSTileView`
- ❓ `com.android.systemui.miui.qs.MiuiQSTileViewImpl`
- ❓ `com.android.systemui.controlcenter.qs.tileview.MiuiQSTileView`

### 锁屏指纹
- ❓ `com.android.keyguard.fod.MiuiFodView`
- ❓ `com.android.systemui.biometrics.MiuiUdfpsView`
- ❓ `com.miui.keyguard.biometrics.fod.MiuiFodView`

### 状态栏
- ❓ `com.android.systemui.statusbar.phone.MiuiPhoneStatusBarView`
- ❓ `com.android.systemui.miui.statusbar.MiuiStatusBarView`

### 设置
- ✅ `com.android.settings.dashboard.DashboardFragment` (AOSP 标准)
- ❓ `com.android.settings.MiuiSettings` (可能的 MIUI 定制)

## 临时解决方案

在等待验证期间，可以：

1. **使用 HookValidator 工具**
```kotlin
val possibleClasses = arrayOf(
    "com.android.systemui.qs.MiuiQSTileView",
    "com.android.systemui.miui.qs.MiuiQSTileViewImpl",
    "com.android.systemui.controlcenter.qs.tileview.MiuiQSTileView"
)

val actualClass = HookValidator.findFirstExistingClass(
    lpparam.classLoader,
    *possibleClasses
)
```

2. **添加完善的日志**
```kotlin
try {
    // 尝试 Hook
} catch (e: ClassNotFoundException) {
    XposedBridge.log("类不存在: ${e.message}")
    // 列出可能的类
    HookValidator.listClassMethods("备选类名", lpparam.classLoader)
} catch (e: NoSuchMethodError) {
    XposedBridge.log("方法不存在: ${e.message}")
}
```

3. **提供降级功能**
如果 Hook 失败，至少保证配置界面能用，用户可以看到功能列表。

## 结论

**当前项目的 Hook 地址需要通过以下方式之一验证：**
1. 反编译目标 HyperOS 版本的系统应用（最可靠）
2. 参考其他已验证的开源项目
3. 使用运行时枚举找到正确的类名

**在验证前，代码只是"理论实现"，不能保证在真机上运行。**
