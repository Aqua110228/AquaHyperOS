# 🚀 GitHub Actions 自动编译指南

## ✨ 无需电脑，在线编译 APK！

### 方案优势

- ✅ **完全免费**
- ✅ **无需电脑**
- ✅ **自动编译**
- ✅ **每次推送自动构建**
- ✅ **可下载 APK**

---

## 📋 步骤说明

### 1. 创建 GitHub 仓库

1. 打开 https://github.com/new
2. 填写：
   - Repository name: `AquaHyperOS`
   - Description: `HyperOS 深度定制模块`
   - 选择 `Public` 或 `Private`
3. 点击 `Create repository`

### 2. 上传代码

#### 方法 A: 使用 Git（推荐）

```bash
cd ~/workspace

# 初始化 Git
git init
git add .
git commit -m "Initial commit: AquaHyperOS v1.0.0"

# 添加远程仓库（替换为你的用户名）
git remote add origin https://github.com/你的用户名/AquaHyperOS.git

# 推送代码
git branch -M main
git push -u origin main
```

#### 方法 B: 使用 GitHub Web 界面

1. 打包项目：
```bash
cd ~/workspace
tar -czf AquaHyperOS.tar.gz .
```

2. 下载 `AquaHyperOS.tar.gz`
3. 在 GitHub 仓库页面点击 `Add file` → `Upload files`
4. 上传并提交

### 3. 等待自动编译

1. 推送后，访问仓库的 **Actions** 页面
2. 查看构建进度（约 5-10 分钟）
3. 构建完成后，会显示绿色 ✓

### 4. 下载 APK

#### 方法 1: 从 Actions 下载

1. 点击完成的 workflow
2. 下滑到 **Artifacts** 部分
3. 点击 `AquaHyperOS-xxxxxx` 下载
4. 解压 ZIP 获得 APK

#### 方法 2: 从 Releases 下载

1. 访问仓库的 **Releases** 页面
2. 找到最新版本
3. 直接下载 APK 文件

---

## 🎯 使用场景

### 开发模式

每次修改代码后：
```bash
git add .
git commit -m "修复 xxx 问题"
git push
```

自动触发编译，5-10 分钟后获得新 APK。

### 自动发布

推送到 `main` 或 `master` 分支时：
- 自动编译
- 自动创建 Release
- 自动上传 APK
- 生成版本说明

---

## 📊 编译日志

### 查看构建进度

1. 访问 **Actions** 页面
2. 点击最新的 workflow
3. 点击 `build` 查看详细日志
4. 可以看到每一步的执行情况

### 构建失败？

1. 查看错误日志
2. 根据错误信息修复代码
3. 重新推送

---

## ⚙️ 高级配置

### 手动触发构建

1. 访问 **Actions** 页面
2. 选择 `Build AquaHyperOS APK`
3. 点击 `Run workflow`
4. 选择分支并运行

### 修改构建配置

编辑 `.github/workflows/build.yml`：

```yaml
# 修改触发条件
on:
  push:
    branches: [ main ]
  
  # 添加定时构建（每天凌晨）
  schedule:
    - cron: '0 0 * * *'
```

---

## 🔒 私有仓库

如果创建的是私有仓库：
- Actions 每月有免费额度（2000 分钟）
- 超出后需要付费
- 对于个人项目完全够用

---

## 📱 手机操作

### 使用手机上传代码

可以使用这些 App：
- **GitHub Mobile** (官方 App)
- **GitJournal** (支持 Git)
- **Working Copy** (iOS)

直接在手机上：
1. 修改代码
2. 提交更改
3. 推送到 GitHub
4. 自动编译

---

## ✅ 完整流程示例

### 第一次使用

```bash
# 1. 创建 GitHub 仓库（网页操作）

# 2. 上传代码
cd ~/workspace
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/你的用户名/AquaHyperOS.git
git push -u origin main

# 3. 等待 5-10 分钟

# 4. 访问 Actions 页面下载 APK
```

### 日常使用

```bash
# 修改代码后
git add .
git commit -m "更新功能"
git push

# 等待自动编译
# 下载新 APK
```

---

## 🎉 优势总结

| 特性 | GitHub Actions | 本地电脑 |
|------|----------------|----------|
| 需要电脑 | ❌ 不需要 | ✅ 需要 |
| 需要 Android Studio | ❌ 不需要 | ✅ 需要 |
| 编译速度 | 5-10 分钟 | 5-10 分钟 |
| 费用 | ✅ 免费 | ✅ 免费 |
| 自动化 | ✅ 完全自动 | ❌ 手动 |
| 随时随地 | ✅ 任何设备 | ❌ 只能电脑 |

---

## 🔗 相关链接

- GitHub Actions 文档: https://docs.github.com/actions
- GitHub Mobile: https://github.com/mobile

---

**完全不需要电脑，只需要 GitHub 账号即可！** 🎉
