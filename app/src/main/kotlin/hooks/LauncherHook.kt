package com.aqua.hyperos.hooks

import android.content.Context
import de.robv.android.xposed.IXposedHookLoadPackage
import de.robv.android.xposed.XC_MethodHook
import de.robv.android.xposed.XposedBridge
import de.robv.android.xposed.XposedHelpers
import de.robv.android.xposed.callbacks.XC_LoadPackage

class LauncherHook : IXposedHookLoadPackage {
    
    companion object {
        private const val TAG = "AquaHyperOS-Launcher"
        private const val PKG = "com.miui.home"
    }
    
    override fun handleLoadPackage(lpparam: XC_LoadPackage.LoadPackageParam) {
        if (lpparam.packageName != PKG) return
        
        runCatching {
            XposedBridge.log("$TAG: Init (Rust-based launcher detected)")
            hookPrefs(lpparam)
            hookSysProps(lpparam)
            hookResources(lpparam)
            XposedBridge.log("$TAG: Loaded")
        }.onFailure {
            XposedBridge.log("$TAG: Failed - ${it.message}")
        }
    }
    
    private fun hookPrefs(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClass(
                "android.app.SharedPreferencesImpl",
                lpparam.classLoader
            )
            
            // Hook getInt
            XposedHelpers.findAndHookMethod(
                clazz,
                "getInt",
                String::class.java,
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val key = param.args[0] as? String ?: return
                        val orig = param.result as Int
                        
                        when {
                            key.matches(Regex(".*(?:workspace|grid)_rows.*", RegexOption.IGNORE_CASE)) -> {
                                param.result = 6
                                XposedBridge.log("$TAG: Rows $orig -> 6")
                            }
                            key.matches(Regex(".*(?:workspace|grid)_col(?:s|umns).*", RegexOption.IGNORE_CASE)) -> {
                                param.result = 5
                                XposedBridge.log("$TAG: Cols $orig -> 5")
                            }
                            key.matches(Regex(".*(?:hotseat|dock).*count.*", RegexOption.IGNORE_CASE)) -> {
                                param.result = 5
                                XposedBridge.log("$TAG: Dock $orig -> 5")
                            }
                        }
                    }
                }
            )
            
            // Hook getString
            XposedHelpers.findAndHookMethod(
                clazz,
                "getString",
                String::class.java,
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val key = param.args[0] as? String ?: return
                        
                        when {
                            key.matches(Regex(".*grid.*size.*", RegexOption.IGNORE_CASE)) -> {
                                param.result = "6x5"
                                XposedBridge.log("$TAG: Grid size -> 6x5")
                            }
                        }
                    }
                }
            )
            
            // Hook getFloat for blur radius
            XposedHelpers.findAndHookMethod(
                clazz,
                "getFloat",
                String::class.java,
                Float::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val key = param.args[0] as? String ?: return
                        
                        when {
                            key.contains("folder", true) && key.contains("blur", true) -> {
                                param.result = 25f
                            }
                            key.contains("wallpaper", true) && key.contains("blur", true) -> {
                                param.result = 30f
                            }
                            key.contains("recents", true) && key.contains("blur", true) -> {
                                param.result = 20f
                            }
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: Prefs hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Prefs hook failed - ${it.message}")
        }
    }
    
    private fun hookSysProps(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClass(
                "android.os.SystemProperties",
                lpparam.classLoader
            )
            
            XposedHelpers.findAndHookMethod(
                clazz,
                "get",
                String::class.java,
                String::class.java,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        val key = param.args[0] as? String ?: return
                        
                        when {
                            key.contains("launcher.grid") -> param.result = "6x5"
                            key.contains("workspace.rows") -> param.result = "6"
                            key.contains("workspace.columns") -> param.result = "5"
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: SysProps hooked")
        }.onFailure {
            XposedBridge.log("$TAG: SysProps hook failed - ${it.message}")
        }
    }
    
    private fun hookResources(lpparam: XC_LoadPackage.LoadPackageParam) {
        runCatching {
            val clazz = XposedHelpers.findClass(
                "android.content.res.Resources",
                lpparam.classLoader
            )
            
            // Hook dimension for margins
            XposedHelpers.findAndHookMethod(
                clazz,
                "getDimensionPixelSize",
                Int::class.javaPrimitiveType,
                object : XC_MethodHook() {
                    override fun afterHookedMethod(param: MethodHookParam) {
                        runCatching {
                            val res = param.thisObject as android.content.res.Resources
                            val resId = param.args[0] as Int
                            val name = res.getResourceName(resId)
                            
                            when {
                                name.contains("workspace") && name.contains("padding") -> {
                                    // Custom margins would go here
                                }
                            }
                        }
                    }
                }
            )
            
            XposedBridge.log("$TAG: Resources hooked")
        }.onFailure {
            XposedBridge.log("$TAG: Resources hook failed - ${it.message}")
        }
    }
}
