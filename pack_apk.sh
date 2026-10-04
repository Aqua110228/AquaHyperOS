#!/bin/bash
set -e

echo "📦 开始打包 AquaHyperOS APK..."
echo ""

# 创建临时目录
TEMP_DIR="apk_temp"
rm -rf "$TEMP_DIR"
mkdir -p "$TEMP_DIR"

# 复制源文件
echo "📁 复制源文件..."
cp -r module "$TEMP_DIR/"

# 创建 APK 结构
echo "🏗️  创建 APK 结构..."
mkdir -p "$TEMP_DIR/apk"
cp module/AndroidManifest.xml "$TEMP_DIR/apk/"
mkdir -p "$TEMP_DIR/apk/res"
cp -r module/res/* "$TEMP_DIR/apk/res/" 2>/dev/null || true

# 编译 Kotlin 到 Java (需要 kotlinc)
echo "🔨 编译 Kotlin 代码..."
if command -v kotlinc &> /dev/null; then
    find module -name "*.kt" -exec kotlinc {} -include-runtime -d "$TEMP_DIR/classes.jar" \;
    echo "✅ Kotlin 编译完成"
else
    echo "⚠️  kotlinc 未安装，跳过编译"
fi

echo ""
echo "📦 APK 结构已准备，但需要 Android SDK 才能完整编译"
echo ""
echo "请使用以下方法之一编译："
echo "  1. 使用 Android Studio 打开本项目"
echo "  2. 使用 Gradle: ./gradlew assembleRelease"
echo "  3. 使用 aapt2 + d8 手动打包"
echo ""

rm -rf "$TEMP_DIR"
