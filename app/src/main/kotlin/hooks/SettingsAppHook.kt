package com.aqua.hyperos.hooks

import android.content.Context
import android.view.View
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class SettingsAppHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-SettingsApp"
        private const val PKG = "com.android.settings"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init")
            hideEntries(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hideEntries(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClassIfExists(
                "androidx.preference.Preference",
                lpparam.classLoader
            ) ?: return
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "setVisible",
                Boolean::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun beforeHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val pref = param.thisObject
                            val key = XposedHelpers.callMethod(pref, "getKey") as? String
                            
                            if (shouldHide(key)) {
                                param.args[0] = false
                            }
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: Hide entries hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Hook failed - ${it.message}")
        }
    }
    
    private fun shouldHide(key: String?): Boolean {
        if (key == null) return false
        
        return when {
            key.contains("benefits", true) -> true
            key.contains("equity", true) -> true
            else -> false
        }
    }
}
