# 📋 APK 需求清单

## ✅ 已分析的 APK（4个）

1. ✅ **系统界面_17.03.260226.r.apk** (SystemUI)
   - 用于：控制中心、状态栏、锁屏、柔光玻璃、灵动岛歌词
   - 状态：已完成

2. ✅ **设置_17.apk** (Settings)
   - 用于：设置注入、配置界面
   - 状态：已完成

3. ✅ **小米设置_16.4.260829.00.apk** (MiSettings)
   - 用于：验证设置相关功能
   - 状态：已完成

4. ✅ **系统界面组件_18.3.2.22.0.apk** (SystemUI Plugin)
   - 用于：辅助验证
   - 状态：已完成

---

## ⚠️ 需要额外 APK 的功能（2个）

### 1. LauncherHook - 桌面启动器
**当前状态**: TODO 占位符

**需要的 APK**:
```
❓ MiuiHome.apk 或 系统桌面.apk（完整版，需包含 DEX 文件）
```

**包名**: `com.miui.home`

**提取命令**:
```bash
adb shell pm path com.miui.home
adb pull /system/priv-app/MiuiHome/MiuiHome.apk
```

**需要查找的类**:
- `com.miui.home.launcher.Workspace`
- `com.miui.home.launcher.CellLayout`
- `com.miui.home.launcher.DeviceProfile`
- 网格配置相关类

**功能**:
- 自定义桌面网格（行数/列数）
- 图标大小调整
- 图标间距设置

**优先级**: 🟡 中等（桌面功能）

---

### 2. StatusBarHook - 状态栏自定义
**当前状态**: TODO 占位符

**需要的 APK**:
```
✅ 已有：系统界面_17.03.260226.r.apk
```

**状态**: **不需要新 APK！可以直接实现**

**需要查找的类**:
- ✅ `com.android.systemui.statusbar.phone.MiuiPhoneStatusBarView`（已找到）
- ✅ `com.android.systemui.statusbar.phone.MiuiKeyguardStatusBarView`（已找到）

**功能**:
- 状态栏高度调整
- 状态栏背景透明度
- 状态栏图标自定义

**优先级**: 🟢 高（可立即实现）

---

## ✅ 不需要额外 APK 的功能（1个）

### SettingsAppHook - 设置应用优化
**当前状态**: 待测试

**需要的 APK**:
```
✅ 已有：设置_17.apk
```

**状态**: **不需要新 APK！需要测试验证**

**功能**:
- 隐藏本机权益入口
- 隐藏权益商店入口

**需要做的**:
- 在真机上测试 Preference key 名称是否正确
- 根据日志调整 key 名称

**优先级**: 🟡 中等（需测试验证）

---

## 📊 总结

### 必需的 APK
```
❓ MiuiHome.apk（完整版，需包含 DEX）
```

### 可选的 APK
```
无
```

### 可以立即实现的功能
```
✅ StatusBarHook - 不需要新 APK
```

### 需要测试的功能
```
⚠️ SettingsAppHook - 需要在真机上测试
```

---

## 📝 关于系统桌面.apk

你之前提供的 `系统桌面_RELEASE-8.01.02.7722-260904-09221533-R.apk`：
- ❌ 是 Flutter 应用，没有 DEX 文件
- ❌ 无法用于 Hook 分析
- ❓ 可能需要重新提取完整版本

**建议**:
使用 adb 直接提取，确保是原始完整版本：
```bash
adb pull $(adb shell pm path com.miui.home | cut -d: -f2)
```

---

## 🎯 优先级建议

### 立即可以做（不需要 APK）
1. ✅ **StatusBarHook** - 实现状态栏自定义
2. ⚠️ **SettingsAppHook** - 在真机测试验证

### 需要 APK 才能做
3. ❓ **LauncherHook** - 需要 MiuiHome.apk（完整版）

---

## 🚀 当前项目完成度

### 已就绪模块（8/10）
1. ✅ CorePatchHook（已实现）
2. ✅ SettingsInjectionHook
3. ✅ SettingsUIHook
4. ✅ ControlCenterHook
5. ✅ ThemeBlurHook
6. ✅ LockscreenHook
7. ✅ DynamicIslandLyricsHook
8. ✅ CorePatchHook

### 待实现模块（2/10）
9. ⚠️ StatusBarHook（可立即实现）
10. ❓ LauncherHook（需要 MiuiHome.apk）

### 待测试模块
- SettingsAppHook

**可用性**: 80% → 90%（实现 StatusBarHook 后）

---

## 🎁 额外建议

如果你想要更完整的功能，可以考虑提供：

### 可选 APK
1. **安全中心.apk** (`com.miui.securitycenter`)
   - 用于：绕过安全检查、权限管理优化
   
2. **系统更新.apk** (`com.android.updater`)
   - 用于：屏蔽系统更新提示

3. **小米云服务.apk** (`com.miui.cloudservice`)
   - 用于：云服务功能定制

**优先级**: 🔵 低（增值功能，非必需）

---

## ✅ 结论

**你只需要提供 1 个 APK**:
```
📦 MiuiHome.apk（完整版，包含 DEX 文件）
```

**或者**:
```
🚀 不提供新 APK，我立即实现 StatusBarHook
   项目完成度：80% → 90%
```

选择哪个？🤔
