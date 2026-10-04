AquaHyperOS 打包文件说明
=========================

本目录包含集成所需的所有文件。

📦 文件清单：

1. AquaHyperOS.apk (需要编译)
   - 编译命令：./gradlew assembleRelease
   - 生成位置：app/build/outputs/apk/release/
   - 无桌面图标，只能从系统设置进入

2. SETTINGS_XML_ENTRY.xml
   - Settings.apk 入口配置
   - 添加到 Settings.apk 的 res/xml/dashboard_main.xml

3. aqua_permissions.xml
   - 权限配置
   - 复制到 /system/etc/permissions/com.aqua.hyperos.xml

4. FINAL_INTEGRATION_GUIDE.md
   - 完整集成指南（320行）
   - 包含所有详细步骤

5. BUILD_SUMMARY.md
   - 打包完成报告
   - 文件位置说明

📍 集成位置：

推荐：system/priv-app/ (系统分区)
  └── AquaHyperOS/
      └── AquaHyperOS.apk

备选：product/priv-app/
  └── AquaHyperOS/
      └── AquaHyperOS.apk

✅ 必须修改：Settings.apk
  添加入口到 res/xml/dashboard_main.xml

✅ 必须添加：权限配置
  system/etc/permissions/com.aqua.hyperos.xml

❌ 不需要修改：
  - SystemUI.apk (保持不动)
  - MiuiHome.apk (保持不动)
  - framework.jar (保持不动)

详细步骤请查看 FINAL_INTEGRATION_GUIDE.md
