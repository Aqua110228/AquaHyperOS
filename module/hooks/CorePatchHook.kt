package com.aqua.hyperos.hooks

import android.content.pm.PackageManager
import android.content.pm.Signature
import com.aqua.hyperos.utils.Logger
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class CorePatchHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "核心破解"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName == "android") {
            Logger.hookStart(TAG, lpparam.packageName)
            
            runCatching {
                patchSignatureCheck(lpparam)
                patchPermissionCheck(lpparam)
                Logger.i(TAG, "核心破解模块加载完成")
            }.onFailure {
                Logger.e(TAG, "核心破解模块加载失败", it)
            }
        }
    }
    
    private fun patchSignatureCheck(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val className = "com.android.server.pm.PackageManagerService"
            val clazz = XposedHelpers.findClassIfExists(className, lpparam.classLoader)
            
            if (clazz == null) {
                Logger.classNotFound(TAG, className)
                return
            }
            
            Logger.classFound(TAG, className)
            
            // Hook checkSignatures
            XposedHelpers.findAndHookMethod(
                clazz,
                "checkSignatures",
                String::class.java,
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val pkg1 = param.args[0] as String
                        val pkg2 = param.args[1] as String
                        param.result = PackageManager.SIGNATURE_MATCH
                        Logger.d(TAG, "绕过签名验证: $pkg1 vs $pkg2")
                    }
                }
            )
            Logger.methodHooked(TAG, "checkSignatures")
            
            // Hook compareSignatures
            XposedHelpers.findAndHookMethod(
                clazz,
                "compareSignatures",
                Array<Signature>::class.java,
                Array<Signature>::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        param.result = PackageManager.SIGNATURE_MATCH
                        Logger.v(TAG, "绕过签名对比")
                    }
                }
            )
            Logger.methodHooked(TAG, "compareSignatures")
            
            Logger.hookSuccess(TAG, "签名验证绕过")
        }.onFailure {
            Logger.hookFailed(TAG, "签名验证绕过", it.message ?: "未知错误")
            Logger.e(TAG, "签名验证绕过失败", it)
        }
    }
    
    private fun patchPermissionCheck(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val className = "com.android.server.pm.PackageManagerService"
            val clazz = XposedHelpers.findClassIfExists(className, lpparam.classLoader) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "checkUidPermission",
                String::class.java,
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        val permName = param.args[0] as? String ?: return
                        val uid = param.args[1] as Int
                        
                        // Whitelist (empty by default)
                        val bypassList = emptyList<String>()
                        
                        if (bypassList.contains(permName)) {
                            param.result = PackageManager.PERMISSION_GRANTED
                            Logger.d(TAG, "绕过权限检查: $permName (UID: $uid)")
                        }
                    }
                }
            )
            Logger.methodHooked(TAG, "checkUidPermission")
            Logger.hookSuccess(TAG, "权限检查Hook (白名单模式)")
        }.onFailure {
            Logger.hookFailed(TAG, "权限检查Hook", it.message ?: "未知错误")
        }
    }
}
