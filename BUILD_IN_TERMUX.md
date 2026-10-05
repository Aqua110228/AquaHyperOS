# 在 Termux 中构建 AquaHyperOS

## 第一步：安装环境

```bash
# 更新包管理器
pkg update && pkg upgrade -y

# 安装必要工具
pkg install -y openjdk-17 kotlin wget unzip zip aapt apksigner

# 验证安装
java -version
kotlinc -version
```

## 第二步：克隆项目

```bash
cd ~
git clone https://github.com/Aqua110228/AquaHyperOS.git
cd AquaHyperOS
```

## 第三步：创建 Xposed API Stubs

```bash
mkdir -p stubs/de/robv/android/xposed

# 创建 IXposedHookLoadPackage.java
cat > stubs/de/robv/android/xposed/IXposedHookLoadPackage.java << 'EOF'
package de.robv.android.xposed;
public interface IXposedHookLoadPackage {
    void handleLoadPackage(XC_LoadPackage.LoadPackageParam lpparam) throws Throwable;
}
EOF

# 创建 XC_LoadPackage.java
cat > stubs/de/robv/android/xposed/XC_LoadPackage.java << 'EOF'
package de.robv.android.xposed;
public class XC_LoadPackage {
    public static class LoadPackageParam {
        public String packageName;
        public ClassLoader classLoader;
    }
}
EOF

# 创建 XposedHelpers.java
cat > stubs/de/robv/android/xposed/XposedHelpers.java << 'EOF'
package de.robv.android.xposed;
public class XposedHelpers {
    public static Object callMethod(Object obj, String methodName, Object... args) { return null; }
    public static Object getObjectField(Object obj, String fieldName) { return null; }
    public static void setObjectField(Object obj, String fieldName, Object value) {}
    public static Class<?> findClass(String className, ClassLoader classLoader) { return Object.class; }
}
EOF

# 创建 XC_MethodHook.java
cat > stubs/de/robv/android/xposed/XC_MethodHook.java << 'EOF'
package de.robv.android.xposed;
public abstract class XC_MethodHook {
    public static class MethodHookParam {
        public Object thisObject;
        public Object[] args;
        public Object getResult() { return null; }
        public void setResult(Object result) {}
    }
    protected void beforeHookedMethod(MethodHookParam param) throws Throwable {}
    protected void afterHookedMethod(MethodHookParam param) throws Throwable {}
}
EOF

# 创建 XposedBridge.java
cat > stubs/de/robv/android/xposed/XposedBridge.java << 'EOF'
package de.robv.android.xposed;
public class XposedBridge {
    public static void log(String text) {}
}
EOF

# 编译 stubs
cd stubs
javac de/robv/android/xposed/*.java
jar cf ../xposed-api.jar de/
cd ..
```

## 第四步：编译 Kotlin 源码

```bash
# 生成源文件列表
find app/src/main/java -name "*.kt" > sources.txt

# 编译（需要 android.jar，如果没有就跳过）
kotlinc @sources.txt \
  -classpath xposed-api.jar \
  -d classes.jar \
  -include-runtime
```

## 第五步：构建 APK

```bash
mkdir -p build/apk
cd build/apk

# 解压 classes
jar xf ../../classes.jar

# 复制 manifest
cp ../../app/src/main/AndroidManifest.xml AndroidManifest.xml

# 创建资源
mkdir -p res/values
echo '<?xml version="1.0" encoding="utf-8"?><resources><string name="app_name">AquaHyperOS</string></resources>' > res/values/strings.xml

# 创建 scope 配置
cat > res/values/arrays.xml << 'EOF'
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string-array name="xposed_scope">
        <item>android</item>
        <item>com.android.systemui</item>
    </string-array>
</resources>
EOF

cd ..

# 打包（如果有 aapt）
aapt package -f -m \
  -M apk/AndroidManifest.xml \
  -S apk/res \
  -F AquaHyperOS-unsigned.apk \
  apk

# 添加 classes
cd apk
zip -r ../AquaHyperOS-unsigned.apk . -x "AndroidManifest.xml" "res/*"
cd ..

# 签名
keytool -genkey -v -keystore release.keystore \
  -alias release -keyalg RSA -keysize 2048 -validity 10000 \
  -storepass android -keypass android \
  -dname "CN=AquaHyperOS"

apksigner sign \
  --ks release.keystore \
  --ks-pass pass:android \
  --key-pass pass:android \
  --out AquaHyperOS-26w40f.apk \
  AquaHyperOS-unsigned.apk

# 完成
ls -lh AquaHyperOS-26w40f.apk
```

## 简化版（如果上面太复杂）

如果 Termux 没有完整的 Android SDK，最简单的方法是：

```bash
# 1. 安装 Android Studio（需要在 Termux X11 环境）
# 2. 或者直接下载之前构建好的 APK
wget https://github.com/Aqua110228/AquaHyperOS/actions/runs/37280383101/artifacts/...

# 3. 或者用这个脚本只编译 jar
pkg install kotlin
cd ~/AquaHyperOS
find app/src/main/java -name "*.kt" > sources.txt
kotlinc @sources.txt -d AquaHyperOS.jar -include-runtime
```

## 注意事项

1. Termux 可能缺少 `aapt` 和 `apksigner`，这两个工具需要 Android SDK
2. 最简单的方法是只编译成 jar，然后在有 Android Studio 的电脑上打包
3. 或者直接使用 GitHub Actions 构建好的 APK

## 推荐方案

如果 Termux 环境不完整，建议：
1. 在电脑上安装 Android Studio
2. 克隆项目
3. Build > Make Project
4. 5-10 分钟即可完成

源代码完整，任何有 Android Studio 的环境都能成功编译！
