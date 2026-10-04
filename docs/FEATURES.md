# 功能说明文档

## 一、系统交互功能

### 1. 独立 Hook 功能配置入口

**实现模块**: `SettingsInjectionHook.kt`

在小米设置主页面添加独立的 "AquaHyperOS" 入口，类似 WLAN、蓝牙的入口风格。

**配置路径**: 设置 → AquaHyperOS

**技术实现**:
- Hook `DashboardFragment.onCreatePreferences()`
- 动态注入 `Preference` 项到设置列表
- 支持点击跳转到配置界面

---

### 2. 控制中心自定义

**实现模块**: `ControlCenterHook.kt`

**功能**:
- ✅ **大磁贴**: 将控制中心磁贴尺寸放大 20%
- ✅ **大磁贴图标颜色**: 自定义磁贴图标颜色（支持 HEX 颜色值）
- ✅ **方形小磁贴**: 使用方形圆角磁贴样式（圆角半径 8dp）

**配置项**:
```json
{
  "controlCenter": {
    "largeTile": false,
    "squareTile": false,
    "customIconColor": false,
    "iconColor": "#FFFFFF"
  }
}
```

**Hook 点**:
- `QSTileViewImpl.onConfigurationChanged()` - 磁贴样式调整
- `QSIconView.setIcon()` - 图标颜色自定义

---

### 3. 第三方主题强制启用柔光玻璃

**实现模块**: `ThemeBlurHook.kt`

**功能**:
- ✅ **强制柔光玻璃**: 第三方主题也能使用系统柔光玻璃效果
- ✅ **焦点通知柔光玻璃**: 焦点通知背景启用模糊效果
- ✅ **悬浮通知柔光玻璃**: 悬浮通知（Heads-up）启用模糊效果

**配置项**:
```json
{
  "theme": {
    "forceBlur": false,
    "notificationFocusBlur": false,
    "notificationHeadsUpBlur": false
  }
}
```

**技术实现**:
- Hook `BlurUtils.supportsBlursOnWindows()` 强制返回 true
- 使用 Android 12+ 的 `RenderEffect.createBlurEffect()` 应用模糊
- 模糊半径: 25px

---

### 4. 锁屏功能

**实现模块**: `LockscreenHook.kt`

**功能**:
- ✅ **隐藏锁屏指纹图标**: 完全隐藏屏下指纹识别图标
- ✅ **隐藏指纹动画**: 禁用指纹识别时的动画效果
- ✅ **显示锁屏小白条**: 在锁屏界面显示导航栏（小白条）

**配置项**:
```json
{
  "lockscreen": {
    "hideFingerprintIcon": false,
    "hideFingerprintAnimation": false,
    "showNavigationBar": false
  }
}
```

**Hook 点**:
- `UdfpsKeyguardView.setVisibility()` - 指纹图标可见性
- `UdfpsView.onIlluminatedRunnable()` - 指纹动画
- `NavigationBarView.onFinishInflate()` - 导航栏显示

---

### 5. 控制中心二级界面 5G 开关

**实现模块**: `ControlCenterHook.kt`

**功能**:
- 🚧 **5G 开关**: 在网络设置二级界面添加 5G 开关（待完整实现）

**配置项**:
```json
{
  "controlCenter": {
    "enable5GSwitch": false
  }
}
```

**Hook 点**:
- `NetworkDetailView.onFinishInflate()` - 注入 5G 开关控件

---

### 6. 隐藏本机权益及商店入口

**实现模块**: `SettingsAppHook.kt`

**功能**:
- ✅ **隐藏本机权益**: 移除设置中的本机权益入口
- ✅ **隐藏权益商店**: 移除设置中的权益商店入口

**配置项**:
```json
{
  "settingsApp": {
    "hideBenefits": false,
    "hideBenefitsStore": false
  }
}
```

**移除的键名**:
- `device_benefits`, `mi_benefits`, `xiaomi_benefits`, `miui_benefits`
- `benefits_store`, `mi_store`, `xiaomi_store`

---

## 二、灵动岛歌词功能

**实现模块**: `DynamicIslandLyricsHook.kt`

### 功能特性

#### 1. 灵动岛歌词显示
- ✅ **无需 Hook 音乐软件**: 通过系统 MediaSession 直接获取音乐信息
- ✅ **自动显示/隐藏**: 播放音乐时自动显示，暂停时隐藏
- ✅ **实时更新**: 切换歌曲时自动更新显示

