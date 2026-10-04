# Hook功能说明

## 已实现的Hook

### 1. StatusBarHook (状态栏)

**目标包**: `com.android.systemui`

**功能**:
- ✅ 状态栏图标自定义
- ✅ 图标颜色修改
- ✅ 电池样式切换
- ⏳ 状态栏布局调整（待实现）

**配置项**:
```json
{
  "statusBar": {
    "enabled": true,
    "customIcons": true,
    "iconColor": "#FFFFFF",
    "batteryStyle": "percentage"
  }
}
```

### 2. CorePatchHook (核心破解)

**目标包**: `android`

**功能**:
- ✅ 签名验证绕过
- ⏳ 权限检查Hook（待实现）
- ⏳ API限制解除（待实现）

**配置项**:
```json
{
  "corePatch": {
    "enabled": true,
    "bypassSignature": true,
    "unlockPermissions": false
  }
}
```

### 3. LauncherHook (桌面启动器)

**目标包**: `com.miui.home`

**功能**:
- ✅ 桌面网格自定义
- ⏳ 应用抽屉增强（待实现）
- ⏳ 手势功能扩展（待实现）

**配置项**:
```json
{
  "launcher": {
    "enabled": true,
    "customGrid": true,
    "gridRows": 6,
    "gridColumns": 5
  }
}
```

### 4. SettingsInjectionHook (设置注入)

**目标包**: `com.android.settings`

**功能**:
- ✅ 在设置主页面添加 AquaHyperOS 入口
- ✅ 动态注入 Preference 项
- ✅ 支持点击跳转配置页面
- ⏳ 搜索索引支持（待实现）

**配置项**:
```json
{
  "settings": {
    "injectionEnabled": true,
    "showInMainSettings": true,
    "settingsPosition": "top"
  }
}
```

### 5. SettingsUIHook (设置界面)

**目标包**: `com.android.settings`

**功能**:
- ✅ 动态构建配置界面
- ✅ 核心破解功能开关
- ✅ 状态栏配置选项
- ✅ 桌面启动器配置
- ✅ 模块信息展示

**支持的控件**:
- SwitchPreference（开关）
- ListPreference（列表选择）
- SeekBarPreference（滑动条）
- PreferenceCategory（分类）

## 计划中的Hook

### 通知系统Hook
- 通知样式自定义
- 通知优先级调整
- 通知分组管理

### 相机增强Hook
- 解锁隐藏功能
- 参数调节扩展

### 电源管理Hook
- 后台限制解除
- 性能模式增强

## Hook开发规范

1. **命名规范**: `XxxHook.kt`
2. **包名**: `com.aqua.hyperos.hooks`
3. **必须实现**: `IXposedHookLoadPackage`
4. **异常处理**: 所有Hook逻辑必须try-catch
5. **日志输出**: 使用统一的日志工具类

## 测试清单

- [ ] Hook是否正常加载
- [ ] 目标应用是否正常运行
- [ ] 配置项是否生效
- [ ] 系统应用更新后是否兼容
- [ ] 多设备适配测试
