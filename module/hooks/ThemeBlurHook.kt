package com.aqua.hyperos.hooks

import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class ThemeBlurHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-Blur"
        private const val PKG = "com.android.systemui"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init")
            hookBlur(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hookBlur(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "com.android.systemui.statusbar.BlurUtils",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "applyBlur",
                Any::class.java,
                Float::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        // Force enable blur
                        param.args[1] = 1.0f
                    }
                }
            )
            
            XposedBridge.log("$TAG: Blur hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Hook failed - ${it.message}")
        }
    }
}
