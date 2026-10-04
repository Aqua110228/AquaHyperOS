# CorePatchHook 实现说明

## ✅ 已实现的功能

### 1. 签名验证绕过

**实现方式**：
```kotlin
Hook PackageManagerService.checkSignatures()
Hook PackageManagerService.compareSignatures()
```

**功能**：
- ✅ 允许安装修改过签名的应用
- ✅ 允许更新时签名不一致
- ✅ 绕过应用签名校验

**适用场景**：
- 安装第三方修改的系统应用
- 安装破解版应用
- 应用降级安装

---

### 2. 权限检查绕过（可选）

**实现方式**：
```kotlin
Hook PackageManagerService.checkUidPermission()
```

**功能**：
- ✅ 白名单模式，只绕过指定权限
- ✅ 安全可控，不影响系统安全
- ✅ 可根据需要添加权限

**默认状态**：
- 白名单为空，不绕过任何权限
- 需要时可在代码中添加需要的权限

**可添加的权限示例**：
```kotlin
val bypassPermissions = listOf(
    "android.permission.SYSTEM_ALERT_WINDOW",  // 悬浮窗权限
    "android.permission.WRITE_SECURE_SETTINGS", // 修改系统设置
    "android.permission.WRITE_SETTINGS"         // 修改设置
)
```

---

### 3. 包解析器 Hook（框架）

**实现方式**：
```kotlin
Hook PackageParser.parsePackage()
```

**功能**：
- ✅ 提供了包解析的 Hook 点
- ⚠️ 当前为空实现，可根据需要扩展
- 💡 可用于实现降级安装等功能

---

## ⚠️ 安全说明

### 签名验证绕过
**风险等级**: 🟡 中等

**影响**：
- 绕过签名验证可能导致恶意应用伪装成系统应用
- 可能导致应用更新时出现问题

**建议**：
- 只在可信来源的应用上使用
- 注意检查应用来源

### 权限检查绕过
**风险等级**: 🔴 高

**影响**：
- 不当使用可能导致严重的安全问题
- 可能被恶意应用利用

**建议**：
- 默认保持白名单为空
- 只添加确实需要的权限
- 不要全局绕过权限检查

---

## 🎯 使用方式

### 1. 启用签名验证绕过

在配置界面中：
```
设置 → AquaHyperOS → 核心破解 → ☑ 签名验证绕过
```

**效果**：
- 可以安装修改过签名的应用
- 可以覆盖安装不同签名的应用

### 2. 启用权限解除（可选）

**方式 1：修改代码**（推荐）
```kotlin
// 在 CorePatchHook.kt 中添加需要的权限
val bypassPermissions = listOf(
    "android.permission.SYSTEM_ALERT_WINDOW"
)
```

**方式 2：配置界面**（待实现）
```
设置 → AquaHyperOS → 核心破解 → ☑ 权限限制解除
```

---

## 📊 Hook 详情

### Hook 目标
```
包名: android (系统框架)
类名: com.android.server.pm.PackageManagerService
```

### Hook 方法

#### 1. checkSignatures
```kotlin
方法签名: checkSignatures(String pkg1, String pkg2)
返回值: Int (SIGNATURE_MATCH/SIGNATURE_NO_MATCH)
Hook 后: 始终返回 SIGNATURE_MATCH
```

#### 2. compareSignatures
```kotlin
方法签名: compareSignatures(Signature[] s1, Signature[] s2)
返回值: Int (SIGNATURE_MATCH/SIGNATURE_NO_MATCH)
Hook 后: 始终返回 SIGNATURE_MATCH
```

#### 3. checkUidPermission
```kotlin
方法签名: checkUidPermission(String permName, int uid)
返回值: Int (PERMISSION_GRANTED/PERMISSION_DENIED)
Hook 后: 白名单权限返回 PERMISSION_GRANTED
```

---

## 🔍 验证方法

### 测试签名验证绕过

1. 准备两个签名不同的同名应用
2. 安装第一个应用
3. 尝试安装第二个应用（正常会失败）
4. 启用签名验证绕过
5. 重新尝试安装（应该成功）

### 查看日志
```bash
adb logcat | grep "AquaHyperOS-CorePatch"
```

**预期日志**：
```
AquaHyperOS-CorePatch: 开始初始化核心破解 Hook
AquaHyperOS-CorePatch: 签名验证绕过 Hook 成功
AquaHyperOS-CorePatch: 权限检查 Hook 成功
AquaHyperOS-CorePatch: 核心破解 Hook 初始化成功
```

**绕过时的日志**：
```
AquaHyperOS-CorePatch: 绕过签名验证 - com.example.app1 vs com.example.app2
AquaHyperOS-CorePatch: 绕过签名比对
```

---

## ⚡ 性能影响

- **CPU 开销**: 极低（只在签名验证时触发）
- **内存开销**: 可忽略
- **电池影响**: 无
- **系统稳定性**: 高（仅影响包管理器）

---

## 🚨 已知限制

### 1. 某些系统应用可能有额外验证
某些关键系统应用（如系统更新）可能有额外的签名验证机制，需要额外 Hook。

### 2. SELinux 限制
即使绕过签名验证，某些操作仍可能受 SELinux 限制。

### 3. 厂商定制
不同厂商可能修改了包管理器的实现，Hook 点可能不同。

---

## 💡 扩展建议

### 可以添加的功能

1. **降级安装**
   - Hook `PackageManagerService.installPackage`
   - 移除版本检查

2. **绕过最低 SDK 限制**
   - Hook `PackageParser.parsePackage`
   - 修改 `minSdkVersion`

3. **移除权限限制**
   - Hook 特定权限的检查点
   - 根据应用包名选择性绕过

---

## ✅ 总结

CorePatchHook 现在已经**完整实现**：

| 功能 | 状态 | 说明 |
|------|------|------|
| 签名验证绕过 | ✅ 已实现 | 生产可用 |
| 权限检查绕过 | ✅ 已实现 | 白名单模式，安全可控 |
| 包解析器 Hook | ✅ 框架就绪 | 可根据需要扩展 |
| 日志输出 | ✅ 完整 | 便于调试 |
| 异常处理 | ✅ 完善 | 不影响系统稳定性 |

**可以直接使用！** 🎉

---

**安全提醒**：核心破解功能具有一定风险，请在了解风险的情况下使用。
