# 开发指南

## 项目架构

AquaHyperOS 采用模块化架构，基于 Symphony Framework 实现系统级Hook。

### 核心组件

1. **Hook模块** (`module/hooks/`)
   - 每个Hook类负责特定功能域
   - 继承 `IXposedHookLoadPackage` 接口
   - 精确定位目标方法和类

2. **配置系统** (`module/config/`)
   - JSON格式配置文件
   - 支持运行时动态修改
   - 持久化用户设置

3. **Symphony Framework集成** (`framework/`)
   - 框架配置和元数据
   - Hook作用域定义
   - 模块依赖管理

## 添加新Hook

1. 在 `module/hooks/` 创建新的Kotlin文件
2. 实现 `IXposedHookLoadPackage` 接口
3. 在 `framework/symphony.json` 注册Hook
4. 添加对应的配置项

### Hook示例

```kotlin
class MyCustomHook : IXposedHookLoadPackage {
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        // 检查目标包名
        if (lpparam.packageName != "target.package") return
        
        // 定位目标类和方法
        val targetClass = XposedHelpers.findClass(
            "com.example.TargetClass", 
            lpparam.classLoader
        )
        
        // Hook方法
        XposedHelpers.findAndHookMethod(
            targetClass,
            "targetMethod",
            object : XC_MethodHook() {
                override fun beforeHookedMethod(param: MethodHookParam) {
                    // 方法执行前的逻辑
                }
                
                override fun afterHookedMethod(param: MethodHookParam) {
                    // 方法执行后的逻辑
                }
            }
        )
    }
}
```

## 调试技巧

1. 启用debug日志：修改 `module/config/default.json` 中的 `debug` 为 `true`
2. 使用 `XposedBridge.log()` 输出日志
3. 通过 `adb logcat` 查看实时日志

## 构建和测试

```bash
# 构建模块
./scripts/build.sh

# 安装到设备
adb push output/AquaHyperOS-v1.0.0.zip /sdcard/
# 然后在Magisk/KernelSU中刷入

# 查看日志
adb logcat | grep AquaHyperOS
```

## 注意事项

- 所有Hook必须有异常处理
- 避免在主线程执行耗时操作
- Hook前验证类和方法是否存在
- 保持代码向后兼容
- 定期测试系统应用更新后的兼容性
