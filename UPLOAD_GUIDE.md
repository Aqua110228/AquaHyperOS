# 🚀 快速上传到 GitHub 指南

## 📋 步骤

### 1. 创建 GitHub 仓库

访问：https://github.com/new

填写：
- **Repository name**: `AquaHyperOS`
- **Description**: `HyperOS 深度定制模块 - 状态栏、控制中心、锁屏、主题自定义`
- **Public** 或 **Private**（选其一）
- ❌ **不要**勾选 "Add README"
- 点击 **Create repository**

### 2. 获取仓库地址

创建后会看到类似：
```
https://github.com/你的用户名/AquaHyperOS.git
```

### 3. 推送代码

在 AiCode 中执行（替换为你的用户名）：

```bash
cd ~/workspace
git remote add origin https://github.com/你的用户名/AquaHyperOS.git
git branch -M main
git push -u origin main
```

**如果需要输入密码**：
- GitHub 不再支持密码登录
- 需要使用 **Personal Access Token**
- 创建方法见下文

### 4. 查看自动构建

推送后：
1. 访问仓库的 **Actions** 页面
2. 会看到 "Build AquaHyperOS APK" 正在运行
3. 等待 5-10 分钟
4. 构建完成后变绿色 ✓

### 5. 下载 APK

**方式 A：从 Actions 下载**
1. 点击完成的构建
2. 下滚到 **Artifacts**
3. 点击下载（ZIP 格式）
4. 解压得到 APK

**方式 B：从 Releases 下载**
1. 访问仓库的 **Releases** 页面
2. 找到最新版本
3. 直接下载 APK

---

## 🔑 创建 GitHub Token（如果需要）

### 步骤

1. 访问：https://github.com/settings/tokens
2. 点击 **Generate new token** → **Generate new token (classic)**
3. 填写：
   - **Note**: `AquaHyperOS Upload`
   - **Expiration**: 90 days（或自定义）
   - **勾选权限**：
     - ✅ repo (全选)
     - ✅ workflow
4. 点击 **Generate token**
5. **复制 token**（只显示一次！）

### 使用 Token

推送时：
```bash
git push -u origin main
```

提示输入密码时：
- **Username**: 你的 GitHub 用户名
- **Password**: 粘贴刚才的 Token（不是你的密码）

或者直接在 URL 中使用：
```bash
git remote set-url origin https://你的用户名:你的token@github.com/你的用户名/AquaHyperOS.git
git push -u origin main
```

---

## 📱 使用 GitHub Mobile（推荐）

如果你在手机上：

1. 安装 **GitHub Mobile** App
2. 在 App 中创建仓库
3. 复制仓库 URL
4. 在 AiCode 执行推送命令

---

## ✅ 完成！

推送成功后：
- ✅ 代码已上传到 GitHub
- ✅ Actions 自动开始编译
- ✅ 5-10 分钟后可下载 APK

---

## 🎯 当前项目状态

```
✅ Git 已初始化
✅ 所有文件已暂存
✅ 提交已创建
⏳ 等待推送到 GitHub
```

**执行这个命令推送**：
```bash
cd ~/workspace
git remote add origin https://github.com/你的用户名/AquaHyperOS.git
git push -u origin main
```

---

## 🔍 检查项目内容

```bash
cd ~/workspace
ls -la
```

应该看到：
- ✅ .git/ (Git 仓库)
- ✅ .github/workflows/build.yml (自动构建)
- ✅ module/ (源代码)
- ✅ dist/ (集成文件)
- ✅ README.md
- ✅ build.gradle
- ✅ settings.gradle
- ✅ gradlew

---

**准备完毕！只需创建 GitHub 仓库并推送即可！** 🚀
