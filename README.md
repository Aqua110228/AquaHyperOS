# AquaHyperOS

HyperOS 系统优化 Xposed 模块

## 功能特性

### 核心破解
- 签名验证绕过
- 权限检查绕过
- 系统完整性检查绕过

### 状态栏自定义
- 自定义状态栏高度
- 自定义网络速度显示位置
- 隐藏状态栏元素（电量、时间等）
- 自定义状态栏图标颜色

### 控制中心自定义
- 自定义快捷开关布局
- 隐藏不需要的快捷开关
- 自定义控制中心背景模糊度
- 调整亮度条样式

### 锁屏功能
- 自定义锁屏时钟样式
- 隐藏锁屏充电动画
- 自定义锁屏快捷方式
- 调整锁屏通知样式

### 主题美化
- 自定义主题色
- 调整圆角半径
- 自定义字体
- 透明度调节

### 其他功能
- 完整的日志系统
- 日志查看器（内置）
- Hook 验证工具
- 设置界面（从系统设置调用）

## 安装说明

### 前置要求
- HyperOS 系统
- LSPosed 框架
- Root 权限

### 安装步骤
1. 下载最新的 APK 文件
2. 安装 APK
3. 在 LSPosed 管理器中激活模块
4. 选择作用域：
   - `android`（系统框架）
   - `com.android.systemui`（系统界面）
   - `com.android.settings`（系统设置）
5. 重启设备使模块生效

## 使用说明

### 访问设置
从系统设置中找到"AquaHyperOS"选项，点击进入模块设置界面。

### 查看日志
日志文件位置：`/sdcard/AquaHyperOS/logs/`
- 每次启动创建新的日志文件
- 自动保留最近 10 个日志文件
- 可通过模块设置界面查看日志

### Hook 验证
模块提供内置的 Hook 验证工具，可检查：
- 目标类是否存在
- 目标方法是否存在
- Hook 是否成功安装

## 技术说明

### 项目结构
```
app/src/main/java/com/aqua/hyperos/
├── HyperOSModule.kt           # Xposed 入口
├── hooks/                      # Hook 实现
│   ├── CoreBypassHook.kt      # 核心破解
│   ├── StatusBarHook.kt       # 状态栏
│   ├── ControlCenterHook.kt   # 控制中心
│   ├── LockScreenHook.kt      # 锁屏
│   ├── ThemeHook.kt           # 主题
│   └── ...
├── ui/                        # 界面
│   └── SettingsActivity.kt   # 设置界面
└── utils/                     # 工具类
    ├── Logger.kt             # 日志系统
    └── HookValidator.kt      # Hook 验证
```

### 编译说明
本项目采用直接编译方式，完全绕过 Gradle：
1. 使用 `kotlinc` 直接编译 Kotlin 代码
2. 使用 `d8` 转换为 DEX
3. 使用 `aapt` 打包 APK
4. 使用 `apksigner` 签名

详细编译流程见 `.github/workflows/build.yml`

## 版本历史

### 26w40c (2024-10-04)
- 修复 xposed_init 文件格式问题
- 优化 APK 打包流程，确保 assets 正确包含
- 删除冗余的重复文件
- 改进模块识别稳定性

### 26w40b (2024-10-04)
- 添加 MainHook.kt 入口类实现
- 添加 xposed_init 配置文件
- 实现完整的 Xposed 模块架构
- 支持 LSPosed 框架检测和激活

### 26w40a (2024-10-04)
- 初始发布版本
- 实现核心功能模块
- 添加完整日志系统
- 支持状态栏、控制中心、锁屏、主题等自定义功能

## 注意事项

- 本模块仅供学习交流使用
- 使用本模块造成的任何问题由用户自行承担
- 建议在使用前备份重要数据
- 不同 HyperOS 版本可能需要适配

## 开源协议

本项目采用 MIT 协议开源。

## 致谢

- LSPosed 团队提供的 Xposed 框架
- HyperOS 系统开发团队
- 所有贡献者和测试者
