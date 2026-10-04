#!/bin/bash
# AquaHyperOS 构建脚本

set -e

echo "开始构建 AquaHyperOS 模块..."

# 项目根目录
PROJECT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
BUILD_DIR="$PROJECT_ROOT/build"
OUTPUT_DIR="$PROJECT_ROOT/output"

# 清理旧构建
rm -rf "$BUILD_DIR" "$OUTPUT_DIR"
mkdir -p "$BUILD_DIR" "$OUTPUT_DIR"

# 复制模块文件
echo "复制模块文件..."
cp -r "$PROJECT_ROOT/module" "$BUILD_DIR/"
cp -r "$PROJECT_ROOT/framework" "$BUILD_DIR/"
cp -r "$PROJECT_ROOT/assets" "$BUILD_DIR/"
cp "$PROJECT_ROOT/module.prop" "$BUILD_DIR/"

# 编译Kotlin代码 (如果需要)
# echo "编译Kotlin代码..."
# kotlinc module/hooks/*.kt -include-runtime -d build/hooks.jar

# 打包模块
echo "打包模块..."
cd "$BUILD_DIR"
zip -r "$OUTPUT_DIR/AquaHyperOS-v1.0.0.zip" ./*

echo "构建完成！输出文件: $OUTPUT_DIR/AquaHyperOS-v1.0.0.zip"
