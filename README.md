# AquaHyperOS

HyperOS 深度定制模块 - 状态栏、控制中心、锁屏、主题等全方位自定义

## ✨ 功能特性

### 核心破解
- ✅ 签名验证绕过
- ✅ 权限检查绕过

### 状态栏
- ✅ 自定义背景颜色
- ✅ 自定义透明度
- ✅ 自定义高度

### 控制中心
- ✅ 大磁贴模式
- ✅ 方形磁贴
- ✅ 自定义图标颜色

### 锁屏
- ✅ 隐藏指纹图标
- ✅ 隐藏指纹动画
- ✅ 显示导航栏

### 主题
- ✅ 强制柔光玻璃效果

### 日志系统
- ✅ 完整中文日志
- ✅ 详细错误追踪
- ✅ 自动保存到 `/sdcard/AquaHyperOS/logs/`

## 📦 安装方式

### 方式 1: LSPosed 模块（推荐测试）

1. 下载 [最新 Release](https://github.com/你的用户名/AquaHyperOS/releases)
2. 安装 APK
3. 在 LSPosed 中激活模块
4. 选择作用域：
   - `android` (系统框架)
   - `com.android.systemui` (系统界面)
   - `com.android.settings` (设置)
5. 重启设备

### 方式 2: 集成到官改 ROM

参考 [dist/FINAL_INTEGRATION_GUIDE.md](dist/FINAL_INTEGRATION_GUIDE.md)

**位置**：`system/priv-app/AquaHyperOS/`

**必须修改**：Settings.apk（添加入口）

## 🎯 使用说明

### 打开设置

- **系统设置**：打开设置 → 第一位的 "AquaHyperOS"
- **桌面图标**：无（按设计不在桌面显示）

### 配置功能

1. 点击各开关启用/禁用功能
2. 调整参数（颜色、透明度、高度等）
3. 保存配置（需要 LSPosed 激活才能生效）

### 查看日志

日志文件位置：`/sdcard/AquaHyperOS/logs/aqua_YYYYMMDD.log`

```bash
# 查看日志
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log

# 实时监控
adb shell tail -f /sdcard/AquaHyperOS/logs/aqua_*.log
```

## 🔧 开发构建

### 环境要求

- Android Studio 最新版
- JDK 17
- Android SDK 34

### 编译步骤

```bash
# 克隆项目
git clone https://github.com/你的用户名/AquaHyperOS.git
cd AquaHyperOS

# 编译
./gradlew assembleRelease

# 输出位置
# app/build/outputs/apk/release/AquaHyperOS-v1.0.0.apk
```

### 自动构建

本项目配置了 GitHub Actions，推送代码后自动编译：

1. 推送代码到 GitHub
2. 等待 Actions 完成（约 5-10 分钟）
3. 在 Actions 页面下载 Artifacts
4. 或在 Releases 页面下载

## 📊 项目结构

```
AquaHyperOS/
├── module/
│   ├── hooks/          # Hook 模块
│   ├── ui/             # 设置界面
│   ├── utils/          # 工具类
│   └── AndroidManifest.xml
├── dist/               # 集成文件
│   ├── SETTINGS_XML_ENTRY.xml
│   ├── aqua_permissions.xml
│   └── FINAL_INTEGRATION_GUIDE.md
├── .github/
│   └── workflows/
│       └── build.yml   # 自动构建配置
├── build.gradle
└── README.md
```

## 📝 代码统计

- **总代码行数**：915 行 Kotlin
- **功能模块**：10 个
- **配置项**：42 个
- **文档**：10+ 个

## 🐛 故障排除

### 模块未激活

检查 LSPosed：
```bash
adb shell ls -la /system/priv-app/AquaHyperOS/
```

### 功能不生效

查看日志：
```bash
adb shell cat /sdcard/AquaHyperOS/logs/aqua_*.log
```

### 设置入口不显示

确认：
- LSPosed 已激活模块
- 已选择 `com.android.settings` 作用域
- 已重启设备

## 📚 文档

- [完整集成指南](dist/FINAL_INTEGRATION_GUIDE.md)
- [日志系统说明](LOG_SYSTEM_GUIDE.md)
- [功能评估报告](EFFECTIVENESS_ASSESSMENT.md)

## 🤝 贡献

欢迎提交 Issue 和 Pull Request！

## 📄 许可证

本项目仅供学习交流使用。

## ⚠️ 免责声明

本模块需要 LSPosed 框架支持。
使用本模块造成的任何问题，开发者不承担责任。
请在测试设备上使用。

## 🎉 致谢

- LSPosed 框架
- Xposed API
- Android Open Source Project

---

**版本**: 1.0.0
**更新时间**: 2024-10-04
