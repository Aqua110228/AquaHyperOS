# APK 反编译分析结果

## 📦 分析的APK

1. **系统界面_17.03.260226.r.apk** (55.9 MB) - SystemUI
   - 包含 4 个 DEX 文件
   - 总计约 32 MB 代码

2. **设置_17.apk** (129.2 MB) - Settings
   - 包含 12 个 DEX 文件
   - 总计约 65 MB 代码

## 🔍 发现的真实类名

### 1. QSTile（控制中心磁贴）

**找到的类**：
```
✅ Lcom/android/systemui/qs/tileimpl/MiuiQSTileView;
✅ Lcom/android/systemui/qs/tileimpl/MiuiQSTileView$1;
✅ Lcom/android/systemui/qs/tileimpl/QSTileImpl;
✅ Lcom/android/systemui/plugins/qs/QSTileView;
```

**结论**：
- MIUI 使用 `MiuiQSTileView` 而不是标准的 `QSTileViewImpl`
- 包路径：`com.android.systemui.qs.tileimpl.MiuiQSTileView`

---

### 2. Blur（柔光玻璃）

**找到的类**：
```
✅ Lcom/android/systemui/statusbar/BlurUtils;
✅ Lcom/android/systemui/statusbar/notification/utils/BlurUtilsImpl;
```

**结论**：
- 使用标准的 `BlurUtils` 类
- 实现类：`BlurUtilsImpl`
- 包路径：`com.android.systemui.statusbar.BlurUtils`

---

### 3. Udfps（屏下指纹）

**找到的类**：
```
✅ Lcom/android/systemui/biometrics/UdfpsControllerOverlay;
✅ Lcom/android/systemui/biometrics/ui/binder/UdfpsTouchOverlayBinder;
✅ Lcom/android/systemui/deviceentry/ui/binder/UdfpsAccessibilityOverlayBinder;
```

**结论**：
- 使用 `UdfpsControllerOverlay` 和相关类
- 没有找到 `UdfpsKeyguardView`（可能被重命名或在其他DEX中）
- 包路径：`com.android.systemui.biometrics.*`

---

### 4. DashboardFragment（设置页面）

**找到的类**：
```
✅ Lcom/android/settings/dashboard/DashboardFragment;
✅ Lcom/android/settings/dashboard/RestrictedDashboardFragment;
✅ Lcom/android/settings/dashboard/CategoryManager;
```

**结论**：
- 使用标准的 `DashboardFragment`
- 包路径：`com.android.settings.dashboard.DashboardFragment`

---

### 5. StatusBar（状态栏）

**需要进一步搜索**：
- 需要查找 `PhoneStatusBarView` 或 `MiuiPhoneStatusBarView`

---

### 6. MediaControl（媒体控制）

**需要进一步搜索**：
- 需要查找 `MediaControlPanel` 或相关类

---

## 📋 需要更新的Hook模块

### ControlCenterHook.kt
```kotlin
// 旧的（错误）
val tileViewClass = "com.android.systemui.qs.tileimpl.QSTileViewImpl"

// 新的（正确）
val tileViewClass = "com.android.systemui.qs.tileimpl.MiuiQSTileView"
```

### ThemeBlurHook.kt
```kotlin
// 保持不变（正确）
val blurUtilsClass = "com.android.systemui.statusbar.BlurUtils"
```

### LockscreenHook.kt
```kotlin
// 旧的（错误）
val fingerprintViewClass = "com.android.systemui.biometrics.UdfpsKeyguardView"

// 新的（需要进一步确认）
val fingerprintViewClass = "com.android.systemui.biometrics.UdfpsControllerOverlay"
```

### SettingsInjectionHook.kt
```kotlin
// 保持不变（正确）
val dashboardFragmentClass = "com.android.settings.dashboard.DashboardFragment"
```

---

## 🔄 下一步

需要继续搜索的类：
1. StatusBarView 相关
2. MediaControlPanel 相关
3. NavigationBarView 相关
4. 确认指纹相关的完整类名

正在继续分析...
