# AquaHyperOS 更新日志

## v1.0.0 (2024-10-03)

### 一、新增功能（系统交互）

#### 1. 新增独立 Hook 功能配置入口
- ✅ 在小米设置主页面添加 "AquaHyperOS" 独立入口
- ✅ 与 WLAN、蓝牙等系统入口风格一致
- ✅ 支持完整的配置界面

#### 2. 控制中心自定义
- ✅ 新增大磁贴功能（磁贴尺寸放大 20%）
- ✅ 新增方形小磁贴（圆角半径 8dp）
- ✅ 新增自定义磁贴图标颜色
- 🚧 新增控制中心二级界面 5G 开关（待完善）

#### 3. 主题美化增强
- ✅ 新增第三方主题强制启用柔光玻璃
- ✅ 新增焦点通知柔光玻璃效果
- ✅ 新增悬浮通知柔光玻璃效果

#### 4. 锁屏功能
- ✅ 新增隐藏锁屏指纹图标
- ✅ 新增隐藏指纹识别动画
- ✅ 新增显示锁屏小白条（导航栏）

#### 5. 设置应用优化
- ✅ 新增隐藏本机权益入口开关
- ✅ 新增隐藏本机权益商店入口开关

### 二、新增功能（灵动岛歌词）

#### 1. 灵动岛歌词核心
- ✅ 新增灵动岛歌词显示（无需 Hook 音乐软件）
- ✅ 通过系统 MediaSession 自动获取音乐信息
- ✅ 自动显示/隐藏，跟随播放状态

#### 2. 组件自定义
- ✅ 新增灵动岛歌词组件位置自定义（左/中/右）
- ✅ 新增文字大小调节（10-20sp）
- ✅ 新增自定义字体支持（TTF/OTF）

#### 3. 视觉效果
- ✅ 新增根据歌曲封面取色设置歌词颜色
- ✅ 动态颜色随专辑封面变化
- ✅ 支持手动指定默认颜色

#### 4. Hook 入口
- ✅ 新增设置自定义 Hook 入口位置

### 三、技术实现

#### Hook 模块
共计 **10 个** Hook 模块：
1. `CorePatchHook.kt` - 核心破解
2. `StatusBarHook.kt` - 状态栏自定义
3. `LauncherHook.kt` - 桌面启动器
4. `SettingsInjectionHook.kt` - 设置页面注入
5. `SettingsUIHook.kt` - 设置界面构建
6. `ControlCenterHook.kt` - 控制中心自定义
7. `ThemeBlurHook.kt` - 主题柔光玻璃
8. `LockscreenHook.kt` - 锁屏功能
9. `SettingsAppHook.kt` - 设置应用优化
10. `DynamicIslandLyricsHook.kt` - 灵动岛歌词

#### 目标包
- `com.android.systemui` - 系统界面
- `com.android.settings` - 设置应用
- `com.miui.home` - 桌面启动器
- `android` - 系统核心

#### 配置界面
- **8 个功能分类**，共计 **20+ 个配置项**
- 完整的 PreferenceScreen 动态构建
- 支持 Switch、List、SeekBar 等多种控件

### 四、已知问题

#### 待完善
- [ ] 控制中心 5G 开关需要完整实现
- [ ] 灵动岛歌词仅显示歌曲信息，未实现逐句歌词
- [ ] 设置搜索索引功能待实现

#### 可能的兼容性问题
- 部分设备指纹图标类名可能不同
- 第三方主题柔光玻璃效果因设备而异
- 某些 ROM 定制版本可能无法正确识别 Fragment 类名

### 五、配置文件

#### 新增配置项
```json
{
  "controlCenter": {
    "largeTile": false,
    "squareTile": false,
    "customIconColor": false,
    "iconColor": "#FFFFFF",
    "enable5GSwitch": false
  },
  "theme": {
    "forceBlur": false,
    "notificationFocusBlur": false,
    "notificationHeadsUpBlur": false
  },
  "lockscreen": {
    "hideFingerprintIcon": false,
    "hideFingerprintAnimation": false,
    "showNavigationBar": false
  },
  "settingsApp": {
    "hideBenefits": false,
    "hideBenefitsStore": false
  },
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

### 六、依赖要求

- **Android 版本**: Android 13+ (API 33+)
- **系统版本**: HyperOS 1.0+ / MIUI 14+
- **Root 方案**: Magisk / KernelSU
- **框架**: Symphony Framework 1.0.0+

### 七、安装说明

1. 确保已安装 Symphony Framework
2. 通过 Magisk/KernelSU 刷入模块
3. 重启设备
4. 在 Symphony 管理器中启用 AquaHyperOS 模块
5. 进入设置 → AquaHyperOS 配置功能
6. 再次重启设备使配置生效

### 八、调试日志

查看模块运行日志：
```bash
adb logcat | grep "AquaHyperOS"
```

按模块查看：
```bash
adb logcat | grep "AquaHyperOS-ControlCenter"
adb logcat | grep "AquaHyperOS-DynamicIsland"
adb logcat | grep "AquaHyperOS-Lockscreen"
adb logcat | grep "AquaHyperOS-ThemeBlur"
```

---

## 开发团队

**AquaHyperOS Team**

## 许可协议

待补充
