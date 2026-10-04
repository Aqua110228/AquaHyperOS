#!/bin/bash

# AquaHyperOS GitHub 上传脚本

echo ""
echo "═══════════════════════════════════════════════════════"
echo "  🚀 AquaHyperOS GitHub 上传助手"
echo "═══════════════════════════════════════════════════════"
echo ""

# 检查是否已在 workspace 目录
if [ ! -f "build.gradle" ]; then
    echo "❌ 错误：请在 ~/workspace 目录运行此脚本"
    exit 1
fi

# 获取用户信息
read -p "请输入你的 GitHub 用户名: " USERNAME
read -p "请输入仓库名（默认 AquaHyperOS）: " REPO_NAME
REPO_NAME=${REPO_NAME:-AquaHyperOS}

echo ""
echo "📋 信息确认："
echo "  用户名: $USERNAME"
echo "  仓库名: $REPO_NAME"
echo "  仓库URL: https://github.com/$USERNAME/$REPO_NAME.git"
echo ""
read -p "确认无误？(y/n): " CONFIRM

if [ "$CONFIRM" != "y" ]; then
    echo "❌ 已取消"
    exit 0
fi

echo ""
echo "🔗 添加远程仓库..."
git remote add origin "https://github.com/$USERNAME/$REPO_NAME.git" 2>/dev/null || \
git remote set-url origin "https://github.com/$USERNAME/$REPO_NAME.git"

echo ""
echo "📤 推送代码到 GitHub..."
echo "   如果需要输入密码，请使用 Personal Access Token"
echo "   Token 创建地址: https://github.com/settings/tokens"
echo ""

git push -u origin main

if [ $? -eq 0 ]; then
    echo ""
    echo "═══════════════════════════════════════════════════════"
    echo "  ✅ 上传成功！"
    echo "═══════════════════════════════════════════════════════"
    echo ""
    echo "🎉 下一步："
    echo ""
    echo "1️⃣  访问 Actions 页面："
    echo "   https://github.com/$USERNAME/$REPO_NAME/actions"
    echo ""
    echo "2️⃣  等待编译完成（5-10 分钟）"
    echo ""
    echo "3️⃣  下载 APK："
    echo "   - Actions → Artifacts"
    echo "   - 或 Releases 页面"
    echo ""
else
    echo ""
    echo "❌ 推送失败！"
    echo ""
    echo "💡 可能的原因："
    echo "  1. 仓库尚未创建"
    echo "     → 访问 https://github.com/new 创建仓库"
    echo ""
    echo "  2. 需要 Personal Access Token"
    echo "     → 访问 https://github.com/settings/tokens"
    echo "     → 创建 Token 并使用它代替密码"
    echo ""
    echo "  3. 网络问题"
    echo "     → 检查网络连接"
    echo ""
fi
