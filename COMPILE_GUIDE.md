# 🔧 APK 编译指南

## ⚠️ 问题说明

当前环境没有 Android SDK，无法直接编译 APK。

---

## 📦 解决方案

### 方案 1: 使用 Android Studio（推荐）✅

#### 下载项目
```bash
# 从 AiCode 下载整个 workspace 文件夹
# 或者打包项目
tar -czf AquaHyperOS.tar.gz ~/workspace
```

#### 在 Android Studio 中编译
```
1. File → Open → 选择 workspace 目录
2. 等待 Gradle 同步
3. Build → Build Bundle(s) / APK(s) → Build APK(s)
4. 生成位置：app/build/outputs/apk/release/
```

---

### 方案 2: 使用在线编译服务

#### GitHub Actions
创建 `.github/workflows/build.yml`:
```yaml
name: Build APK
on: [push]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-java@v3
        with:
          java-version: '17'
      - name: Build APK
        run: ./gradlew assembleRelease
      - uses: actions/upload-artifact@v3
        with:
          name: apk
          path: app/build/outputs/apk/release/*.apk
```

---

### 方案 3: 手动打包（高级）

需要工具：
- aapt2
- d8
- zipalign
- apksigner

步骤：
```bash
# 1. 编译资源
aapt2 compile --dir module/res -o compiled_res.zip

# 2. 链接资源
aapt2 link compiled_res.zip \
  --manifest module/AndroidManifest.xml \
  -o base.apk

# 3. 编译 Kotlin → DEX
kotlinc module/hooks/*.kt module/ui/*.kt module/utils/*.kt \
  -classpath xposed-api.jar \
  -d classes

d8 classes/*.class --output classes.dex

# 4. 添加 DEX 到 APK
zip -j base.apk classes.dex

# 5. 对齐
zipalign -v 4 base.apk aligned.apk

# 6. 签名
apksigner sign --ks keystore.jks aligned.apk
```

---

## 🎯 推荐方案

**使用 Android Studio 编译**

1. 下载 Android Studio: https://developer.android.com/studio
2. 打开本项目
3. 一键编译

**预计时间**：
- 首次同步：5-10 分钟
- 编译：2-3 分钟

---

## 📁 项目已准备完毕

所有源文件都在：
```
~/workspace/
├── app/
│   └── build.gradle
├── module/
│   ├── hooks/          (10 个 Hook 类)
│   ├── ui/             (SettingsActivity)
│   ├── utils/          (Logger)
│   ├── AndroidManifest.xml
│   └── res/
├── build.gradle
├── settings.gradle
└── gradlew
```

直接用 Android Studio 打开即可编译。

---

## ⚡ 快速开始

如果你有 Android Studio：
```
File → Open → 选择 ~/workspace
等待同步完成
Build → Build APK
```

如果没有：
```
下载 Android Studio
安装 Android SDK
然后编译
```

---

**项目已完全准备好，只需要 Android Studio 编译即可！**