#### 2. 组件自定义
- ✅ **显示位置**: 左侧/居中/右侧
- ✅ **文字大小**: 10-20sp 可调
- ✅ **自定义字体**: 支持加载 TTF/OTF 字体文件

#### 3. 根据专辑封面取色
- ✅ **自动取色**: 使用 Palette 从专辑封面提取主色调
- ✅ **动态颜色**: 每首歌曲颜色独立，随封面变化

#### 4. 配置选项

```json
{
  "dynamicIslandLyrics": {
    "enabled": false,
    "position": "center",
    "textSize": 14,
    "font": "default",
    "useAlbumColor": false,
    "color": "#FFFFFF"
  }
}
```

**配置说明**:
- `enabled`: 是否启用灵动岛歌词
- `position`: 显示位置 (left/center/right)
- `textSize`: 文字大小 (10-20)
- `font`: 字体路径 (default 为系统默认)
- `useAlbumColor`: 是否使用专辑封面颜色
- `color`: 默认文字颜色 (HEX 格式)

### 技术实现

**数据来源**:
- 通过 `MediaControlPanel.bindPlayer()` Hook 获取音乐信息
- 从 `MediaData` 提取歌曲名、艺术家、专辑封面

**UI 注入**:
- Hook `PhoneStatusBarView.onFinishInflate()`
- 动态创建 `TextView` 并添加到状态栏
- 使用 `FrameLayout` 容器控制位置

**颜色提取**:
```kotlin
Palette.from(artwork).generate { palette ->
    palette?.dominantSwatch?.let { swatch ->
        lyricsView.setTextColor(swatch.rgb)
    }
}
```

---

## 配置界面预览

### 设置页面结构

```
AquaHyperOS

【核心破解】
  ☑ 签名验证绕过
  ☐ 权限限制解除

【状态栏】
  ☑ 自定义图标
  ⚙ 电池样式: 百分比

【桌面启动器】
  ☑ 自定义网格
  ━━●━━ 网格行数: 6
  ━━━●━ 网格列数: 5

【控制中心】
  ☐ 大磁贴
  ☐ 方形小磁贴
  ☐ 自定义图标颜色
  ☐ 5G 开关

【主题美化】
  ☐ 强制柔光玻璃
  ☐ 焦点通知柔光玻璃
  ☐ 悬浮通知柔光玻璃

【锁屏】
  ☐ 隐藏指纹图标
  ☐ 隐藏指纹动画
  ☐ 显示小白条

【设置应用】
  ☐ 隐藏本机权益
  ☐ 隐藏权益商店

【灵动岛歌词】
  ☐ 启用灵动岛歌词
  ⚙ 显示位置: 居中
  ━━━●━ 文字大小: 14
  ☐ 使用专辑颜色

【关于】
  版本: 1.0.0 (100)
  Symphony Framework: 1.0.0+
```

---

## 使用注意事项

### 兼容性
- **Android 版本**: Android 13+ (API 33+)
- **系统版本**: HyperOS 1.0+ / MIUI 14+
- **Root 方案**: Magisk / KernelSU
- **框架依赖**: Symphony Framework

### 配置存储
所有配置通过 SharedPreferences 存储：
- **路径**: `/data/data/com.android.settings/shared_prefs/aquahyperos_settings.xml`
- **权限**: `MODE_WORLD_READABLE` (供 SystemUI 读取)

### 日志调试
```bash
# 查看所有 AquaHyperOS 日志
adb logcat | grep "AquaHyperOS"

# 按模块查看
adb logcat | grep "AquaHyperOS-ControlCenter"
adb logcat | grep "AquaHyperOS-DynamicIsland"
adb logcat | grep "AquaHyperOS-Lockscreen"
```

### 重启生效
修改配置后需要重启对应进程：
- **SystemUI 相关**: 重启 SystemUI 或重启设备
- **设置应用**: 清除设置应用数据或重启设备

---

## 已知限制

### 待完善功能
- [ ] 5G 开关完整实现（需要动态创建 Switch 控件）
- [ ] 真实歌词显示（需要 LRC 文件或歌词 API）
- [ ] 灵动岛歌词滚动效果
- [ ] 设置搜索索引支持

### 可能的问题
- 部分设备的指纹图标类名可能不同
- 第三方主题柔光玻璃效果因设备而异
- 灵动岛歌词当前仅显示歌曲名和艺术家，未实现逐句歌词

---

## 未来计划
- [ ] 支持导入/导出配置
- [ ] 添加主题切换功能
- [ ] 实现真正的逐句歌词显示
- [ ] 支持更多自定义选项
- [ ] 优化性能和稳定性
