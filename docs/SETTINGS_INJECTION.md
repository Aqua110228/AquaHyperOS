# 设置页面注入说明

## 功能概述

AquaHyperOS 通过 Hook 小米设置应用，在设置主页面中添加独立的配置入口，用户可以像访问 WLAN、蓝牙等功能一样便捷地访问 AquaHyperOS 的配置界面。

## 实现原理

### 1. 入口注入 (SettingsInjectionHook)

**目标**: `com.android.settings`

**Hook点**: `DashboardFragment.onCreatePreferences()`

**实现逻辑**:
- 在设置主页面加载时，动态注入一个新的 Preference 项
- 设置标题为 "AquaHyperOS"，摘要为 "官改功能配置与管理"
- 使用系统图标，保持视觉一致性
- 设置较高的优先级，使入口显示在列表前部

**点击行为**:
- 主方案：启动 SubSettings Activity，加载自定义 Fragment
- 降级方案：显示对话框展示模块信息（当自定义页面加载失败时）

### 2. 界面构建 (SettingsUIHook)

**目标**: `com.android.settings`

**Hook点**: `PreferenceFragmentCompat.onCreatePreferences()`

**实现逻辑**:
- 检测到 AquaHyperOSSettings Fragment 加载时触发
- 动态构建完整的设置界面，包括：
  - PreferenceCategory（分类）
  - SwitchPreference（开关选项）
  - ListPreference（列表选择）
  - SeekBarPreference（滑动条）

**配置分类**:

#### 核心破解
- 签名验证绕过 (Switch)
- 权限限制解除 (Switch)

#### 状态栏
- 自定义图标 (Switch)
- 电池样式 (List: 默认/百分比/隐藏)

#### 桌面启动器
- 自定义网格 (Switch)
- 网格行数 (SeekBar: 4-8)
- 网格列数 (SeekBar: 3-6)

#### 关于
- 版本信息
- Framework 版本

## 技术要点

### Preference 创建

所有 UI 组件通过反射动态创建，避免编译期依赖：

```kotlin
val preferenceClass = XposedHelpers.findClass(
    "androidx.preference.Preference",
    context.classLoader
)
val preference = XposedHelpers.newInstance(preferenceClass, context)
```

### 配置持久化

配置项通过 SharedPreferences 自动保存，键名格式：
- `signature_bypass` - 签名验证绕过
- `permission_unlock` - 权限限制解除
- `statusbar_custom_icons` - 自定义图标
- `statusbar_battery_style` - 电池样式
- `launcher_custom_grid` - 自定义网格
- `launcher_grid_rows` - 网格行数
- `launcher_grid_columns` - 网格列数

### 搜索索引

计划支持在设置搜索框中输入 "AquaHyperOS" 直接跳转（待实现）。

## 界面效果

```
设置
├── 连接与共享
├── AquaHyperOS              ← 新增入口
│   └── 官改功能配置与管理
├── WLAN
├── 蓝牙
└── ...
```

点击 "AquaHyperOS" 后进入：

```
AquaHyperOS

【核心破解】
系统级限制解除
  ✓ 签名验证绕过
    允许安装任意签名的应用
  ☐ 权限限制解除
    解除部分系统权限限制

【状态栏】
图标与样式自定义
  ✓ 自定义图标
    启用状态栏图标自定义功能
  ⚙ 电池样式
    百分比

【桌面启动器】
桌面功能增强
  ✓ 自定义网格
    自定义桌面图标行列数
  ━━●━━ 网格行数: 6
  ━━━●━ 网格列数: 5

【关于】
模块信息
  版本
    1.0.0 (100)
  Symphony Framework
    1.0.0+
```

## 配置文件

### module/config/default.json

```json
{
  "settings": {
    "injectionEnabled": true,
    "showInMainSettings": true,
    "settingsPosition": "top",
    "showSearchIndex": true
  }
}
```

**配置项说明**:
- `injectionEnabled` - 是否启用设置注入
- `showInMainSettings` - 是否显示在设置主页面
- `settingsPosition` - 显示位置 (top/bottom)
- `showSearchIndex` - 是否添加搜索索引

## 兼容性

### 支持的系统版本
- HyperOS 1.0+
- MIUI 14+
- Android 13 (API 33)+

### 已测试设备
- 待补充

### 已知问题
- [ ] 部分 MIUI 定制版本可能无法正确识别 Fragment 类名
- [ ] 搜索索引功能尚未完整实现
- [ ] 图标可能在不同主题下显示异常

## 调试日志

启用 debug 模式后，可通过 logcat 查看详细日志：

```bash
adb logcat | grep "AquaHyperOS-Settings"
```

**关键日志**:
- `开始注入设置页面` - Hook 开始执行
- `设置列表 Hook 成功` - 入口注入成功
- `成功注入 AquaHyperOS 设置入口` - Preference 添加成功
- `启动配置页面` - 用户点击入口
- `AquaHyperOS 设置界面构建完成` - 配置界面加载完成

## 未来计划

- [ ] 添加主题切换功能
- [ ] 实现配置导入/导出
- [ ] 添加模块更新检测
- [ ] 支持配置云同步
- [ ] 添加更多自定义选项
- [ ] 实现完整的搜索索引
