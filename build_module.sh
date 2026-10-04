#!/bin/bash

echo "🚀 开始编译 AquaHyperOS 模块..."
echo ""

# 检查环境
if [ ! -f "build.gradle" ]; then
    echo "❌ 错误：请在项目根目录运行此脚本"
    exit 1
fi

# 清理旧文件
echo "🧹 清理旧文件..."
rm -rf build/
rm -rf app/build/

# 编译项目
echo "🔨 编译项目..."
./gradlew clean assembleRelease

if [ $? -ne 0 ]; then
    echo "❌ 编译失败"
    exit 1
fi

# 查找生成的 APK
APK_PATH=$(find app/build/outputs/apk/release -name "*.apk" | head -1)

if [ -z "$APK_PATH" ]; then
    echo "❌ 未找到生成的 APK"
    exit 1
fi

echo "✅ 编译成功：$APK_PATH"

# 重命名
OUTPUT="AquaHyperOS-v1.0.0.apk"
cp "$APK_PATH" "$OUTPUT"

echo ""
echo "📦 生成的文件："
echo "  $OUTPUT"
echo ""
echo "📊 文件大小："
ls -lh "$OUTPUT"
echo ""
echo "✅ 打包完成！"
echo ""
echo "📥 安装方法："
echo "  adb install $OUTPUT"
echo ""
echo "📚 查看集成指南："
echo "  cat BUILD_AND_INTEGRATION_GUIDE.md"
